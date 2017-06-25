//
//  Power.m
//  TouchAlgebra
//
//  Created by David Sullivan on 8/29/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "Power.h"
#import "Integer.h"
#import "Multiplication.h"
#import "Fraction.h"
#import "RealNumber.h"
#import "Addition.h"

#define LINE_THICKNESS 3.0
#define MAX_EXPONENT_EXPANSION 10
#define RADICAL_SPACING 15
#define EXPONENT_SPACING 2
#define NEGATIVE_SIGN_WIDTH 10

@interface Power()

// needed so we can set our subterm's parent term pointer and still used properties
@property (nonatomic, retain, getter=_base,     setter=_setBase:)     Term *base;
@property (nonatomic, retain, getter=_exponent, setter=_setExponent:) Term *exponent;

@end


@implementation Power


- (Term *)   base {
	
	return [self _base];
}

- (void) setBase:(Term *) newBase {
	
	Term *copyBase = [newBase copy];
	[self _setBase:copyBase];
	[copyBase setParentTerm:self];
	[copyBase release];
}

- (Term *)   exponent {
	
	return [self _exponent];
}

- (void) setExponent:(Term *) newExp {
	
	Term *copyExp = [newExp copy];
	[self _setExponent:copyExp];
	[copyExp setParentTerm:self];
	[copyExp release];
	
	// need to reset the font so the exponent font gets set
	[self setFont:font];
 }

@synthesize base, exponent;

// initialize with a string value - this is the designated initializer
- (id) initWithTermValue:(NSString*) someStringValue {
	
	if (self = [super initWithTermValue:@"^"]) {
		simpleTerm = NO;
	}
	
	return self;
}

// default initialization calls designated initializer
- (id) init{
	
	return [self initWithTermValue:@"^"];
}

- (id) initWithBase: (Term *) b andExponent: (Term *) e {
	
	Power *p = (Power *) [self init];
	[p setBase:b];
	[p setExponent:e];
	
	return p;
}

- (BOOL) isEquivalent:(Term *) term {
	
	if ([term isKindOfClass:[Power class]]) {
		
		return [base isEquivalent:[(Power *) term base]] && [exponent isEquivalent:[(Power *) term exponent]] && self.isOpposite == term.isOpposite;
	}
	return NO;
}

- (BOOL) isEquivalentIgnoringSign:(Term *)term {
	
	if ([term isKindOfClass:[Power class]]) {
		
		return [base isEquivalent:[(Power *) term base]] && [exponent isEquivalent:[(Power *) term exponent]];
	}
	return NO;	
}

- (BOOL) replaceSubterm: (Term *) oldTerm withTerm: (Term *) newTerm {
	
	if ([base replaceSubterm:oldTerm withTerm:newTerm]) {
		
		return YES;
	}
	else if ([exponent replaceSubterm:oldTerm withTerm:newTerm]){
		
		return YES;
	}
	else if (base == oldTerm) {
		
		[self setBase:newTerm];
		[newTerm setParentTerm:self];
		return YES;
		
	} else if (exponent == oldTerm){
		
		[self setExponent:newTerm];
		[newTerm setParentTerm:self];
		return YES;
	}
	return NO;
}

// override printStringValue so it returns (1 + c)/(2 + x), etc.
- (NSMutableString *) printStringValue {
	
	NSMutableString *newString = [[[NSMutableString alloc] init] autorelease];
	
	// put parenthesis around negative powers
	if (isOpposite) {
		[newString appendString:@"-("];
	}
	
	if ([base isSimpleTerm] && ![base isOpposite]) {
		[newString appendString:[base printStringValue]];
	}
	else {
		[newString appendString:@"("];
		[newString appendString:[base printStringValue]];
		[newString appendString:@")"];
	}
	
	[newString appendString:termValue];
	
	
	if ([exponent isSimpleTerm]) {
		[newString appendString:[exponent printStringValue]];
	}
	else {
		[newString appendString:@"("];
		[newString appendString:[exponent printStringValue]];
		[newString appendString:@")"];
	}
	
	if (isOpposite) {
		[newString appendString:@")"];
	}
	
	return newString;
}

