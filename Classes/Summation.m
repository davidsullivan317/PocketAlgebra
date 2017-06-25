//
//  Summation.m
//  TouchAlgebra
//
//  Created by David Sullivan on 2/27/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "Summation.h"
#import "Multiplication.h"
#import "Addition.h"
#import "Fraction.h"

#define SIGMA_SPACING 5

@interface Summation()

@property (nonatomic, retain, getter=_expression, setter=_setExpression:) Term *expression;
@property (nonatomic, retain, getter=_lowerBounds, setter=_setLowerBounds:) Term *lowerBounds;
@property (nonatomic, retain, getter=_upperBounds, setter=_setUpperBounds:) Term *upperBounds;

@end


@implementation Summation

@synthesize indexVariable, expression, upperBounds, lowerBounds;

- (Term *) expression {
	return [self _expression];
}

- (void)   setExpression: (Term *) e {
	
	Term *newExpression = [e copy];
	[self _setExpression:newExpression];
	[newExpression setParentTerm:self];
	[newExpression release];
}

- (Term *) lowerBounds {
	return [self _lowerBounds];
}

- (void)   setLowerBounds: (Term *) lb {
	
	Term *newLB = [lb copy];
	[self _setLowerBounds:newLB];
	[newLB setParentTerm:self];
	[newLB release];
	
	// need to reset the font so the index and bounds fonts gets set
	[self setFont:font];

}

- (Term *) upperBounds {
	return [self _upperBounds];
}

- (void)   setUpperBounds: (Term *) ub {
	
	Term *newUB = [ub copy];
	[self _setUpperBounds:newUB];
	[newUB setParentTerm:self];
	[newUB release];
	
	// need to reset the font so the index and bounds fonts gets set
	[self setFont:font];

}

- (id) init{
	
	return [self initWithTermValue:@"∑"];
}

- (id) initWithIndex: (Variable *) i lower: (Term *) l upper: (Term *) u expression: (Term *) e {
	
	[self init];
	[self setIndexVariable:i];
	[self setUpperBounds:u];
	[self setLowerBounds:l];
	[self setExpression:e];
	
	// need to reset the font so the index and bounds fonts gets set
	[self setFont:font];

	return self;
}

- (NSMutableString *) printStringValue {
	
	NSMutableString *newString = [[[NSMutableString alloc] init] autorelease];
	[newString appendString:termValue];
	[newString appendString:@" "];
	[newString appendString:[indexVariable printStringValue]];
	[newString appendString:@"="];
	[newString appendString:[lowerBounds printStringValue]];
	[newString appendString:@".."];
	[newString appendString:[upperBounds printStringValue]];
	[newString appendString:@" ("];
	[newString appendString:[expression printStringValue]];
	[newString appendString:@")"];

	return newString;	
}	

- (void) renderInView: (UIView *) view atLocation: (CGPoint) loc {
	
	// make the background transparent
	[self setBackgroundColor:[UIColor clearColor]];
	
	// remove all subviews
	for (UIView *v in self.subviews) {
		[v removeFromSuperview];
	}
	
	// render the sigma label and upper bounds
	[upperBounds renderInView:self atLocation:self.frame.origin];
	CGFloat width = 0;
	CGFloat height = 0;
	UILabel *sigma = [[[UILabel alloc] initWithFrame:CGRectMake(0, 
															   upperBounds.frame.size.height/2 + SIGMA_SPACING, 
															   [@"∑" sizeWithFont:font].width, 
															   [@"∑" sizeWithFont:font].height)] autorelease];
	[sigma setBackgroundColor:[UIColor clearColor]];
	[sigma setText:@"∑"];
	[sigma setFont:font];
	width += sigma.frame.size.width;
	height += sigma.frame.size.height;
	[self addSubview:sigma];
	[upperBounds setFrame:CGRectMake(sigma.frame.size.width/2 - upperBounds.frame.size.width/2, 
									 0, 
									 upperBounds.frame.size.width, 
									 upperBounds.frame.size.height)];
	[self addSubview:upperBounds];
	height += upperBounds.frame.size.height;

	// render the index variable and lower bounds
	int subscriptWidth = 0;
	[indexVariable renderInView:self atLocation:CGPointMake(0, upperBounds.frame.size.height + sigma.frame.size.height)];
	[self addSubview:indexVariable];
	subscriptWidth += indexVariable.frame.size.width;
	UILabel *equals = [[[UILabel alloc] initWithFrame:CGRectMake(subscriptWidth, 
															   height, 
															   [@" = " sizeWithFont:[self defaultExponentFont]].width, 
															   [@" = " sizeWithFont:[self defaultExponentFont]].height)] autorelease];
	[equals setBackgroundColor:[UIColor clearColor]];
	[equals setText:@" = "];
	[equals setFont:[self defaultExponentFont]];
	[self addSubview:equals];
	subscriptWidth += equals.frame.size.width;
	[lowerBounds renderInView:self atLocation:CGPointMake(subscriptWidth, height)];
	[self addSubview:lowerBounds];
	
	// render the opening parenthesis
	UILabel *leftParen = [[[UILabel alloc] initWithFrame:CGRectMake(width, 
																upperBounds.frame.size.height,
																[@"(" sizeWithFont:font].width, 
																[@"(" sizeWithFont:font].height)] autorelease];
	[leftParen setBackgroundColor:[UIColor clearColor]];
	[leftParen setText:@"("];
	[leftParen setFont:font];
	[self addSubview:leftParen];
	width += leftParen.frame.size.width;
	
	// render the expression
	[expression renderInView:self atLocation:CGPointMake(width, upperBounds.frame.size.height)];
	[self addSubview:expression];
	width += expression.frame.size.width;

	// render the closing parenthesis
	UILabel *rightParen = [[[UILabel alloc] initWithFrame:CGRectMake(width, 
																   upperBounds.frame.size.height,
																   [@")" sizeWithFont:font].width, 
																   [@")" sizeWithFont:font].height)] autorelease];
	[rightParen setBackgroundColor:[UIColor clearColor]];
	[rightParen setText:@")"];
	[rightParen setFont:font];
	[self addSubview:rightParen];
	width += rightParen.frame.size.width;
	height += MAX(rightParen.frame.size.height, expression.frame.size.height);
	
	// set the frame
	[self setFrame:CGRectMake(loc.x, loc.y, width, height)];
	
	[view addSubview:self];
	
}

