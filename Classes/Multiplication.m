//
//  Multiplication.m
//  TouchAlgebra
//
//  Created by David Sullivan on 7/11/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "Multiplication.h"
#import "Addition.h"
#import "Integer.h"
#import "RealNumber.h"
#import "Constant.h"
#import "Power.h"
#import "Fraction.h"

@implementation Multiplication

-(id) init {
	
	return [self initWithTermValue:@""];
}

- (id) initWithTermValue:(NSString*) someStringValue  {
	
	// string value of multiplication is always "*" 
	if (self = [super initWithTermValue:@""]){
		
		[self setTermValue:@"*"];
	}
	return self;
	
}

- (id) init:(Term *) term, ... {
	
	// term value is always "ListOperator"
	if (self = [super initWithTermValue:@"ListOperator"]) {
		
		// add the intial terms
		id currentObject;
		va_list argList;
		
		if (term)
		{
			[self appendTerm:term];
			
			va_start(argList, term);
			while ((currentObject = va_arg(argList, id)))
				[self appendTerm:currentObject];
			va_end(argList);
		}
	}
	
	return self;
}

- (NSMutableString *) printStringValue {
	
	NSMutableString *newString = [[[NSMutableString alloc] init] autorelease];
	
	for (int x = 0; x < [termList count]; x++) {
	
		// add multiplication symbol for second and subsequent terms ("*")
		if (x != 0) {
			
			// add parenthesis around addition terms
			if ([[self termAtIndex:x] isKindOfClass:[Addition class]]) {
				
				[newString appendString:@"*("];
				[newString appendString:[[self termAtIndex:x] printStringValue]];
				[newString appendString:@")"];
				 
			}
			else {
				[newString appendString:@"*"];
				[newString appendString:[[self termAtIndex:x] printStringValue]];
			}
		}
		else {
			[newString appendString:[[self termAtIndex:x] printStringValue]];
		}

	}
	
	return newString;
}

- (id) copyWithZone:(NSZone *) zone {
	
	Multiplication *newTerm = [[Multiplication	alloc] initWithTermValue:termValue];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:nil];
	[newTerm setColor:color];
	[newTerm setFont:font];
	
	// copy the term array
	Term *t;
	for (int x = 0; x < [termList count]; x++) {
		t = [(Term *)[termList objectAtIndex:x] copyWithZone:zone];
		[newTerm appendTerm:t];
		[t release];
	}
	
	return newTerm;
}

- (Term *) copyRemovingTerm: (Term *) t {
	
	// make sure there are at least two terms
	if ([self count] < 2) {
		return nil;
	}
	
	// find the index of the term in the multiplication
	int index = [self indexOfTerm:t];
	
	// if term not in the multiplication - bail
	if (index == NSNotFound) {
		return nil;
	}
	
	// create a copy and remove the term
	Multiplication *newMult = [[self copy] autorelease];
	[newMult removeTermAtIndex:index];
	
	// if only one term remaining? return that term
	if ([newMult count] == 1) {
		
		return [[newMult termAtIndex:0] copy];
	}
	
	// more than two terms return the new multiplication
	else {
		
		return [newMult retain];
	}
}

- (Term *) copyRemovingTerms: (Term *) t1 and: (Term *) t2 {
	
	// make sure there are at least three terms
	if ([self count] < 3) {
		return nil;
	}
	
	// find the index of the terms in the multiplication
	int index1 = [self indexOfTerm:t1];
	int index2 = [self indexOfTerm:t2];
	
	// if term not in the multiplication - bail
	if (index1 == NSNotFound || index2 == NSNotFound) {
		return nil;
	}
	
	// create a copy and remove the term
	// Note - need to remove the terms right to left to retain the index values
	Multiplication *newMult = [[self copy] autorelease];
	if (index1 > index2) {
		[newMult removeTermAtIndex:index1];
		[newMult removeTermAtIndex:index2];
	}
	else {
		[newMult removeTermAtIndex:index2];
		[newMult removeTermAtIndex:index1];
	}

	
	// no terms left?
	if ([newMult count] == 0) {
		return nil;
	}
	// if only one term remaining? return that term
	else if ([newMult count] == 1) {
		
		return [[newMult termAtIndex:0] copy];
	}
	
	// more than two terms return the new multiplication
	else {
		
		return [newMult retain];
	}
}

