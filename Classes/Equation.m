//
//  Equation.m
//  TouchAlgebra
//
//  Created by David Sullivan on 1/17/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "Equation.h"
#import "Addition.h"
#import "Multiplication.h"
#import "Fraction.h"
#import "Integer.h"

@interface Equation()

@property (nonatomic, retain, getter=_LHS, setter=_setLHS:) Term *LHS;
@property (nonatomic, retain, getter=_RHS, setter=_setRHS:) Term	*RHS;

@end


@implementation Equation

@synthesize LHS, RHS;

- (id) initWithLHS: (Term *) lhs andRHS: (Term *) rhs {
	
	if (self = [self initWithTermValue:@"="]) {
		[self setLHS:lhs];
		[self setRHS:rhs];
		
		// set a default rendering base
		renderingBase = [super renderingBase];

	}
	
	return self;
}

- (Term *) LHS {
	return [self _LHS];
}

- (void)   setLHS: (Term *) lhs {
	
	Term *newLHS = [lhs	 copy];
	[self _setLHS:newLHS];
	[newLHS setParentTerm:self];
	[newLHS release];
}

- (Term *) RHS {
	
	return [self _RHS];
}

- (void)   setRHS: (Term *) rhs {
	
	Term *newRHS = [rhs copy];
	[self _setRHS:newRHS];
	[newRHS setParentTerm:self];
	[newRHS release];
}

// initialize with a string value - this is the designated initializer
- (id) initWithTermValue:(NSString*) someStringValue {
	
	if (self = [super initWithTermValue:@"="]) {
		simpleTerm = NO;
		parentTerm = nil;
	}
	
	return self;
}

// default initialization calls designated initializer
- (id) init{
	
	return [self initWithTermValue:@"="];
}

- (NSMutableString *) printStringValue {
	
	NSMutableString *newString = [[[NSMutableString alloc] init] autorelease];
	
	[newString appendString:[LHS printStringValue]];
	[newString appendString:@" = "];
	[newString appendString:[RHS printStringValue]];
	
	return newString;	
}	

- (void) renderInView: (UIView *) view atLocation: (CGPoint) loc {
	
	// make the background transparent
	[self setBackgroundColor:[UIColor clearColor]];
	
	// remove all subviews
	for (UIView *v in self.subviews) {
		[v removeFromSuperview];
	}
	
	// render the LHS & RHS
	[LHS renderInView:self atLocation:self.frame.origin];
	[RHS renderInView:self atLocation:self.frame.origin];
	
	// computer the rendering base and max descender
	renderingBase = MAX([LHS renderingBase], [RHS renderingBase]);
	CGFloat maxDescender = MAX(LHS.frame.size.height - [LHS renderingBase], RHS.frame.size.height - [RHS renderingBase]);
	
	// create and render the equality label
	NSString *equalityString = [[[NSString alloc] initWithString:@" = "] autorelease];
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(LHS.bounds.size.width, 
															      renderingBase - [font ascender], 
																  [equalityString sizeWithFont:font].width, 
																  [equalityString sizeWithFont:font].height)] autorelease];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextColor:color];
	[label setText:equalityString];
	[label setFont:font];
	[self  addSubview:label];

	// move the LHS and RHS
	[LHS setFrame:CGRectMake(0, 
							 renderingBase - [LHS renderingBase],
							 LHS.frame.size.width, 
							 LHS.frame.size.height)];
	[RHS setFrame:CGRectMake(LHS.bounds.size.width + label.bounds.size.width, 
							 renderingBase - [RHS renderingBase],
							 RHS.frame.size.width, 
							 RHS.frame.size.height)];
	
	
	// set the my frame
	[self setFrame:CGRectMake(loc.x, 
							  loc.y, 
							  LHS.bounds.size.width + label.bounds.size.width + RHS.bounds.size.width, 
							  renderingBase + maxDescender)];
	
	
	[view addSubview:self];
}