- (id) copyWithZone:(NSZone *) zone {
	
	Power *newTerm = [[Power alloc] initWithTermValue:[self termValue]];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:nil];
	[newTerm setColor:color];
	[newTerm setFont:font];
	
	// copy the numerator and denominator
	Term *newBase = [[base copyWithZone:zone] autorelease];
	Term *newExp  = [[exponent copyWithZone:zone] autorelease];
	[newTerm setBase:newBase];
	[newTerm setExponent:newExp];
	
	return newTerm;
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	[super encodeWithCoder:coder];
	[coder encodeObject:base forKey:@"base"];
	[coder encodeObject:exponent forKey:@"exponent"];
	
}

- (id) initWithCoder:(NSCoder *)coder { 
	
	// Init first.
	if (self = [super initWithCoder:coder]) {
		
		base = [[coder decodeObjectForKey:@"base"] retain];
		exponent = [[coder decodeObjectForKey:@"exponent"] retain];
	}
	
	return self;
}

- (void) setFont: (UIFont *) f {
	
	[super setFont:f];
	
	// set font for base & exponent, mapping exponent font
	[base setFont:f];
	[exponent setFont:[self defaultExponentFont]];

}

- (NSUInteger) complexity {
	
	NSUInteger complexity = [base complexity];
	complexity += [exponent complexity];
	return complexity + 1;
}

- (void) drawLeftParen: (CGRect) rect context: (CGContextRef) context  {
	
	CGContextSetLineWidth(context, LINE_THICKNESS);
	CGContextSetLineCap(context, kCGLineCapRound);
	[color setStroke];
	
	CGContextMoveToPoint(context, rect.origin.x + rect.size.width - LINE_THICKNESS, rect.origin.y + LINE_THICKNESS);
	CGContextAddLineToPoint(context, rect.origin.x + LINE_THICKNESS, rect.origin.y + LINE_THICKNESS);
	CGContextAddLineToPoint(context, rect.origin.x + LINE_THICKNESS, rect.size.height - LINE_THICKNESS);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - LINE_THICKNESS, rect.size.height - LINE_THICKNESS);
	CGContextStrokePath(context);
}

- (void) drawRightParen: (CGRect) rect context: (CGContextRef) context  {
	
	CGContextSetLineWidth(context, LINE_THICKNESS);
	CGContextSetLineCap(context, kCGLineCapRound);
	[color setStroke];
	
	CGContextMoveToPoint(context, rect.origin.x + LINE_THICKNESS, rect.origin.y + LINE_THICKNESS);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - LINE_THICKNESS, rect.origin.y + LINE_THICKNESS);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - LINE_THICKNESS, rect.size.height - LINE_THICKNESS);
	CGContextAddLineToPoint(context, rect.origin.x + LINE_THICKNESS, rect.size.height - LINE_THICKNESS);
	CGContextStrokePath(context);
}

- (void) drawRadical: (CGContextRef) context  {
	
	CGContextSetLineWidth(context, LINE_THICKNESS);
	CGContextSetLineCap(context, kCGLineCapRound);
	[color setStroke];
	
	CGContextMoveToPoint(context, rMargin.origin.x + rMargin.size.width - LINE_THICKNESS, LINE_THICKNESS);
	CGContextAddLineToPoint(context, lMargin.origin.x + lMargin.size.width - LINE_THICKNESS/2, LINE_THICKNESS);
	CGContextAddLineToPoint(context, lMargin.origin.x + lMargin.size.width - RADICAL_SPACING, lMargin.size.height - LINE_THICKNESS);
	CGContextAddLineToPoint(context, lMargin.origin.x + lMargin.size.width - RADICAL_SPACING - 10, lMargin.size.height - LINE_THICKNESS - 10);
	CGContextStrokePath(context);
	
	// draw the minus sign if necessay
	if (isOpposite) {
		CGContextMoveToPoint(context, 0, lMargin.size.height - LINE_THICKNESS - 20);
		CGContextAddLineToPoint(context, NEGATIVE_SIGN_WIDTH, lMargin.size.height - LINE_THICKNESS - 20);
		CGContextStrokePath(context);
	}
	
}