- (Term *) copyReplacingTerm: (Term *) t1 withTerm: (Term *) t2 {
	
	// make sure there are at least two terms
	if ([self count] < 2) {
		return nil;
	}
	
	// find the index of the term in the multiplication
	int index = [self indexOfTerm:t1];
	
	// if term not in the multiplication - bail
	if (index == NSNotFound) {
		return nil;
	}
	
	// create a copy and replace the term
	Multiplication *newMult = [[self copy] autorelease];
	[newMult removeTermAtIndex:index];
	
	// ignore values of 1 
	if (!([t2 isKindOfClass:[Integer class]] && [(Integer *) t2 rawValue] == 1) ||
		([t2 isKindOfClass:[RealNumber class]] && [(RealNumber *) t2 rawValue] == 1.0)) {
		
		[newMult insertTerm:t2 atIndex:index];
	}
	else {
		if([newMult count] == 1) {
			
			// only one term remaining? return that term
			return [[newMult termAtIndex:0] copy];
		}
	}
	
	return [newMult retain];
}

- (Term *) copyRemovingTerm: (Term *) t1 andReplacingTerm: (Term *) t2 withTerm: (Term *) t3 {
	
	// find the index of the terms in the multiplication
	int index1 = [self indexOfTerm:t1];
	int index2 = [self indexOfTerm:t2];
	
	// if term not in the multiplication - bail
	if (index1 == NSNotFound || index2 == NSNotFound) {
		return nil;
	}
	
	// create a copy, remove the terms and insert the new term
	Multiplication *newMult = [[self copy] autorelease];
	[newMult removeTermAtIndex:index2];
	[newMult insertTerm:t3 atIndex:index2];
	[newMult removeTermAtIndex:index1];
	
	// if only one term remaining? return that term
	if ([newMult count] == 1) {
		
		return [[newMult termAtIndex:0] copy];
	}
	
	// more than two terms return the new multiplication
	else {
		
		return [newMult retain];
	}
}

- (Multiplication *) copyReplacingTerm: (Term *) t1 withTerm: (Term *) t2 andReplacingTerm: (Term *) t3 withTerm: (Term *) t4 {
	
	// find the index of the terms in the multiplication
	int index1 = [self indexOfTerm:t1];
	int index2 = [self indexOfTerm:t3];
	
	// if terms are not in the multiplication - bail
	if (index1 == NSNotFound || index2 == NSNotFound) {
		return nil;
	}
	
	// create a copy, remove the terms and inserting the new terms
	Multiplication *newMult = [self copy];
	[newMult removeTermAtIndex:index1];
	[newMult insertTerm:t2 atIndex:index1];
	[newMult removeTermAtIndex:index2];
	[newMult insertTerm:t4 atIndex:index2];
	
	return newMult;
}

- (BOOL) isReducableTermInFractionMultiplicand: (Term *) t {
	
	return (([[t parentTerm] isKindOfClass:[Fraction class]] && 
			 [self isImmediateSubTerm:[t parentTerm]]) ||
			([[t parentTerm] isKindOfClass:[Multiplication class]] && 
			 [[[t parentTerm] parentTerm] isKindOfClass:[Fraction class]] && 
			 [self isImmediateSubTerm:[[t parentTerm] parentTerm]]));
}