- (CGFloat) renderingBase {
	
	return renderingBase;
}

- (BOOL) isEquivalent:(Term *) term {
	
	if ([term isKindOfClass:[Equation class]]) {
		 
		return [LHS isEquivalent:[(Equation *) term LHS]] && [RHS isEquivalent:[(Equation *) term RHS]];
	}
	return NO;
}

// is this term a subterm?
-(BOOL) isSubTerm:(Term *) term {
	
	if (term == LHS || term == RHS) {
		return YES;
	}
	else {
		if ([LHS isSubTerm:term]) {
			return YES;
		}
		else if ([RHS isSubTerm:term]){
			return YES;
		}
	}

	return NO;
	
}

-(BOOL) isImmediateSubTerm: (Term *) term {
	return term == LHS || term == RHS;
}

// replace a subterm. Returns YES if the old term was found and replaced
- (BOOL) replaceSubterm: (Term *) oldTerm withTerm: (Term *) newTerm{

	if ([LHS replaceSubterm:oldTerm withTerm:newTerm]) {
		
		return YES;
	}
	else if ([RHS replaceSubterm:oldTerm withTerm:newTerm]){
		
		return YES;
	}
	else if (LHS == oldTerm) {
		
		[self setLHS:newTerm];
		[newTerm setParentTerm:self];
		return YES;
		
	} else if (RHS == oldTerm){
		
		[self setRHS:newTerm];
		[newTerm setParentTerm:self];
		return YES;
	}
	return NO;
	
}

- (BOOL) isZero{
	
	// can an equation = 0?
	return NO;
}

- (void) opposite {
	
	// negating an equation?
}

- (NSUInteger) complexity {
	
	NSUInteger complexity = [LHS complexity];
	complexity += [RHS complexity];
	return complexity + 1;
}

// an equation cannot have a parent term
- (void) setParentTerm:(Term *) t {
	
	if (t) {
		NSException *exception = [NSException exceptionWithName:@"TermException" 
														 reason:@"An equation cannot have a parent term" 
													   userInfo:nil];
		@throw exception;
		
	}
	[super setParentTerm:t];
}

