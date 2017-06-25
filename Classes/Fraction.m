//
//  Fraction.m
//  TouchAlgebra
//
//  Created by David Sullivan on 8/14/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "Fraction.h"
#import "Integer.h"
#import "RealNumber.h"
#import "Variable.h"
#import "Multiplication.h"
#import "Addition.h"
#import "Power.h"
#import "Constant.h"


#define FRACTION_VERTICAL_SPACING 20

@interface Fraction()

// needed so we can set our subterm's parent term pointer and still used properties
@property (nonatomic, retain, getter=_numerator,   setter=_setNumerator:)   Term *numerator;
@property (nonatomic, retain, getter=_denominator, setter=_setDenominator:) Term	*denominator;

@end


@implementation Fraction

@synthesize numerator, denominator;

- (Term *) numerator {
	return [self _numerator];
}

- (void)   setNumerator: (Term *) num {
	
	Term *newNum = [num	 copy];
	[self _setNumerator:newNum];
	[newNum setParentTerm:self];
	[newNum release];
}

- (Term *) denominator {
	
	return [self _denominator];
}

- (void)   setDenominator: (Term *) denom {
	
	// the first term cannot be subtracted
	if ([denom isZero]) {
		
		NSException *exception = [NSException exceptionWithName:@"TermException" 
														 reason:@"The denominator of a fraction cannot be zero" 
													   userInfo:nil];
		@throw exception;
	}
	
	Term *newDenom = [denom copy];
	[self _setDenominator:newDenom];
	[newDenom setParentTerm:self];
	[newDenom release];
}

// initialize with a string value - this is the designated initializer
- (id) initWithTermValue:(NSString*) someStringValue {
	
	if (self = [super initWithTermValue:@"/"]) {
		[self setSimpleTerm:NO];
	}
	
	return self;
}

// default initialization calls designated initializer
- (id) init{
	
	return [self initWithTermValue:@"/"];
}

- (id) initWithNum: (Term *) num andDenom: (Term *) denom {
	
	Fraction *f = (Fraction *) [self init];
	[f setNumerator:num];
	[f setDenominator:denom];
	
	return f;
}

- (BOOL) replaceSubterm: (Term *) oldTerm withTerm: (Term *) newTerm {

	if ([numerator replaceSubterm:oldTerm withTerm:newTerm]) {
		return YES;
	}
	else if ([denominator replaceSubterm:oldTerm withTerm:newTerm]){
		return YES;
	}
	else if (numerator == oldTerm) {
		[oldTerm setParentTerm:nil];
		[newTerm setParentTerm:self];
		[self setNumerator:newTerm];
		return YES;
	} 
	else if (denominator == oldTerm){
		[oldTerm setParentTerm:nil];
		[newTerm setParentTerm:self];
		[self setDenominator:newTerm];
		return YES;
	}
	
	return NO;
}

// override printStringValue so it returns (1 + c)/(2 + x), etc.
- (NSMutableString *) printStringValue {
	
	NSMutableString *newString = [[[NSMutableString alloc] init] autorelease];
	
	if ([numerator isSimpleTerm]) {
		[newString appendString:[numerator printStringValue]];
	}
	else {
		[newString appendString:@"("];
		[newString appendString:[numerator printStringValue]];
		[newString appendString:@")"];
	}

	[newString appendString:[self termValue]];

	
	if ([denominator isSimpleTerm]) {
		[newString appendString:[denominator printStringValue]];
	}
	else {
		[newString appendString:@"("];
		[newString appendString:[denominator printStringValue]];
		[newString appendString:@")"];
	}
	
	return newString;
}

- (BOOL) isEquivalent:(Term *) term {
	
	if ([term isKindOfClass:[Fraction class]]) {
		
		// cast term to fraction for simplicty
		Fraction *f = (Fraction *) term;

		return [numerator isEquivalent:[f numerator]] && [denominator isEquivalent:[f denominator]];
	}
	
	return NO;
}

- (void) opposite {
	
	// by default take the opposite of the numerator
	[numerator opposite];
}

- (NSUInteger) complexity {
	
	NSUInteger complexity = [numerator complexity];
	complexity += [denominator complexity];
	return complexity + 1;
}