- (Term *) copyReducingWithSubTerm:(Term *) source andSubTerm:(Term *) target {

	if ([self isImmediateSubTerm:source] && [self isImmediateSubTerm:target]) {
		
		// multiply by zero
		if ([source isZero] || [target isZero]) {
			
			return [[Integer alloc] initWithInt:0];
		}
		
		// multiply infinity
		else if ([source isEquivalent:[Constant infinity]] || [target isEquivalent:[Constant infinity]]) {
			
			return [[Constant infinity] copy];
		}
				
		// multiply by 1
		else if(([source isKindOfClass:[Integer class]] && [(Integer *) source rawValue] == 1) ||
				([source isKindOfClass:[RealNumber class]] && [(RealNumber *) source rawValue] == 1))
		{
			return [self copyRemovingTerm:source];
		}
		else if(([target isKindOfClass:[Integer class]] && [(Integer *) target rawValue] == 1) ||
				([target isKindOfClass:[RealNumber class]] && [(RealNumber *) target rawValue] == 1))
		{
			return [self copyRemovingTerm:target];
		}
		
		// multiply terms by negative one
		else if([source isKindOfClass:[Integer class]] && [(Integer *) source rawValue] == -1)
		{
			Term *newTarget = [[target copy] autorelease];
			[newTarget opposite];
			return [self copyRemovingTerm:source andReplacingTerm: target withTerm: newTarget];
		}
		else if([target isKindOfClass:[Integer class]] && [(Integer *) target rawValue] == -1)
		{
			Term *newSource = [[source copy] autorelease];
			[newSource opposite];
			return [self copyRemovingTerm:target andReplacingTerm: source withTerm: newSource];
		}
				
		// multiply numbers
		else if ([source isKindOfClass:[Number class]] && [target isKindOfClass:[Number class]]) {
			
			Number *n;
			
			// real number?
			if ([source isKindOfClass:[RealNumber class]]) {
				if ([target isKindOfClass:[RealNumber class]]) {
					
					n = [[[RealNumber alloc] initWithFloat:[(RealNumber *) source rawValue] * [(RealNumber *) target rawValue]] autorelease];
				}
				else {
					n = [[[RealNumber alloc] initWithFloat:[(RealNumber *) source rawValue] * [(Integer *) target rawValue]] autorelease];
				}
			}
			else if ([target isKindOfClass:[RealNumber class]]){
				
				n = [[[RealNumber alloc] initWithFloat:[(Integer *) source rawValue] * [(RealNumber *) target rawValue]] autorelease];
			}
			else {
                
                // check for overflow -MAX_INTEGER to MAX_INTEGER
                NSInteger x = [(Integer *) source rawValue];
                NSInteger y = [(Integer *) target rawValue];
                long z = x * y;
                
                if (z > MAX_INTEGER || z < -MAX_INTEGER) {
                    return nil;
                }

				n = [[[Integer alloc] initWithInt:z] autorelease];
			}
            
            return [self copyRemovingTerm:source andReplacingTerm:target withTerm:n];

		}
		
		// multiply two constants
		else if ([source isKindOfClass:[SymbolicTerm class]] && [target isKindOfClass:[SymbolicTerm class]] && [source isEquivalentIgnoringSign:target]) {
				
			// create the power term
			Power *newPower = [[[Power alloc] init] autorelease];
			Constant *newBase = [[source copy] autorelease];
			[newBase setIsOpposite:NO];
			[newPower setBase:newBase];
			[newPower setExponent:[[[Integer alloc] initWithInt:2] autorelease]];
			
			// set the sign of the new term
			int sign = ([(SymbolicTerm *) source isOpposite] ? -1 : 1) * ([(SymbolicTerm *) target isOpposite] ? -1 : 1);
			if (sign == -1) {
				[newPower setIsOpposite:YES];
			}
			
            return [self copyRemovingTerm:source andReplacingTerm:target withTerm:newPower];
		}	
		
		// distribute
		else if ([target isKindOfClass:[Addition class]]) {
			
			// multiply each term in the target addition by the source term
			Addition *newAddition = [[[Addition alloc] init] autorelease];
			for (Term *t in [(Addition *) target termList]) {
				Multiplication *m = [[[Multiplication alloc] init:source, t, nil] autorelease];
				[newAddition appendTerm:m Operator:[(Addition *) target getOperatorAtIndex:[(Addition *) target indexOfTerm:t]]];
			}
			
			return [self copyRemovingTerm:source andReplacingTerm:target withTerm:newAddition];
		}
		
		// multiply two powers
		else if ([source isKindOfClass:[Power class]] && [target isKindOfClass:[Power class]]) {
			
			// multiply two powers with the same base
			if ([[(Power *) source base] isEquivalent:[(Power *) target base]]) {
				
				// create the new power
				Power *newPower = [[[Power alloc] init] autorelease];
				[newPower setBase:[(Power *) target base]];
				
				// take the opposite if necessary
				if ([source isOpposite]) {
					[newPower opposite];
				}
				if ([target isOpposite]) {
					[newPower opposite];
				}
				
				// create the new exponent
				Addition *newAdd = [[[Addition alloc] init] autorelease];
				[newAdd appendTerm:[(Power *) target exponent]];
				[newAdd appendTerm:[(Power *) source exponent]];
				
				// set the new exponent of the target
				[newPower setExponent:newAdd];
				
                return [self copyRemovingTerm:source andReplacingTerm:target withTerm:newPower];
			}
			// multiply two powers with the same exponent
			else if ([[(Power *) source exponent] isEquivalent:[(Power *) target exponent]]) {

				// create the new multiplication
				Multiplication *newMult = [[[Multiplication alloc] init:[(Power *) source base], [(Power *) target base], nil] autorelease];
				Power *newPower = [[[Power alloc] initWithBase:newMult andExponent:[(Power *) source exponent]] autorelease];
				
				// take the opposite if necessary
				if ([source isOpposite]) {
					[newPower opposite];
				}
				if ([target isOpposite]) {
					[newPower opposite];
				}

                return [self copyRemovingTerm:source andReplacingTerm:target withTerm:newPower];
			}
		}
		
		// multiply two fractions
		else if ([source isKindOfClass:[Fraction class]] && [target isKindOfClass:[Fraction class]]){
			
			// create the numerator
			Multiplication *num	 = [[[Multiplication alloc] init] autorelease];
			[num appendTerm:[(Fraction *)source numerator]];
			[num appendTerm:[(Fraction *)target numerator]];
			
			// create the demoninator
			Multiplication *denom	 = [[[Multiplication alloc] init] autorelease];
			[denom appendTerm:[(Fraction *)source denominator]];
			[denom appendTerm:[(Fraction *)target denominator]];
			
			// create the new fraction
			Fraction *newFraction = [[[Fraction alloc] initWithNum:num andDenom:denom] autorelease];
			
			// copy and replace term
			return [self copyRemovingTerm:source andReplacingTerm:target withTerm:newFraction];
		}	
				
		// multiply a power by the base
		else if (([source isKindOfClass:[Power class]] && [[(Power *) source base] isEquivalentIgnoringSign: target]) || 
				 ([target isKindOfClass:[Power class]] && [[(Power *) target base] isEquivalentIgnoringSign: source])) {
			
			// pointer to power and base
			Power *p;
			Term *b;
			if ([source isKindOfClass:[Power class]]) {
				p = (Power *) source;
				b = target;
			}
			else {
				p = (Power *) target;
				b = source;
			}

			// handle case where the base is opposite and the multiplicand is not
			if ([[p base] isOpposite] && ![b isOpposite]) {
				return nil;
			}
			
			// create the new power
			Addition *newExp = [[[Addition alloc] init:[p exponent], [[[Integer alloc] initWithInt:1] autorelease], nil] autorelease];
			Power *newPower = [[[Power alloc] initWithBase:[p base] andExponent:newExp] autorelease];
			
			// take the opposite if necessary
			if (![[p base] isEquivalent: b] && [b isOpposite]) {
				
				[newPower opposite];
			}
			if ([p isOpposite]) {
				[newPower opposite];
			}
			
			return [self copyRemovingTerm:source andReplacingTerm:target withTerm:newPower];
		}
		// otherwise swap terms
		else {
			
			int x = [self indexOfTerm:source];
			int y = [self indexOfTerm:target];
			
			Multiplication *temp = [[self copy] autorelease];
			[temp exchangeTerm:x andTerm:y];
			return [temp retain];
		}
		
	}	
	
	// multiply a power by the base
	else if ([source isEquivalentIgnoringSign:target] &&
			 (([self isImmediateSubTerm:source] && 
			  [[target parentTerm] isKindOfClass:[Power class]] &&
			  [self isImmediateSubTerm:[target parentTerm]] && 
			  [(Power *) [target parentTerm] base] == target) || 
			 ([self isImmediateSubTerm:target] && 
			  [[source parentTerm] isKindOfClass:[Power class]] &&
			  [self isImmediateSubTerm:[source parentTerm]] && 
			  [(Power *) [source parentTerm] base] == source))) {
		
				 // local pointers
				 Term *immediateTerm;
				 Power *p;
				 if ([self isImmediateSubTerm:source]) {
					 p = (Power *) [target parentTerm];
					 immediateTerm = source;
				 }
				 else {
					 p = (Power *) [source parentTerm];
					 immediateTerm = target;
				 }
				 
				 // handle case where the base is opposite and the multiplicand is not
				 if ([[p base] isOpposite] && ![immediateTerm isOpposite]) {
					 return nil;
				 }
				 
				 
				 // create the new power
				 Addition *newExp = [[[Addition alloc] init:[p exponent], [[[Integer alloc] initWithInt:1] autorelease], nil] autorelease];
				 Power *newPower = [[[Power alloc] initWithBase:[p base] andExponent:newExp] autorelease];
				 
				 // take the opposite if necessary
				 if (![[p base] isEquivalent: immediateTerm] && [immediateTerm isOpposite]) {
					 
					 [newPower opposite];
				 }
				 if ([p isOpposite]) {
					 [newPower opposite];
				 }
				 
				 if ([self isImmediateSubTerm:source]) {
					 return [self copyRemovingTerm:immediateTerm andReplacingTerm:p	withTerm:newPower];
				 }
				 else {
					 return [self copyRemovingTerm:p andReplacingTerm:immediateTerm withTerm:newPower];
				 }

			 }

	// Cancel expressions in multiplicand fractions
	else if ([source isEquivalent:target] &&
			 [self isReducableTermInFractionMultiplicand:source] &&
			 [self isReducableTermInFractionMultiplicand:target]
			 ) {
		
		// state variables and handy pointers
		BOOL sourceInMulti = [[source parentTerm] isKindOfClass:[Multiplication class]];
		BOOL targetInMulti = [[target parentTerm] isKindOfClass:[Multiplication class]];
		Fraction *sourceFraction = (Fraction *) (sourceInMulti ? [[source parentTerm] parentTerm] : [source parentTerm]);
		Fraction *targetFraction = (Fraction *) (targetInMulti ? [[target parentTerm] parentTerm] : [target parentTerm]);
		BOOL sourceInNum   = [sourceFraction numerator] == source || [[sourceFraction numerator] isSubTerm:source];
		BOOL targetInNum   = [targetFraction numerator] == target || [[targetFraction numerator] isSubTerm:target];
		
		// one term must in a numerator and the other in the denominator
		if (!(sourceInNum ^ targetInNum)) {
			
			return nil;
		}
		
		Term *newSource;
		Term *newTarget;
		
		// create new terms
		if (sourceInNum) {
			if (sourceInMulti) {
				newSource = [[[Fraction alloc] initWithNum:[[(Multiplication *) [sourceFraction numerator] copyRemovingTerm:source] autorelease] 
												  andDenom:[sourceFraction denominator]] autorelease];
			}
			else {
				newSource = [[[Fraction alloc] initWithNum:[[[Integer alloc] initWithInt:1] autorelease] 
												  andDenom:[sourceFraction denominator]] autorelease];
			}
			if (targetInMulti) {
				newTarget = [[[Fraction alloc] initWithNum:[targetFraction numerator]
												  andDenom:[[(Multiplication *) [targetFraction denominator] copyRemovingTerm:target] autorelease]] autorelease];
			}
			else {
				newTarget = [[[targetFraction numerator] copy] autorelease];
			}
		}
		else {
			if (sourceInMulti) {
				newSource = [[[Fraction alloc] initWithNum:[sourceFraction numerator]
												  andDenom:[[(Multiplication *) [sourceFraction denominator] copyRemovingTerm:source] autorelease]] autorelease];
			}
			else {
				newSource = [[[sourceFraction numerator] copy] autorelease];
			}
			if (targetInMulti) {
				newTarget = [[[Fraction alloc] initWithNum:[[(Multiplication *) [targetFraction numerator] copyRemovingTerm:target] autorelease] 
												  andDenom:[targetFraction denominator]] autorelease];
			}
			else {
				newTarget = [[[Fraction alloc] initWithNum:[[[Integer alloc] initWithInt:1] autorelease] 
												  andDenom:[targetFraction denominator]] autorelease];
			}
		}

		Multiplication *newMult = [[self copy] autorelease];
		
		// replace both fraction with the new terms and return
        Term *targetFractionInNewMulti = [newMult termAtIndex:[self indexOfTerm:targetFraction]]; // need to save a pointer to the target fraction as we don't know where is will be after the source fraction is replaced
		[newMult replaceSubterm:[newMult termAtIndex:[self indexOfTerm:sourceFraction]] withTerm:newSource];
		[newMult replaceSubterm:targetFractionInNewMulti withTerm:newTarget];
		return [newMult retain];
	}
	
	// cancel a multiplicand with a multiplicand in the denominator of a fraction
	else if (([self isImmediateSubTerm:source] && [[target parentTerm] isKindOfClass:[Fraction class]] && [self isImmediateSubTerm:[target parentTerm]]) ||
			 ([self isImmediateSubTerm:target] && [[source parentTerm] isKindOfClass:[Fraction class]] && [self isImmediateSubTerm:[source parentTerm]])) {

		// some local variables to simplify life
		Term *multiplicand;
		Term *base;
		
		if ([self isImmediateSubTerm:source]) {
			base = target;
			multiplicand = source;
		}
		else {
			base = source;
			multiplicand = target;
		}

		if ([multiplicand isEquivalent:base] && [(Fraction *) [base parentTerm] denominator] == base) {
			
			// note: need to copy the numerator because the parent fraction gets released before the base is added
			Term *newNum = [[[(Fraction *) [base parentTerm] numerator] copy] autorelease];
			return [self copyRemovingTerm:multiplicand andReplacingTerm:[base parentTerm] withTerm:newNum];
		}

		// move a multiplicand to the numerator of a fraction
		else if ([(Fraction *)[base parentTerm] numerator] == base || [[(Fraction *)[base parentTerm] numerator] isSubTerm:base]){
			
			Fraction *f = (Fraction *) [base parentTerm];
			
			// create the new fraction multiplying source and numerator
			Multiplication *m = [[[Multiplication alloc] init: multiplicand, [f numerator], nil] autorelease];
			Fraction *newFrac = [[[Fraction alloc] initWithNum:m andDenom:[f denominator]] autorelease];
			
			return [self copyRemovingTerm:multiplicand andReplacingTerm:f withTerm:newFrac];
		}		
	}

	// cancel a multiplicand with a multiplicand in the denominator of a fraction, which is also a multiplicand
	else if ([source isEquivalent:target] &&
			 (([self isImmediateSubTerm:source] && 
			  [[target parentTerm] isKindOfClass:[Multiplication class]] && 
			  [[[target parentTerm] parentTerm] isKindOfClass:[Fraction class]] && 
			  [(Fraction *)[[target parentTerm] parentTerm] denominator] == [target parentTerm] && 
			  [self isImmediateSubTerm:[[target parentTerm] parentTerm]]) ||
			 ([self isImmediateSubTerm:target] && 
			  [[source parentTerm] isKindOfClass:[Multiplication class]] && 
			  [[[source parentTerm] parentTerm] isKindOfClass:[Fraction class]] && 
			  [(Fraction *)[[source parentTerm] parentTerm] denominator] == [source parentTerm] && 
			  [self isImmediateSubTerm:[[source parentTerm] parentTerm]]))
			 ) {
				 
		// some local variables to simplify life
		Term *denomMultiplicand;
		Term *multiplicand;
		Fraction *frac;
		
		if ([self isImmediateSubTerm:source]) {
			denomMultiplicand = target;
			multiplicand = source;
			frac = (Fraction *)[[target parentTerm] parentTerm];
		}
		else {
			denomMultiplicand = source;
			multiplicand = target;
			frac = (Fraction *)[[source parentTerm] parentTerm];
		}
		
		
		Term *newDenom = [[(Multiplication *)[denomMultiplicand parentTerm] copyRemovingTerm:denomMultiplicand] autorelease];
		Fraction *newFrac = [[[Fraction alloc] initWithNum:[frac numerator] andDenom:newDenom] autorelease];
		
		// note: need to copy the numerator because the parent fraction gets released before the base is added
		return [self copyRemovingTerm:multiplicand andReplacingTerm:frac withTerm:newFrac];
	}
    
    // multiplicands with same exponent move to base of exponential
    else if ([source isEquivalent:target] &&
             [[source parentTerm] isKindOfClass:[Power class]] && [(Power *) [source parentTerm] exponent] == source && 
             [[target parentTerm] isKindOfClass:[Power class]] && [(Power *) [target parentTerm] exponent] == target && 
             [self isImmediateSubTerm:[source parentTerm]] &&
             [self isImmediateSubTerm:[target parentTerm]]
             ) {
        
        Power *sourcePower = (Power *) [source parentTerm];
        Power *targetPower = (Power *) [target parentTerm];
        
        Multiplication *m = [[[Multiplication alloc] init:[sourcePower base], [targetPower base], nil] autorelease];
        
        Power *newPower = [[[Power alloc] initWithBase:m andExponent:[sourcePower exponent]] autorelease];
        
        return [self copyRemovingTerm:[source parentTerm] andReplacingTerm:[target parentTerm] withTerm:newPower];
        
    }

	return nil;
}