- (Term *) copyReducingWithSubTerm:(Term *) source andSubTerm:(Term *) target {
	
	// create a new equation
	Equation *newEquation = [[[Equation alloc] init] autorelease];

	// set the source and target sides
	BOOL	 sourceIsLHS = (source == LHS || [LHS isSubTerm:source]);
	Term *sourceSide;
	Term *targetSide;
	if (sourceIsLHS) {
		sourceSide = LHS;
		targetSide = RHS;
	}
	else {
		sourceSide = RHS;
		targetSide = LHS;
	}
	
	// move LHS/RHS to the other side of the equation
	if (sourceSide == source) {
		
		// if either side is zero just swap the sides
		if (([LHS isKindOfClass:[Number class]] && [LHS isZero]) || ([RHS isKindOfClass:[Number class]] && [RHS isZero])) {
			return [[Equation alloc] initWithLHS:RHS andRHS:LHS];
		}
		
		// create the new equation 
		Addition *newTargetSide = [[[Addition alloc] init:targetSide, nil] autorelease];;
		[newTargetSide appendTerm:sourceSide Operator:SUBTRACTION_OPERATOR];
		if (sourceIsLHS) {
			return [[Equation alloc] initWithLHS:[[[Integer alloc] initWithInt:0] autorelease] andRHS:newTargetSide];
		}
		else {
			return [[Equation alloc] initWithLHS:newTargetSide andRHS:[[[Integer alloc] initWithInt:0] autorelease]];
		}
	}
	
	// move an addend from one side of the equation to the other
	if ([sourceSide isKindOfClass:[Addition class]] &&  [source parentTerm] == sourceSide) {
		
		// don't move zero
		if ([source isKindOfClass:[Number class]] && [source isZero]) {
			return nil;
		}
		
		
		// determine if we need to add or subtract the new term from the target side
		int addorsubtract = [(Addition *) sourceSide getOperatorAtIndex:[(Addition *) sourceSide indexOfTerm:source]];
		if (addorsubtract == SUBTRACTION_OPERATOR) {
			addorsubtract = ADDITION_OPERATOR;
		}
		else {
			addorsubtract = SUBTRACTION_OPERATOR;
		}
		
		// the new addend
		Term *newAddend = [[source copy] autorelease];
		
		// add the new term to the target side
		if ([targetSide isKindOfClass:[Addition class]]) {
			
			Addition *newTargetSide = [[targetSide copy] autorelease];
			[newTargetSide appendTerm:newAddend Operator: addorsubtract];
			if (sourceIsLHS) {
				[newEquation setRHS:newTargetSide];
			}
			else {
				[newEquation setLHS:newTargetSide];
			}

		}
		// target side is zero
		else if ([targetSide isKindOfClass:[Number class]] && [targetSide isZero]) {

			// if source was being subtracted, take the opposite of the term being added to the target side
			if (addorsubtract == SUBTRACTION_OPERATOR) {
				
				[newAddend opposite];
			}
			
			if (sourceIsLHS) {
				[newEquation setRHS:newAddend];
			}
			else {
				[newEquation setLHS:newAddend];
			}
		}

		else {
			// target side is now an addition
			Addition *a = [[[Addition alloc] init: targetSide, source, nil] autorelease];
			[a setOperator:addorsubtract atIndex:1];
			if (sourceIsLHS) {
				[newEquation setRHS:a];
			}
			else {
				[newEquation setLHS:a];
			}

		}
		
		// remove addend from source side
		if ([(Addition *) sourceSide count] > 2) {
			
			// create new source side
			Term *newSourceSide = [[(Addition *) sourceSide copyRemovingTerm:source] autorelease];

			if (sourceIsLHS) {
				[newEquation setLHS:newSourceSide];
			}
			else {
				[newEquation setRHS:newSourceSide];
			}
		}
		else {
			// one one term remaining - copy the remaining term adjusting for subtraction if necessary
			Addition *newSourceSide = [[sourceSide copy] autorelease];
			if ([(Addition *) sourceSide getOperatorAtIndex:1] == SUBTRACTION_OPERATOR) {
				[[newSourceSide termAtIndex:1] opposite];
			}
			[(Addition *) newSourceSide removeTermAtIndex:[(Addition *) sourceSide indexOfTerm:source]];
			Term *temp = [[[newSourceSide termAtIndex:0] copy] autorelease];
			if (sourceIsLHS) {
				[newEquation setLHS:temp];
			}
			else {
				[newEquation setRHS:temp];
			}

		}
		
		return [newEquation retain];
	}
	
	// divide both sides of the equation by a multiplicand in the source side
	if ([sourceSide isKindOfClass:[Multiplication class]] && 
		[source parentTerm] == sourceSide) {
		
		// source cannot be zero
		if ([source isZero]) {
			return nil;
		}
		
		// the new LHS and RHS
		Multiplication *newSourceSide;
		Fraction *newTargetSide;
		
		// target side already a fraction - multiply to denominator
		if ([targetSide isKindOfClass:[Fraction class]]) {
			
			newTargetSide = [(Fraction *) [targetSide copy] autorelease];
			Term *denom = [newTargetSide denominator];
			
			// denominator is already a multiplication
			if ([denom isKindOfClass:[Multiplication class]]) {
				
				[(Multiplication *) denom appendTerm:source];
			}
			else {
				// denominator is now a multiplication
				Multiplication *m = [[[Multiplication alloc] init:denom, source, nil] autorelease];
				[newTargetSide setDenominator:m];
			}
		}
		else {
			
			// target side is now a fraction
			newTargetSide = [[[Fraction alloc] initWithNum:targetSide andDenom:source] autorelease];
		}
		
		// set the target side
		if (sourceIsLHS) {
			[newEquation setRHS:newTargetSide];
		}
		else {
			[newEquation setLHS:newTargetSide];
		}

		
		// remove multiplicand from source side
		newSourceSide = [[sourceSide copy] autorelease];
		[newSourceSide removeTermAtIndex:[(Multiplication *) sourceSide indexOfTerm:source]];
		
		// if only one term left, source side is that term
		if ([newSourceSide count] == 1) {
			
			if (sourceIsLHS) {
				[newEquation setLHS:[newSourceSide termAtIndex:0]];
			}
			else {
				[newEquation setRHS:[newSourceSide termAtIndex:0]];
			}
		}
		else {
			if (sourceIsLHS) {
				[newEquation setLHS:newSourceSide];
			}
			else {
				[newEquation setRHS:newSourceSide];
			}
		}
		
		return [newEquation retain];
	}
		
	// multiply both sides of the equation by a fraction's denominator
	if ([sourceSide isKindOfClass:[Fraction class]] && [(Fraction *)sourceSide denominator] == source) {
		
		// set the source and target sides
		Multiplication	*newTargetSide;
		if (sourceIsLHS) {
			newTargetSide = [[[Multiplication alloc] init:RHS, [(Fraction *) LHS denominator], nil] autorelease];
			
			// create the new equation and return
			return [[Equation alloc] initWithLHS:[(Fraction *) LHS numerator] andRHS:newTargetSide];
		}
		else {
			newTargetSide = [[[Multiplication alloc] init:LHS, [(Fraction *) RHS denominator], nil] autorelease];

			// create the new equation and return
			return [[Equation alloc] initWithLHS:newTargetSide andRHS:[(Fraction *) RHS numerator] ];
		}
	}
	
	// multiply both sides of the equation by a fraction's denominator where the fraction is a multiplicand
	if ([sourceSide isKindOfClass:[Multiplication class]] && 
		[[source parentTerm] isKindOfClass:[Fraction class]] && 
		[[source parentTerm] parentTerm] == sourceSide &&
		[(Fraction *) [source parentTerm] denominator] == source) {
		
		// set the source and target sides
		Multiplication	*newTargetSide;
		if (sourceIsLHS) {
			newTargetSide = [[[Multiplication alloc] init:RHS, source, nil] autorelease];
			
			// create the new equation and return
			return [[Equation alloc] initWithLHS:[[(Multiplication *) sourceSide copyReplacingTerm:[source parentTerm] 
																						 withTerm:[[[(Fraction *) [source parentTerm] numerator] copy] autorelease]] autorelease]
										  andRHS:newTargetSide];
		}
		else {
			newTargetSide = [[[Multiplication alloc] init:LHS, source, nil] autorelease];
			
			// create the new equation and return
			return [[Equation alloc] initWithLHS:newTargetSide
										  andRHS:[[(Multiplication *) sourceSide copyReplacingTerm:[source parentTerm] 
																						 withTerm:[[[(Fraction *) [source parentTerm] numerator] copy] autorelease]] autorelease]];
		}
	}
	
	// multiply both sides of the equation by a multiplicand in the fraction's denominator
	if ([sourceSide isKindOfClass:[Fraction class]] && 
		[[(Fraction *)sourceSide denominator] isKindOfClass:[Multiplication class]] && 
		[(Fraction *)sourceSide denominator] == [source parentTerm]) {
		
		// convenience variables
		Fraction *frac;
		Multiplication	*newTargetSide;
		Fraction        *newSourceSide;
		
		if ([LHS isSubTerm:source]) {

			frac = (Fraction *) LHS;
			
			newTargetSide  = [[[Multiplication alloc] init:RHS, source, nil] autorelease];
			Term *newDenom = [[(Multiplication *) [frac denominator] copyRemovingTerm:source] autorelease];
			newSourceSide  = [[[Fraction alloc] initWithNum:[frac numerator] andDenom:newDenom] autorelease];
			
			// create the new equation and return
			return [[Equation alloc] initWithLHS:newSourceSide andRHS:newTargetSide];
		}
		else {
			
			frac = (Fraction *) RHS;
			
			newTargetSide  = [[[Multiplication alloc] init:LHS, source, nil] autorelease];
			Term *newDenom = [[(Multiplication *) [frac denominator] copyRemovingTerm:source] autorelease];
			newSourceSide  = [[[Fraction alloc] initWithNum:[frac numerator] andDenom:newDenom] autorelease];
			
			// create the new equation and return
			return [[Equation alloc] initWithLHS:newTargetSide andRHS:newSourceSide];
		}
	}
		
	// divide both sides of the equation by a multiplicand in the fraction's numerator
	if ([sourceSide isKindOfClass:[Fraction class]] && 
		[[(Fraction *)sourceSide numerator] isKindOfClass:[Multiplication class]] && 
		[(Fraction *)sourceSide numerator] == [source parentTerm]) {
		
		// convenience variables
		Fraction *frac;
		Multiplication	*newTargetSide;
		Fraction        *newSourceSide;
		
		if ([LHS isSubTerm:source]) {
			
			frac = (Fraction *) LHS;
			
			newTargetSide  = [[[Fraction alloc] initWithNum:RHS andDenom:source] autorelease];
			Term *newNum   = [[(Multiplication *) [frac numerator] copyRemovingTerm:source] autorelease];
			newSourceSide  = [[[Fraction alloc] initWithNum:newNum andDenom:[frac denominator]] autorelease];
			
			// create the new equation and return
			return [[Equation alloc] initWithLHS:newSourceSide andRHS:newTargetSide];
		}
		else {
			
			frac = (Fraction *) RHS;
			
			newTargetSide  = [[[Fraction alloc] initWithNum:LHS andDenom:source] autorelease];
			Term *newNum   = [[(Multiplication *) [frac numerator] copyRemovingTerm:source] autorelease];
			newSourceSide  = [[[Fraction alloc] initWithNum:newNum andDenom:[frac denominator]] autorelease];
			
			// create the new equation and return
			return [[Equation alloc] initWithLHS:newTargetSide andRHS:newSourceSide];
		}
	}
	
	return nil;
}