- (BOOL) hasParenthesis {
	
	return ![base isSimpleTerm] || ([base isSimpleTerm] && [base isOpposite]) || [self isOpposite];
}

- (void)drawRect:(CGRect)rect {

	[super drawRect:rect];
	
	// get the drawing context
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadow(context, CGSizeMake(3.0f, 3.0f), 5.0f);

	// draw radical for powers of the form 1/n
	if ([self isRadical]) {
		
		[self drawRadical:context];
	}
	
	// draw the parenthesis
	else if ([self hasParenthesis]) {
		
		[self drawLeftParen:lMargin context:context];
		[self drawRightParen:rMargin context:context];
	}
	
}

- (void) renderInView: (UIView *) view atLocation: (CGPoint) loc {
	
	// make the background transparent
	[self setBackgroundColor:[UIColor clearColor]];
	
	// remove all subviews
	for (UIView *v in self.subviews) {
		[v removeFromSuperview];
	}
		
	// render the base at the origin
	[base   renderInView:self atLocation:self.frame.origin];

	// layout with radical symbol
	if ([self isRadical]) {

		// if radical is negative leave room for negative sign
		int signOffset = isOpposite ? NEGATIVE_SIGN_WIDTH : 0;
		
		// render the radical at the origin
		Integer *radical = (Integer *) [(Fraction *) exponent denominator];
		[radical renderInView:self atLocation:CGPointMake(signOffset, self.frame.origin.y)];
		
		// set the parenthesis size and location
		lMargin = CGRectMake(signOffset, 0, radical.frame.size.width + RADICAL_SPACING, base.frame.size.height);
		rMargin = CGRectMake(signOffset + lMargin.size.width + base.frame.size.width, 0, 5, base.frame.size.height);
		
		// move the subviews 
		[base setFrame:CGRectMake(signOffset + lMargin.size.width, 
								  LINE_THICKNESS*2, 
								  base.frame.size.width, 
								  base.frame.size.height)];
		[radical setFrame:CGRectMake(signOffset, 
									  0, 
									  radical.frame.size.width, 
									  radical.frame.size.height)];
		
		// set the rendering base
		renderingBase = [base renderingBase];
		
		// set the frame
		[self setFrame:CGRectMake(loc.x, loc.y, signOffset + lMargin.size.width + base.frame.size.width + rMargin.size.width, base.frame.size.height + LINE_THICKNESS*2)];
	}
	
	else { 
		
		[exponent renderInView:self atLocation:self.frame.origin];
		
		// if the power is opposite leave room for the a minus sign
		int signWidth = 0;
		if (isOpposite) {
			signWidth = [@"-" sizeWithFont:font].width;
		}
		
		// compute the height and width making sure the exponent doesn't extend below
		// half the height of the base
		CGFloat exponentOffset = 0;
		if (exponent.frame.size.height > base.frame.size.height/2) {
			
			exponentOffset = exponent.frame.size.height - base.frame.size.height/2;
			
		}

		// add parenthesis if base is not a simple term or is opposite
		if ([self isOpposite]) {
			
			// set the paranthesis size and location
			lMargin = CGRectMake(signWidth, exponentOffset, 10, base.frame.size.height+exponentOffset);
			rMargin = CGRectMake(signWidth + lMargin.size.width + base.frame.size.width, exponentOffset, 10, base.frame.size.height+exponentOffset);
		}
		else if (![base isSimpleTerm] || ([base isSimpleTerm] && [base isOpposite])) {

			// set the paranthesis size and location
			lMargin = CGRectMake(0, exponentOffset, 10, base.frame.size.height+exponentOffset);
			rMargin = CGRectMake(lMargin.size.width + base.frame.size.width, exponentOffset, 10, base.frame.size.height+exponentOffset);
		}

		else {
			
			// use empty rectangle for parenthesis if simple term
			lMargin = CGRectMake(0, 0, 0, 0);
			rMargin = CGRectMake(0, 0, 0, 0);
		}
		
		CGFloat height = base.frame.size.height + exponentOffset;
		CGFloat width  = signWidth + base.frame.size.width  + exponent.frame.size.width + lMargin.size.width + rMargin.size.width + EXPONENT_SPACING;
		
		
		// move the subviews 
		[base setFrame:CGRectMake(signWidth + lMargin.size.width, 
								  exponentOffset, 
								  base.frame.size.width, 
								  base.frame.size.height)];
		[exponent setFrame:CGRectMake(signWidth + base.frame.size.width + lMargin.size.width + rMargin.size.width + EXPONENT_SPACING, 
									  0, 
									  exponent.frame.size.width, 
									  exponent.frame.size.height)];
		
		// set the rendering base
		renderingBase = [base renderingBase] + exponentOffset;
		
		// add the negative sign if necessary
		if (isOpposite) {
			
			// create the sign label 
			UILabel *sign = [Term createLabelAtX:0 
									  y:renderingBase - [font ascender]
								  width:[@"-" sizeWithFont:font].width
								 height:[@"-" sizeWithFont:font].height
						backgroundColor:[UIColor clearColor]
							  fontColor:color
								   font:font
								  label:@"-"];
			
			[self addSubview:sign];
		}

		// set the frame
		[self setFrame:CGRectMake(loc.x, loc.y, width, height)];
	}
	
	[view addSubview:self];
	[self setNeedsDisplay];
}	