- (id) copyWithZone:(NSZone *) zone {
	
	Fraction *newTerm = [[Fraction alloc] initWithTermValue:[self termValue]];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:nil];
	[newTerm setColor:color];
	[newTerm setFont:font];
	
	// copy the numerator and denominator
	Term *newNum = [[numerator copyWithZone:zone] autorelease];
	Term *newDenom = [[denominator copyWithZone:zone] autorelease];
	[newTerm setNumerator:newNum];
	[newTerm setDenominator:newDenom];
	
	return newTerm;
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	
	[super encodeWithCoder:coder];
	[coder encodeObject:numerator forKey:@"numerator"];
	[coder encodeObject:denominator forKey:@"denominator"];
	
}

- (id) initWithCoder:(NSCoder *)coder { 
	
	// Init first.
	if (self = [super initWithCoder:coder]) {
		
		numerator = [[coder decodeObjectForKey:@"numerator"] retain];
		denominator = [[coder decodeObjectForKey:@"denominator"] retain];
	}
	
	return self;
}

- (void) setFont: (UIFont *) f {
	
	[super setFont:f];
	
	// set font for numerator & demoninator
	[numerator setFont:f];
	[denominator setFont:f];
}

- (CGFloat) renderingBase {
	
	return numerator.bounds.size.height + FRACTION_VERTICAL_SPACING/2 + [font xHeight]/2;
}

- (void) renderInView: (UIView *) view atLocation: (CGPoint) loc {
	
	#define LINE_OVERLAP 4
	
	// make the background transparent
	[self setBackgroundColor:[UIColor clearColor]];
	
	// remove all subviews
	for (UIView *v in self.subviews) {
		[v removeFromSuperview];
	}
	
	// render the subviews
	[numerator   renderInView:self atLocation:self.frame.origin];
	[denominator renderInView:self atLocation:self.frame.origin];
	
	// compute the height and width
	CGFloat height = numerator.bounds.size.height + denominator.bounds.size.height + FRACTION_VERTICAL_SPACING;
	CGFloat width  = MAX(numerator.bounds.size.width, denominator.bounds.size.width) + LINE_OVERLAP*2;
	
	// set my frame
	[self setFrame:CGRectMake(loc.x, loc.y, width + LINE_OVERLAP*2, height)];
	
	// move the subviews 
	[numerator setFrame:CGRectMake((width - numerator.bounds.size.width)/2 + LINE_OVERLAP, 
									0, 
									numerator.frame.size.width, 
									numerator.frame.size.height)];
	[denominator setFrame:CGRectMake((width - denominator.bounds.size.width)/2 + LINE_OVERLAP, 
									  numerator.bounds.size.height + FRACTION_VERTICAL_SPACING, 
									  denominator.frame.size.width, 
									  denominator.frame.size.height)];
	
	[view addSubview:self];
	[self setNeedsDisplay]; // force the line to draw
}

- (void)drawRect:(CGRect)rect {
	
	[super drawRect:rect];
	
	// get the drawing context
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadow(context, CGSizeMake(3.0f, 3.0f), 5.0f);
	
	// set the line details
	CGContextSetLineWidth(context, 2.0);
	CGContextSetLineCap(context, kCGLineCapRound);
	[color setStroke];
		
	// compute the height of the numerator
	CGFloat height = numerator.bounds.size.height + FRACTION_VERTICAL_SPACING/2;
	
	CGContextMoveToPoint(context, 4, height);
	CGContextAddLineToPoint(context, self.frame.size.width - 4, height);
	CGContextStrokePath(context);
	
}

- (BOOL) termsAreNegativeWhenReduced: (Term *) t1 term2: (Term *) t2 {
	
	BOOL t1IsNeg = ([t1 isKindOfClass:[SymbolicTerm class]] && [(SymbolicTerm *) t1 isOpposite]) ||
				   ([t1 isKindOfClass:[Number class]] && [(Number *) t1 isOpposite]);
	BOOL t2IsNeg = ([t2 isKindOfClass:[SymbolicTerm class]] && [(SymbolicTerm *) t2 isOpposite]) ||
				   ([t2 isKindOfClass:[Number class]] && [(Number *) t2 isOpposite]);
	
	return t1IsNeg ^ t2IsNeg;
}

- (BOOL) term: (Term *) t1 isFactorOf: (Term *) t2 {
	
	if ([t1 isKindOfClass:[Integer class]] && [t2 isKindOfClass:[Integer class]]) {
		
		return ([(Integer *) t2 rawValue] % [(Integer *) t1 rawValue] == 0);
	}
	return NO;
}