- (id) copyWithZone:(NSZone *) zone {
	
	Equation *newTerm = [[Equation alloc] initWithTermValue:[self termValue]];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:nil];
	[newTerm setColor:color];
	[newTerm setFont:font];
	
	// copy the LHS and the RHS
	Term *newLHS = [[LHS copyWithZone:zone] autorelease];
	Term *newRHS  = [[RHS copyWithZone:zone] autorelease];
	[newTerm setLHS:newLHS];
	[newTerm setRHS:newRHS];
	
	return newTerm;
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	[super encodeWithCoder:coder];
	[coder encodeObject:LHS forKey:@"LHS"];
	[coder encodeObject:RHS forKey:@"RHS"];
	
}

- (id) initWithCoder:(NSCoder *)coder { 
	
	// Init first.
	if (self = [super initWithCoder:coder]) {
		
		LHS = [[coder decodeObjectForKey:@"LHS"] retain];
		RHS = [[coder decodeObjectForKey:@"RHS"] retain];
	}
	
	return self;
}

- (void) setFont: (UIFont *) f {
	
	[super setFont:f];
	
	// set font for LHS and RHS
	[LHS setFont:f];
	[RHS setFont:f];
}

- (void) setColorRecursively: (UIColor *) c {
	
	[super setColorRecursively:c];
	[LHS setColorRecursively:c];
	[RHS setColorRecursively:c];
}

- (CGPoint) selectPoint {
	
	// select equation only via the "=" label subview
	return CGPointMake(-100, -100);
}

- (void) dealloc {
	
	[LHS release];
	[RHS release];
	[super dealloc];
}

@end