- (CGFloat) renderingBase {
	
	return renderingBase;
}

- (Term *) factorRoot: (int) root ofRadicand: (Term *) radicand  {
	
	// can't deal with a zero or negative radicand
	if (root < 1) {
		return nil;
	}
	
	// root is one (i.e. 1/1) return the term
	if (root == 1) {
		Term *t = [[radicand copy] autorelease];
		
		// take the opposite if necessary
		if ([self isOpposite]) {
			[t opposite];
		}
		return t;
	}
	
	// term is zero
	if ([radicand isZero]) {
		return [[Integer alloc] initWithInt:0];
	}
	
	// factor integers
	if ([radicand isKindOfClass:[Integer class]]) {
				
		// set up to factor
		int intRadicand = [(Integer *) radicand rawValue];
		
		// factor
		rootFactorResult result = [Term factorRoot:root ofRadicand:intRadicand];
		
		if (result.wasFactored) {
			
			if (result.radicandRemainder == 0 || result.radicandRemainder == 1) {
				
				// take the opposite if necessary returning a simple result
				if ([self isOpposite]) {
					return [[[Integer alloc] initWithInt:result.result*-1] autorelease];
				}
				else {
					return [[[Integer alloc] initWithInt:result.result] autorelease];
				}
			}
			else {
				
				// create a multiplication with the new result
				Integer *rr = [[[Integer alloc] initWithInt:result.radicandRemainder] autorelease];
				Power *p = [[[Power alloc] initWithBase:rr andExponent:exponent] autorelease];
				
				Integer *r = [[[Integer alloc] initWithInt:result.result] autorelease];
				
				// take the opposite if necessary
				if ([self isOpposite]) {
					[r opposite];
				}
				
				return [[[Multiplication alloc] init:r, p, nil] autorelease];
			}
		}
		else {
			return nil;
		}
	}
	
	// factor powers
	else if([radicand isKindOfClass:[Power class]]) {
		
		if ([[(Power *) radicand exponent] isKindOfClass:[Integer class]]) {
			
			int radicandExp = [(Integer *) [(Power *) radicand exponent] rawValue];
			
			// exponent is inverse of root - return the base
			if (radicandExp == root) {

				Power *p = [[[(Power *) radicand base] copy] autorelease];
				
				// take the opposite if necessary
				if ([self isOpposite]) {
					[p opposite];
				}
				
				return p;
			}
			
			// create a new power using root and exponent of radicand
			else if (radicandExp > root) {
				
				Fraction *newExp = [[[Fraction alloc] initWithNum:[[[Integer alloc] initWithInt:radicandExp] autorelease] 
														 andDenom:[[[Integer alloc] initWithInt:root] autorelease]] 
									 autorelease];
				Power *p = [[[Power alloc] initWithBase:[(Power *) radicand base] andExponent:newExp] autorelease];
				
				// take the opposite if necessary
				if ([self isOpposite]) {
					[p opposite];
				}
				
				return p;
			}
		}
	}
	return nil;
}