- (BOOL) isEquivalent:(Term *) term {
	
	// make sure were the same type
	if ([term isKindOfClass:[Multiplication class]]) {
		
		// cast term to list operator for simplicity
		Multiplication *m = (Multiplication *) term;
		int termCount = [termList count];
		
		if ([m count] == termCount) {
			
			// initialize an array to record which terms have been matched
			// 1 = matched, 0 = unmatched
			int match[termCount];
			for (int x = 0; x < termCount; x++) {
				match[x] = 0;
			}
			
			// step through each term in the term list
			for (int x = 0; x < termCount; x++) {
				
				BOOL termMatched = NO;
				
				// try to match an unmatched term in the second term
				for (int y = 0; y < termCount && !termMatched; y++) {
					
					if (!match[y]) {
						if ([[self termAtIndex:x] isEquivalent:[m termAtIndex:y]]) {
							match[y] = 1;
							termMatched = YES;
						}
					}
				}
				
				// We didn't find a match for current term, so we're done
				if (!termMatched) {
					return NO;
				}
			}
			
			// see if all terms where matched
			for (int x = 0; x < termCount; x++) {
				if (!match[x]) {
					return NO;
				}
			}
			
			return YES;
		}
	}
	
	return NO;
}

- (void) opposite {
	
	// take the opposite the first term
	[[termList objectAtIndex:0] opposite];
}

- (BOOL) isZero {

	// if any term is zero the multiplication is zero
	for (Term *t in termList) {
		
		if ([t isZero]) {
			return YES;
		}
	}
			 
	return NO;
}

@end