- (Term *) copyReducingWithSubTerm:(Term *) source andSubTerm:(Term *) target {
	
	// ignore zero denominators
	if ([denominator isKindOfClass:[Number class]] && [denominator isZero]) {
		return nil;
	}
	
	// numerator is zero
	if ((source == numerator || target == numerator) && 
		[numerator isKindOfClass:[Integer class]] && 
		[(Integer *) numerator rawValue] == 0) {
		
		return [numerator copy];
		
	}
	else if ((source == numerator || target == numerator) &&
			 [numerator isKindOfClass:[RealNumber class]] && 
			 [(RealNumber *) numerator rawValue] == 0) {
		
		return [numerator copy];
		
	}

	// numerator is infinity
	else if ((source == numerator || target == numerator) &&
			 [numerator isEquivalent:[Constant infinity]]){
		
		if (![denominator isEquivalent:[Constant infinity]]) {

			return [numerator copy];
		}
			
		return nil;
	}
	
	// denominator is infinity
	else if ((source == denominator || target == denominator) &&
			 [denominator isEquivalent:[Constant infinity]]){
		
		if (![numerator isEquivalent:[Constant infinity]]) {

			return [[Integer alloc] initWithInt:0];
		}	 
			
		return nil;
	}
	
	// denominator is 1
	else if ((source == numerator || target == numerator) &&
			 [denominator isKindOfClass:[Integer class]] && 
			 [(Integer *) denominator rawValue] == 1) {
		
		return [numerator copy];
		
	}
	else if ((source == numerator || target == numerator) &&
			 [denominator isKindOfClass:[RealNumber class]] && 
			 [(RealNumber *) denominator rawValue] == 1) {
		
		return [numerator copy];
		
	}
	
	// denominator is -1
	else if ((source == numerator || target == numerator) &&
			 ![numerator isKindOfClass:[Power class]] && // can't take the opposite of a power
			 [denominator isKindOfClass:[Integer class]] && 
			 [(Integer *) denominator rawValue] == -1) {
		
		Integer *i = [numerator copy];
		[i opposite];
		return i;
		
	}
	else if ((source == numerator || target == numerator) &&
			 ![numerator isKindOfClass:[Power class]] && // can't take the opposite of a power
			 [denominator isKindOfClass:[RealNumber class]] && 
			 [(RealNumber *) denominator rawValue] == -1) {
		
		RealNumber *r = [numerator copy];
		[r opposite];
		return r;
		
	}
	
	// source and target are in multiplication and/or simple term
	else if ((([self isImmediateSubTerm:source] && [source isSimpleTerm]) || ([source isSimpleTerm] && [[source parentTerm] isKindOfClass:[Multiplication class]] && [self isImmediateSubTerm:[source parentTerm]])) &&
			 (([self isImmediateSubTerm:target] && [target isSimpleTerm]) || ([target isSimpleTerm] && [[target parentTerm] isKindOfClass:[Multiplication class]] && [self isImmediateSubTerm:[target parentTerm]]))
			 ){
		
		// numerator is one - term is inverse of the denominator
		if (([numerator isKindOfClass:[Integer class]] && [(Integer *) numerator rawValue] == 1) || 
			([numerator isKindOfClass:[RealNumber class]] && [(RealNumber *) numerator rawValue] == 1)) {
			
			// create new power
			return [[Power alloc] initWithBase:denominator andExponent:[[[Integer alloc] initWithInt:-1] autorelease]];
		}
		
		BOOL canReduce = NO;
		
		// we will assume source is the numerator and target is the denominator. If not swap.
		if (!(numerator == source || numerator == [source parentTerm])) {
			Term *temp = source;
			source = target;
			target = temp;
		}
		
		// determine reduced terms. nil means remove term
		BOOL needOpposite = NO;
		Term *newSource;
		Term *newTarget;
		
		// terms are equivalent - they reduce to 1
		if ([source isEquivalent:target]) {
			newSource = [[[Integer alloc] initWithInt:1] autorelease];
			newTarget = [[[Integer alloc] initWithInt:1] autorelease];
			canReduce = YES;
		}
		
		// terms are equivalent - they reduce to 1 but we need to take the opposite
		else if([source isEquivalentIgnoringSign:target]) {
			needOpposite = YES;
			newSource = [[[Integer alloc] initWithInt:1] autorelease];
			newTarget = [[[Integer alloc] initWithInt:1] autorelease];
			canReduce = YES;
		}
		
		// integer reduction
		else if ([source isKindOfClass:[Integer class]] && [target isKindOfClass:[Integer class]]) {
			
			// get the integer values for convenience
			int sourceInt = [(Integer *) source rawValue];
			int targetInt = [(Integer *) target rawValue];
			
			// source is a factor of the target
			if ([self term:source isFactorOf:target]){
				
				newSource = [[[Integer alloc] initWithInt:1] autorelease];
				newTarget = [[[Integer alloc] initWithInt:targetInt/sourceInt] autorelease];
				canReduce = YES;
				
				// keep negative sign with original term
				if (sourceInt < 0) {
					[newSource opposite];
					[newTarget opposite];
				}
			}
			
			// target is a factor of the source
			else  if ([self term:target isFactorOf:source]){
				
				newTarget = [[[Integer alloc] initWithInt:1] autorelease];
				newSource = [[[Integer alloc] initWithInt:sourceInt/targetInt] autorelease];
				canReduce = YES;
				
				// keep negative sign with original term
				if (targetInt < 0) {
					[newSource opposite];
					[newTarget opposite];
				}
			}
			
			// source and target can be reduced via GCD
			else if([Term gcdX:sourceInt Y:targetInt] > 1) {
				
				newSource = [[[Integer alloc] initWithInt:sourceInt/[Term gcdX:sourceInt Y:targetInt]] autorelease];
				newTarget = [[[Integer alloc] initWithInt:targetInt/[Term gcdX:sourceInt Y:targetInt]] autorelease];
				canReduce = YES;

			}
		}
		
		// create the numerator and denominator for the new fraction
		if (canReduce) {
			
			Term *newNum;
			Term *newDenom;
			if (source == numerator) {
				newNum = newSource;
			}
			else {
				newNum = [[(Multiplication *) [source parentTerm] copyReplacingTerm:source withTerm:newSource] autorelease];
			}
			if (target == denominator) {
				newDenom = newTarget;
			}
			else {
				newDenom = [[(Multiplication *) [target parentTerm] copyReplacingTerm:target withTerm:newTarget] autorelease];
			}
			
			//clean up and return
			if ([newNum   isKindOfClass:[Integer class]] && ([(Integer *) newNum   rawValue] == 1 ||[(Integer *) newNum   rawValue] == -1) &&
				[newDenom isKindOfClass:[Integer class]] && ([(Integer *) newDenom rawValue] == 1 ||[(Integer *) newDenom rawValue] == -1) 
				) {

				// num and denom are both one, so simplify
				// take the opposite if needed
				if (needOpposite) {
					return [[Integer alloc] initWithInt:-1];					
				}
				else {
					return [[Integer alloc] initWithInt:1];
				}
			}
			else {
				// take the opposite if needed
				if (needOpposite) {
					[newNum opposite];
				}
				
				// if denominator is one, just return the numerator
				if ([newDenom isKindOfClass:[Integer class]] && [(Integer *) newDenom rawValue] == 1) {

					return [newNum retain];
				}
				else {
					return [[Fraction alloc] initWithNum:newNum andDenom:newDenom];
				}
			}		
		}
	}
	
	// reduce powers in fraction
	else if([source isKindOfClass:[Power class]] ||
			[target isKindOfClass:[Power class]] ||
			([[source parentTerm] isKindOfClass:[Power class]] && [(Power *) [source parentTerm] base] == source)||
			([[target parentTerm] isKindOfClass:[Power class]] && [(Power *) [target parentTerm] base] == target)
			) {
		
		// pointers to the base terms in the numerator and denominator
		Term *numBaseTerm;
		Term *denomBaseTerm;
		if (source == numerator || [numerator isSubTerm:source]) {
			
			numBaseTerm = [source isKindOfClass:[Power class]] ? [(Power *) source base] : source;
			denomBaseTerm = [target isKindOfClass:[Power class]] ? [(Power *) target base] : target;
		}
		else {
			numBaseTerm = [target isKindOfClass:[Power class]] ? [(Power *) target base] : target;
			denomBaseTerm = [source isKindOfClass:[Power class]] ? [(Power *) source base] : source;
		}
		
		// base terms must be equal
		if (![numBaseTerm isEquivalent:denomBaseTerm]) {

            // if source is denominator, move the denominator to the numberator by raising to -1
            if (source == denominator) {
                
                Power *p = [[[Power alloc] initWithBase:denominator andExponent:[[[Integer alloc] initWithInt:-1] autorelease]] autorelease];
                
                return [[Multiplication alloc] init:numerator, p, nil];
            }
            else {
             return nil;   
            }
		}
		
		// figure out the "state" of the numerator
		// base        = selected term in numerator is equivalent to the base of the power selected in the denominator
		// baseInMult  = same as "base" but the base is in a multiplication
		// power       = numerator is a power and the base term is the base of that power
		// powerInMult = same as "power" but the power is in a multiplication
		enum  CaseState {
			base, baseInMulti, power, powerInMult, none
		} ;
		enum CaseState numState = none;
		enum CaseState denomState = none;
		
		if ([[numBaseTerm parentTerm] isKindOfClass:[Power class]]) {
			
			if ([numBaseTerm parentTerm] == numerator) {
				numState = power;
			}
			else if ([[[numBaseTerm parentTerm] parentTerm] isKindOfClass:[Multiplication class]] && [[numBaseTerm parentTerm] parentTerm] == numerator) {
				numState = powerInMult;
			}
		}
		else {
			if (numBaseTerm == numerator) {
				numState = base;
			}
			else if ([[numBaseTerm parentTerm] isKindOfClass:[Multiplication class]] && [numBaseTerm parentTerm] == numerator) {
				numState = baseInMulti;
			}
		}
		
		// repeat for denominator 
		if ([[denomBaseTerm parentTerm] isKindOfClass:[Power class]]) {
			
			if ([denomBaseTerm parentTerm] == denominator) {
				denomState = power;
			}
			else if ([[[denomBaseTerm parentTerm] parentTerm] isKindOfClass:[Multiplication class]] && [[denomBaseTerm parentTerm] parentTerm] == denominator) {
				denomState = powerInMult;
			}
		}
		else {
			if (denomBaseTerm == denominator) {
				denomState = base;
			}
			else if ([[denomBaseTerm parentTerm] isKindOfClass:[Multiplication class]] && [denomBaseTerm parentTerm] == denominator) {
				denomState = baseInMulti;
			}
		}
		
		// both numerator and denominator term states must be valid
		if (numState == none || denomState == none) {
			return nil;
		}
		
		// Case 1: base/power 
		if (numState == base && denomState == power) {
			
			Addition *exp = [[[Addition alloc] init:[[[Integer alloc] initWithInt:1] autorelease], nil] autorelease];
			[exp appendTerm:[(Power *) [denomBaseTerm parentTerm] exponent] Operator:SUBTRACTION_OPERATOR];
			
			return [[Power alloc] initWithBase:numBaseTerm andExponent:exp];
		}

		// Case 2: power/base 
		if (numState == power && denomState == base) {
			
			Addition *exp = [[[Addition alloc] init:[(Power *) [numBaseTerm parentTerm] exponent], nil] autorelease];
			[exp appendTerm:[[[Integer alloc] initWithInt:1] autorelease] Operator:SUBTRACTION_OPERATOR];
			
			return [[Power alloc] initWithBase:numBaseTerm andExponent:exp];
		}

		// Case 3: baseInMulti/power 
		if (numState == baseInMulti && denomState == power) {
			
			Addition *exp = [[[Addition alloc] init:[[[Integer alloc] initWithInt:1] autorelease], nil] autorelease];
			[exp appendTerm:[(Power *) [denomBaseTerm parentTerm] exponent] Operator:SUBTRACTION_OPERATOR];
			
			Power *newPower = [[[Power alloc] initWithBase:denomBaseTerm andExponent:exp] autorelease];
			
			return [(Multiplication *) numerator copyReplacingTerm:numBaseTerm withTerm:newPower];
		}
		
		// Case 4: power/baseInMulti
		if (numState == power && denomState == baseInMulti) {
			
			Addition *exp = [[[Addition alloc] init:[(Power *) [numBaseTerm parentTerm] exponent], nil] autorelease];
			[exp appendTerm:[[[Integer alloc] initWithInt:1] autorelease] Operator:SUBTRACTION_OPERATOR];
			
			Power *newNum =  [[[Power alloc] initWithBase:numBaseTerm andExponent:exp] autorelease];
			
			Term *newDenom = [[(Multiplication *) denominator copyRemovingTerm:denomBaseTerm] autorelease];
			
			return [[Fraction alloc] initWithNum:newNum andDenom:newDenom];
		}
		
		// Case 5: power/power
		if (numState == power && denomState == power) {
			
			Addition *exp = [[[Addition alloc] init:[(Power *) [numBaseTerm parentTerm] exponent], nil] autorelease];
			[exp appendTerm:[(Power *) [denomBaseTerm parentTerm] exponent] Operator:SUBTRACTION_OPERATOR];
			
			return [[Power alloc] initWithBase:numBaseTerm andExponent:exp];
		}
				
		// Case 6: powerInMulti/base
		if (numState == powerInMult && denomState == base) {
			
			Addition *exp = [[[Addition alloc] init:[(Power *) [numBaseTerm parentTerm] exponent], nil] autorelease];
			[exp appendTerm:[[[Integer alloc] initWithInt:1] autorelease] Operator:SUBTRACTION_OPERATOR];
			
			Power *newPower = [[[Power alloc] initWithBase:numBaseTerm andExponent:exp] autorelease];
			
			return [(Multiplication *) numerator copyReplacingTerm:[numBaseTerm parentTerm] withTerm:newPower];
		}
		
		// Case 7: base/powerInMulti
		if (numState == base && denomState == powerInMult) {
			
			Addition *exp = [[[Addition alloc] init:[[[Integer alloc] initWithInt:1] autorelease], nil] autorelease];
			[exp appendTerm:[(Power *) [denomBaseTerm parentTerm] exponent] Operator:SUBTRACTION_OPERATOR];
			
			Power *newNum = [[[Power alloc] initWithBase:numBaseTerm andExponent:exp] autorelease];

			Term *newDenom = [[(Multiplication *) denominator copyRemovingTerm:[denomBaseTerm parentTerm]] autorelease];
			
			return [[Fraction alloc] initWithNum:newNum andDenom:newDenom];
		}
				
		// Case 8: powerInMulti/baseInMulti
		if (numState == powerInMult && denomState == baseInMulti) {
			
			Addition *exp = [[[Addition alloc] init:[(Power *) [numBaseTerm parentTerm] exponent], nil] autorelease];
			[exp appendTerm:[[[Integer alloc] initWithInt:1] autorelease] Operator:SUBTRACTION_OPERATOR];
			
			Power *newPower = [[[Power alloc] initWithBase:numBaseTerm andExponent:exp] autorelease];
			
			Term *newNum = [[(Multiplication *) numerator copyReplacingTerm:[numBaseTerm parentTerm] withTerm:newPower] autorelease];
			
			Term *newDenom = [[(Multiplication *) denominator copyRemovingTerm:denomBaseTerm] autorelease];
			
			return [[Fraction alloc] initWithNum:newNum andDenom:newDenom];
		}
		
		// Case 9: baseInMulti/powerInMulti
		if (numState == baseInMulti && denomState == powerInMult) {
			
			Addition *exp = [[[Addition alloc] init:[[[Integer alloc] initWithInt:1] autorelease], nil] autorelease];
			[exp appendTerm:[(Power *) [denomBaseTerm parentTerm] exponent] Operator:SUBTRACTION_OPERATOR];
			
			Power *newPower = [[[Power alloc] initWithBase:numBaseTerm andExponent:exp] autorelease];
			
			Term *newNum = [[(Multiplication *) numerator copyReplacingTerm:numBaseTerm withTerm:newPower] autorelease];
			
			Term *newDenom = [[(Multiplication *) denominator copyRemovingTerm:[denomBaseTerm parentTerm]] autorelease];
			
			return [[Fraction alloc] initWithNum:newNum andDenom:newDenom];
		}
		
		// Case 10: powerInMulti/power
		if (numState == powerInMult && denomState == power) {
			
			Addition *exp = [[[Addition alloc] init:[(Power *) [numBaseTerm parentTerm] exponent], nil] autorelease];
			[exp appendTerm:[(Power *) [denomBaseTerm parentTerm] exponent] Operator:SUBTRACTION_OPERATOR];
			
			Power *newPower = [[[Power alloc] initWithBase:numBaseTerm andExponent:exp] autorelease];
			
			return [(Multiplication *) numerator copyReplacingTerm:[numBaseTerm parentTerm] withTerm:newPower];
		}

		// Case 11: power/powerInMulti
		if (numState == power && denomState == powerInMult) {
			
			Addition *exp = [[[Addition alloc] init:[(Power *) [numBaseTerm parentTerm] exponent], nil] autorelease];
			[exp appendTerm:[(Power *) [denomBaseTerm parentTerm] exponent] Operator:SUBTRACTION_OPERATOR];
			
			Power *newPower = [[[Power alloc] initWithBase:numBaseTerm andExponent:exp] autorelease];
			
			Term *newDenom = [[(Multiplication *) denominator copyRemovingTerm:[denomBaseTerm parentTerm]] autorelease];
			
			return [[Fraction alloc] initWithNum:newPower andDenom:newDenom];
		}
		
		// Case 12: powerInMult/powerInMulti
		if (numState == powerInMult && denomState == powerInMult) {
			
			Addition *exp = [[[Addition alloc] init:[(Power *) [numBaseTerm parentTerm] exponent], nil] autorelease];
			[exp appendTerm:[(Power *) [denomBaseTerm parentTerm] exponent] Operator:SUBTRACTION_OPERATOR];
			
			Power *newPower = [[[Power alloc] initWithBase:numBaseTerm andExponent:exp] autorelease];
			
			Term *newNum = [[(Multiplication *) numerator copyReplacingTerm:[numBaseTerm parentTerm] withTerm:newPower] autorelease];
			
			Term *newDenom = [[(Multiplication *) denominator copyRemovingTerm:[denomBaseTerm parentTerm]] autorelease];
			
			return [[Fraction alloc] initWithNum:newNum andDenom:newDenom];
		}		
        
        // if source is denominator, move the denominator to the numberator by raising to -1
        if (source == denominator) {
            
            Power *p = [[[Power alloc] initWithBase:denominator andExponent:[[[Integer alloc] initWithInt:-1] autorelease]] autorelease];
            
            return [[Multiplication alloc] init:numerator, p, nil];
        }
	}
	
	// source and target are numerator/denominator
	else if ([self isImmediateSubTerm:source] && [self isImmediateSubTerm:target]) {
		
		// numerator and denominator are equivelent - return one
		if ([numerator isEquivalent:denominator]) {
			return [[Integer alloc] initWithInt:1];
		}
		
		// numerator is one - term is inverse of the denominator
		else if (([numerator isKindOfClass:[Integer class]] && [(Integer *) numerator rawValue] == 1) || 
				 ([numerator isKindOfClass:[RealNumber class]] && [(RealNumber *) numerator rawValue] == 1)) {
			
			// create new power
			return [[Power alloc] initWithBase:denominator andExponent:[[[Integer alloc] initWithInt:-1] autorelease]];
		}
		
		// numerator is addition - create fraction for each term in the addition
		else if ([numerator isKindOfClass:[Addition class]]){
			
			Addition *a = [[[Addition alloc] init] autorelease];
			Fraction *f;
			for (int x = 0; x < [(Addition *) numerator count]; x++) {
				f = [[[Fraction alloc] init] autorelease];
				[f setNumerator:[(Addition *) numerator termAtIndex:x]];
				[f setDenominator:denominator];
				[a appendTerm:f];
				[a setOperator:[(Addition *) numerator getOperatorAtIndex:x] atIndex:x];
			}
			
			return [a retain];
		}
		
		// if numerator and denominator are fractions, invert and multiply
		else if ([numerator isKindOfClass:[Fraction class]] && [denominator isKindOfClass:[Fraction class]]) {
			
			// create the numerator
			Multiplication *newnum	 = [[[Multiplication alloc] init] autorelease];
			[newnum appendTerm:[(Fraction *)numerator numerator]];
			[newnum appendTerm:[(Fraction *)denominator denominator]];
			
			// create the demoninator
			Multiplication *newdenom	 = [[[Multiplication alloc] init] autorelease];
			[newdenom appendTerm:[(Fraction *)numerator denominator]];
			[newdenom appendTerm:[(Fraction *)denominator numerator]];
			
			// create the new fraction
			Fraction *newTerm = [[[Fraction alloc] initWithNum:newnum andDenom:newdenom] autorelease];
			
			 // clean up and return
			return [newTerm retain];
			
		}
		
		// numerator (only) is fraction - move denominator to the numerator's denominator [(a/b)/c -> a/b*c)]
		else if ([numerator isKindOfClass:[Fraction class]]) {
			
			// create the new denominator
			Multiplication *m;
			if ([[(Fraction *) numerator denominator] isKindOfClass:[Multiplication class]]) {
				
				m = [(Multiplication *) [[(Fraction *) numerator denominator] copy] autorelease];
				[m appendTerm:denominator];
			}
			else {
				// create new multiplication for denominator
				m  = [[[Multiplication alloc] init: [(Fraction *)numerator denominator], denominator, nil] autorelease];
			}
			
			// create the new fraction
			return [[Fraction alloc] initWithNum:[(Fraction *) numerator numerator] andDenom:m];
		}
		
		// denominator (only) is fraction
		else if ([denominator isKindOfClass:[Fraction class]]) {
			
			// create the new numerator
			Multiplication *m;
			if ([numerator isKindOfClass:[Multiplication class]]) {
				
				m = [(Multiplication *) [numerator copy] autorelease];
				[m appendTerm:[(Fraction *) denominator denominator]];
			}
			else {
				// create new multiplication for numerator
				m  = [[[Multiplication alloc] init: numerator, [(Fraction *)denominator denominator], nil] autorelease];
			}
			
			// create the new fraction
			return [[Fraction alloc] initWithNum:m andDenom:[(Fraction *) denominator numerator]];
		}
        
        // if source is denominator, move the denominator to the numberator by raising to -1
        else if (source == denominator) {
            
            Power *p = [[[Power alloc] initWithBase:denominator andExponent:[[[Integer alloc] initWithInt:-1] autorelease]] autorelease];
                        
            return [[Multiplication alloc] init:numerator, p, nil];
        }
	}
			
	// source and target are equivalent and may be in multiplicand
	else if ([source isEquivalent:target] && 
			 ((source == numerator || [[source parentTerm] isKindOfClass:[Multiplication class]] && [source parentTerm] == numerator) ||
			  (source == denominator || [[source parentTerm] isKindOfClass:[Multiplication class]] && [source parentTerm] == denominator)) &&
			 ((target == numerator || [[target parentTerm] isKindOfClass:[Multiplication class]] && [target parentTerm] == numerator) ||
			  (target == denominator || [[target parentTerm] isKindOfClass:[Multiplication class]] && [target parentTerm] == denominator)) 
			 ) {
		
		// we will assume source is the numerator and target is the denominator. If not swap.
		if (!(numerator == source || numerator == [source parentTerm])) {
			Term *temp = source;
			source = target;
			target = temp;
		}
		
		// case 1: source is numerator and target is multiplicand in denominator
		if (source == numerator && [[target parentTerm] isKindOfClass:[Multiplication class]]) {
			
			Integer *newNum   = [[[Integer alloc] initWithInt:1] autorelease];
			Term    *newDenom = [[(Multiplication *) denominator copyRemovingTerm:target] autorelease];
			return [[Fraction alloc] initWithNum:newNum andDenom:newDenom];
		}
		
		// case 2: source is multiplicand in numerator and target is denominator
		if ([[source parentTerm] isKindOfClass:[Multiplication class]] && target == denominator) {
			
			return [(Multiplication *) numerator copyRemovingTerm:source];
		}
		
		// case 3: source is multiplicand in numerator and target is multiplicand in denominator
		if ([[source parentTerm] isKindOfClass:[Multiplication class]] && [[target parentTerm] isKindOfClass:[Multiplication class]]) {
			
			Integer *newNum   = [[(Multiplication *) numerator   copyRemovingTerm:source] autorelease];
			Term    *newDenom = [[(Multiplication *) denominator copyRemovingTerm:target] autorelease];
			return [[Fraction alloc] initWithNum:newNum andDenom:newDenom];
		}
	}
	
	return nil;
}

- (void) setColorRecursively: (UIColor *) c {
	
	[super setColorRecursively:c];
	[numerator setColorRecursively:c];
	[denominator setColorRecursively:c];
}

- (void) dealloc {

	[numerator autorelease];
	[denominator autorelease];
	[super dealloc];
}

@end