- (Term *) copyReducingWithSubTerm:(Term *) source andSubTerm:(Term *) target {

    // if exponent is zero return one
    if ([exponent isKindOfClass:[Integer class]] && [(Integer *)exponent rawValue] == 0 ) {

        if ([self isOpposite]) {
            return [[Integer alloc] initWithInt:-1];
        }
        return [[Integer alloc] initWithInt:1];
    }
    
    // if the exponent is one return the base
    else if ([exponent isKindOfClass:[Integer class]] && [(Integer *) exponent rawValue] == 1) {
        
        Term *b = [[base copy] autorelease];
        if ([self isOpposite]) {
            [b opposite];
        }
        return [b retain];
    }

    // if the exponent is negative one return the 1/base
    else if ([exponent isKindOfClass:[Integer class]] && [(Integer *) exponent rawValue] == -1 && ![base isKindOfClass:[Power class]]) {
        
        // base cannot be zero
        if ([base isZero]) {
            return nil;
        }
        
        Fraction *f = [[Fraction alloc] initWithNum:[[[Integer alloc] initWithInt:1] autorelease] 
                                           andDenom:[[base copy] autorelease]];
        
        if ([self isOpposite]) {
            [f opposite];
        }
        return f;
    }

    // exponent < -1
    else if ([exponent isKindOfClass:[Integer class]] && [(Integer *) exponent rawValue] < -1) {
        
        // base cannot be zero
        if ([base isZero]) {
            return nil;
        }
        
        Integer *newExp = [[[Integer alloc] initWithInt:[(Integer *) exponent rawValue]*-1] autorelease];
        Power *p = [[[Power alloc] initWithBase:[self base] andExponent:newExp] autorelease];
        if ([self isOpposite]) {
            [p opposite];
        }
        return [[Fraction alloc] initWithNum:[[[Integer alloc] initWithInt:1] autorelease]  
                                    andDenom:p];
    }

	// radicals - take the square root, 3rd root, n-root of the base
	else if ([self isRadical] &&
		(target == base     || [base isImmediateSubTerm:target]) && 
		(source == exponent || [exponent isImmediateSubTerm:source])
		) {
		
		Term *root = [(Fraction *) exponent denominator];
		
		// "distribute" the root across a multiplication - (c*b)^(1/2) -> (c^(1/2))*(b^(1/2))
		if ([base isKindOfClass:[Multiplication class]]) {
			
			// create the multiplication
			Multiplication *m = [[Multiplication alloc] init];
			
			// add new power terms to multiplication
			Power *p;
			for (Term *t in [(Multiplication *) base termList]) {
				
				p = [[[Power alloc] initWithBase:t andExponent:exponent] autorelease];
				[m appendTerm:p];
			}
			
			// take the opposite if appropriate
			if ([self isOpposite]) {
				[m opposite];
			}
			return m;
		}
		
		// "distribute" the root across a fraction - (c/b)^(1/2) -> (c^(1/2))/(b^(1/2))
		else if ([base isKindOfClass:[Fraction class]]) {
			
			// create the new numerator and denominator
			Power *num   = [[[Power alloc] initWithBase:[(Fraction *) base numerator]   andExponent:exponent] autorelease];
			Power *denom = [[[Power alloc] initWithBase:[(Fraction *) base denominator] andExponent:exponent] autorelease];
			
			// take the opposite if appropriate
			if ([self isOpposite]) {
				[num opposite];
			}
			
			// return the fraction
			return [[Fraction alloc] initWithNum:num andDenom:denom];
		}

		// base is power and the base exponent is the inverse of the root
		else if ([[self base] isKindOfClass:[Power class]] && [[(Power *) base exponent] isEquivalent:root]) {
			
			Power *p = [[[(Power *) base  base] copy] autorelease];
			
			// take the opposite if appropriate
			if ([self isOpposite]) {
				[p opposite];
			}
			
			return [p retain];
		}
		
		
		// integer root
		else if ([root isKindOfClass:[Integer class]]) {

			// if the root is less than one - ignore
			if ([(Integer *)root rawValue] < 1) {
				
				return nil;
			}
			
			if ([base isKindOfClass:[Integer class]] || [base isKindOfClass:[Power class]]) {
				
				// factor
				Term *t = [self factorRoot:[(Integer *) root rawValue] ofRadicand:base];
				if (t && [base isKindOfClass:[Integer class]]) {
					return [t retain];
				}
				
				// create a new fractional exponent for the power
				else if ([base isKindOfClass:[Power class]]){
					
					Fraction *newExp = [[[Fraction alloc] initWithNum:[(Power *) base exponent] andDenom:root] autorelease];
					
					Power *p = [[[Power alloc] initWithBase:[(Power *) base base] andExponent:newExp] autorelease];

					// take the opposite if appropriate
					if ([self isOpposite]) {
						[p opposite];
					}
					
					return [p retain];
					
				}
				else {
					return nil;
				}
			}
		}
		
		// non-integer root
		else {
			
			// create a new fractional exponent if base is power
			if ([[self base] isKindOfClass:[Power class]]) {
				
				Fraction *newExp = [[[Fraction alloc] initWithNum:[(Power *) base exponent] andDenom:root] autorelease];
				
				Power *p = [[[Power alloc] initWithBase:[(Power *) base base] andExponent:newExp] autorelease];
				
				// take the opposite if appropriate
				if ([self isOpposite]) {
					[p opposite];
				}
				
				return [p retain];
			}
		}
	}
		
	// raise a power to a power
	else if ([base isKindOfClass:[Power class]] && 
			 (target == base || [base isSubTerm:target]) && 
			 (source == exponent || ([self isRadical] && source == [(Fraction *) exponent denominator]))) {
		
		// multiply the exponents
		Multiplication *m = [[[Multiplication alloc] init: [(Power *) base exponent], exponent, nil] autorelease];
		
		// create the new power and return
		Power *newPower = [[[Power alloc] initWithBase:[(Power *) base base] andExponent:m] autorelease];
		
        // take the opposite if appropriate
        if ([self isOpposite]) {
            [newPower opposite];
        }
        
        return [newPower retain];
	}
	
	// expand powers (C^3 -> c*c*c)
	else if ([self isImmediateSubTerm:source] && [self isImmediateSubTerm:target] &&
			 [exponent isKindOfClass:[Integer class]] && 
             ![base isKindOfClass:[Multiplication class]] &&
			 abs([(Integer *) exponent rawValue]) <= MAX_EXPONENT_EXPANSION) {
		
		Integer *exp  = (Integer *) exponent;
		Integer *one = [[[Integer alloc] initWithInt:1]  autorelease];
		
        Multiplication *newMult = [[[Multiplication alloc] init] autorelease];
        
        // multiply base term n times 
        for (int x = 0; x < abs([exp rawValue]); x++) {
            [newMult appendTerm:base];
        }
        
        // adjust for opposite
        if ([self isOpposite]) {
            [newMult opposite];
        }
        if ([exp rawValue] > 0) {
            
            return [newMult retain];
        }
        else {
            Integer *newExp = [[[Integer alloc] initWithInt:abs([exp rawValue])] autorelease];
            Power *newPower = [[[Power alloc] initWithBase:base andExponent:newExp] autorelease];
            
            return [[Fraction alloc] initWithNum:one andDenom:newPower];
        }
	}
	
	// "distribute" a power across a multiplication - (c*b)^a -> (c^a)*(b^a)
	else if ([self isImmediateSubTerm:source] && [self isImmediateSubTerm:target] &&
			 [base isKindOfClass:[Multiplication class]] && base == target && source == exponent) {
		
		// create the multiplication
		Multiplication *m = [[Multiplication alloc] init];
		
		// add new power terms to multiplication
		Power *p;
		for (Term *t in [(Multiplication *) base termList]) {
			
			p = [[[Power alloc] initWithBase:t andExponent:exponent] autorelease];
			[m appendTerm:p];
		}
        
        if ([self isOpposite]) {
            [m opposite];
        }
		
		return m;
		
	}
	
	// "distribute" a power across a fraction - (c/b)^a -> (c^a)/(b^a)
	else if ([self isImmediateSubTerm:source] && [self isImmediateSubTerm:target] && 
			 [base isKindOfClass:[Fraction class]] && base == target && source == exponent) {
		
		// create the new numerator and denominator
		Power *num   = [[[Power alloc] initWithBase:[(Fraction *) base numerator]   andExponent:exponent] autorelease];
		Power *denom = [[[Power alloc] initWithBase:[(Fraction *) base denominator] andExponent:exponent] autorelease];
        
        // take the opposite if necessary
        if ([self isOpposite]) {
            [num opposite];
        }
		
		// return the fraction
		return [[Fraction alloc] initWithNum:num andDenom:denom];
	}
	
	return nil;
}