- (BOOL) isEquivalent:(Term *) term {
	
	if ([term isKindOfClass:[Summation class]]) {
		
		return upperBounds == [(Summation *) term upperBounds] && lowerBounds == [(Summation *) term lowerBounds] &&
			   [expression isEquivalent:[(Summation *) term expression]];
	}
	return NO;
}

-(BOOL) isImmediateSubTerm: (Term *) term {
	return term == expression;
}

- (BOOL) replaceSubterm: (Term *) oldTerm withTerm: (Term *) newTerm{
	
	if ([expression replaceSubterm:oldTerm withTerm:newTerm]) {
		
		return YES;
	}
	else if (expression == oldTerm) {
		
		[expression release];
		expression = [oldTerm copy];
		[newTerm setParentTerm:self];
		return YES;
	}
	return NO;
}

- (BOOL) isZero{
	
	return [expression isZero];
}

- (void) opposite {
	
	[expression opposite];
}

- (NSUInteger) complexity {
	
	NSUInteger complexity = [indexVariable complexity];
	complexity += [lowerBounds complexity];
	complexity += [upperBounds complexity];
	complexity += [expression complexity];
	return complexity + 1;

}

- (Fraction *) makeSumOfI {
	
	// numerator
	Multiplication *newNum = [[[Multiplication alloc] init:upperBounds, 
							  [[[Addition alloc] init:upperBounds, [[[Integer alloc] initWithInt:1] autorelease], nil] autorelease], 
							  nil] autorelease];
	
	return [[[Fraction alloc] initWithNum:newNum andDenom:[[Integer alloc] initWithInt:2]] autorelease];
	
}

- (Term *) copyReducingWithSubTerm:(Term *) source andSubTerm:(Term *) target {
	
	// bounds must be dropped on expression
	if ((source == lowerBounds ||  source == upperBounds) && (expression == target || [expression isSubTerm:target])) { 
		
		// lower bounds is 1
		if ([lowerBounds isKindOfClass:[Integer class]] && [(Integer *) lowerBounds rawValue] == 1) { 
			
			// ∑ i=1..n (i) ==> n*(n+1)/2
			if ([indexVariable isEquivalentIgnoringSign:expression]) {
				Fraction *newTerm = [self makeSumOfI];
				
				// take the opposite of the numerator if expression (i) is negative
				if ([(Variable *) expression isOpposite]) {
					[newTerm opposite];
				}
				
				return [newTerm retain];
			}
			
			// ∑ i=1..n (a*i) ==> a*n*(n+1)/2
			else if ([indexVariable isEquivalentIgnoringSign:target] && 
					 [expression isKindOfClass:[Multiplication class]] && 
					 [target parentTerm] == expression) {
				
				Multiplication *newMult = [(Multiplication *) [(Multiplication *) expression copyReplacingTerm:target withTerm:[self makeSumOfI]] autorelease]; 

				// take the opposite of the numerator if expression (i) is negative
				if ([(Variable *) target isOpposite]) {
					[newMult opposite];
				}
				
				return [newMult retain];
			}
		}
	}
	return nil;
}

- (id) copyWithZone:(NSZone *) zone {
	
	Summation *newTerm = [[Summation alloc] initWithIndex:indexVariable lower:lowerBounds upper:upperBounds expression:expression];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:nil];
	[newTerm setColor:color];
	[newTerm setFont:font];
	return newTerm;
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	
	[super encodeWithCoder:coder];
	[coder encodeObject:indexVariable forKey:@"indexVariable"];
	[coder encodeObject:lowerBounds forKey:@"lowerBounds"];
	[coder encodeObject:upperBounds forKey:@"upperBounds"];
	[coder encodeObject:expression  forKey:@"expression"];
	
}

- (id) initWithCoder:(NSCoder *)coder { 
	
	// Init first.
	if (self = [super initWithCoder:coder]) {
		
		indexVariable = [[coder decodeObjectForKey:@"indexVariable"] retain];
		lowerBounds = [[coder decodeObjectForKey:@"lowerBounds"] retain];
		upperBounds = [[coder decodeObjectForKey:@"upperBounds"] retain];
		expression = [[coder decodeObjectForKey:@"expression"] retain];
	}
	
	return self;
}



- (void) setFont: (UIFont *) f {
	
	[super setFont:f];
	
	// map fonts for index and bounds
	[expression setFont:f];
	[upperBounds setFont:[self defaultExponentFont]];
	[lowerBounds setFont:[self defaultExponentFont]];
	[indexVariable setFont:[self defaultExponentFont]];
	
}

- (void) setColorRecursively: (UIColor *) c {
	
	[super setColorRecursively:c];
	[indexVariable setColorRecursively:c];
	[lowerBounds setColorRecursively:c];
	[upperBounds setColorRecursively:c];
	[expression setColorRecursively:c];
}

- (void) dealloc {
	
	[indexVariable release];
	[expression release];
	[super dealloc];
}

@end