- (BOOL) isRadical {
	
	
	return
		[exponent isKindOfClass:[Fraction class]] &&
		[[(Fraction *) exponent numerator] isKindOfClass:[Integer class]] && 
		[(Integer *) [(Fraction *) exponent numerator] rawValue] == 1;

}

- (Term *) copyDecrementingExponent {
	
	// integer exponent
	if ([exponent isKindOfClass:[Integer class]]) {

		// decrement exponent
		Integer *newInt = [[[Integer alloc] initWithInt:[(Integer *) exponent rawValue] - 1] autorelease];
		
		// if exponent is zero, just return the base
		if ([newInt rawValue] == 1) {
			Term *t = [base copy];
			if (isOpposite) {
				[t opposite];
			}
			return t;
			
		}
		// if exponent is zero, just return one
		else if ([newInt rawValue] == 0) {
			return [[Integer alloc] initWithInt:isOpposite ? -1 : 1];
		}
		
		// create new power
		Power *p = [self copy];
		[p setExponent:newInt];
		return p;
	}
	
	// real number exponent
	if ([exponent isKindOfClass:[RealNumber class]]) {
		
		// decrement exponent
		RealNumber *newReal = [[[Integer alloc] initWithInt:[(RealNumber *) exponent rawValue] - 1] autorelease];
		
		// if exponent is zero, just return the base
		if (newReal == 0) {
			return [base copy];
		}
		
		// create new power
		return [[Power alloc] initWithBase:base andExponent:newReal];
	}
	
	// create addition and substract 1 from the exponent
	Addition *newAdd = [[[Addition alloc] init] autorelease];
	[newAdd appendTerm:exponent];
	[newAdd appendTerm:[[[Integer alloc] initWithInt:1] autorelease] Operator: SUBTRACTION_OPERATOR];
	
	// create and return the new power
	return [[Power alloc] initWithBase:base andExponent:newAdd];
}

- (void) setColorRecursively: (UIColor *) c {
	
	[super setColorRecursively:c];
	[base setColorRecursively:c];
	[exponent setColorRecursively:c];
}

- (CGPoint) selectPoint {
	
	// if radical use lower left corner, otherwise lower right corner
	if ([self isRadical]) {
		
		return CGPointMake(2, self.frame.size.height - 2);
	}
	else {
		return CGPointMake(self.frame.size.width - exponent.frame.size.width/2, self.frame.size.height - 2);

	}
}

- (void) dealloc {
	
	[base release];
	[exponent release];
	[super dealloc];
}

@end
