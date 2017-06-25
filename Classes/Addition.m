//
//  Addition.m
//  TouchAlgebra
//
//  Created by David Sullivan on 7/8/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "Addition.h"
#import "Term.h"
#import "Integer.h"
#import "RealNumber.h"
#import "Constant.h"
#import "Variable.h"
#import "Multiplication.h"
#import "Power.h"
#import "Fraction.h"


/**************************** ADDITION OPERATOR ******************************/
// private class for addition operator (add or subtract)

@interface additionOperator : NSObject
{
	NSUInteger operator;
}

- (id) initWithOperator:(NSUInteger)oper;

@property NSUInteger operator;

@end

@implementation additionOperator

- (id) init {
	
	if (self = [super init]) {
		[self setOperator:ADDITION_OPERATOR] ;
	}
	return	self;
}

- (id) initWithOperator:(NSUInteger) oper {
	
	if (self = [super init]) {
		[self setOperator:oper]; 
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	
	[coder encodeInt:operator forKey:@"operator"];
	
}

- (id) initWithCoder:(NSCoder *)coder { 
	
	// Init first.
    self = [self init];
	
	operator = [coder decodeIntForKey:@"operator"];
	
	return self;
}

@synthesize operator;

@end

/**************************** ADDITION IMPLEMENTATION *****************************/
@implementation Addition

-(id) init {
	
	return [self initWithTermValue:@""];
}

// designated initializer
- (id) initWithTermValue:(NSString*) someStringValue {
	
	if (self = [super initWithTermValue:@""]) {
		
		// string value of addition is always "+" 
		[self setTermValue:@"+"];
		
		// set up the operator list
		operatorList = [[NSMutableArray alloc] initWithCapacity:(NSUInteger) 3];
	}
	
	return self;
	
}

- (id) init:(Term *) term, ... {
	
	// term value is always "ListOperator"
	if (self = [super initWithTermValue:@"ListOperator"]) {
		
		// add the intial terms
		id currentObject;
		va_list argList;
		
		// set up the operator list
		operatorList = [[NSMutableArray alloc] initWithCapacity:(NSUInteger) 3];

		if (term) {
			[self appendTerm:term];
			
			va_start(argList, term);
			while (currentObject = va_arg(argList, id)) {
				[self appendTerm:currentObject];
			}
			va_end(argList);
		}
	}
	
	return self;
}

- (void) insertTerm:(Term *) newTerm atIndex: (NSUInteger) index Operator: (NSUInteger) oper {
	
	// the first term cannot be subtracted
	if (index == 0 && oper == SUBTRACTION_OPERATOR) {
		
		NSException *exception = [NSException exceptionWithName:@"TermException" 
														 reason:@"The first term in an addition cannot be subtracted" 
													   userInfo:nil];
		@throw exception;
	}
	
	// if newTerm is addition add its subterms instead
	if ([newTerm isKindOfClass:[Addition class]]) {
				
		NSUInteger i = index;
		Addition *a = (Addition *) newTerm;
		
		for (int x = 0; x < [[a termList] count]; x++) {

			[super insertTerm:[a termAtIndex:x] atIndex:i];
			
			// if subtracting, reverse the operator
			int newOperator;
			if (oper == SUBTRACTION_OPERATOR) {
				newOperator = [a getOperatorAtIndex:x] == SUBTRACTION_OPERATOR ? ADDITION_OPERATOR : SUBTRACTION_OPERATOR;
			}
			else {
				newOperator = [a getOperatorAtIndex:x];
			}

			additionOperator *o = [[additionOperator alloc] initWithOperator:newOperator];
			[operatorList insertObject:o atIndex:i];
			[o release];
			i++;
		}
	} 
	else {
		[super insertTerm:newTerm atIndex:index];
		additionOperator *o = [[additionOperator alloc] initWithOperator:oper];
		[operatorList insertObject:o atIndex:index];
		[o release];
	}
}

- (void) insertTerm:(Term *) newTerm atIndex: (NSUInteger) index {
	
	// assume addition as no operator is provided
	[self insertTerm:newTerm atIndex:index Operator: ADDITION_OPERATOR];	
}

- (void) appendTerm:(Term *) newTerm{
	
	// assume addition as no operator is provided
	[self insertTerm:newTerm atIndex:[termList count] Operator: ADDITION_OPERATOR];	
}

- (void) appendTerm:(Term *) newTerm Operator: (NSUInteger) oper {
	
	[self insertTerm:newTerm atIndex:[termList count] Operator: oper];	
}

- (void) removeTerm:(Term *) oldTerm{
	
	// find the term in the array
	NSUInteger location = [termList indexOfObjectIdenticalTo:oldTerm];
	
	// remove term and operator
	[super removeTermAtIndex:location];
	[operatorList removeObjectAtIndex:location];
}

- (void) removeTermAtIndex: (NSUInteger) index{
	
	[super removeTermAtIndex:index];
	[operatorList removeObjectAtIndex:index];
}

- (NSUInteger) getOperatorAtIndex:(NSUInteger) index{
	
	return	[[operatorList objectAtIndex:index] operator];
}

- (void) setOperator:(NSInteger) operator atIndex:(NSUInteger) index{
	
	// remove existing and insert new
	[operatorList removeObjectAtIndex:index];
	additionOperator *o = [[additionOperator alloc] initWithOperator:operator];
	[operatorList insertObject:o atIndex:index];
	[o release];
}

// override printStringValue so it returns 1 + c + x, etc.
- (NSMutableString *) printStringValue {
	
	NSMutableString *newString = [[[NSMutableString alloc] init] autorelease];
	
	for (int x = 0; x < [termList count]; x++) {

		// add operator formating for second and subsequent terms (" +/- ")
		if (x != 0) {
			
			[newString appendString:@" "];
			
			if ([self getOperatorAtIndex:x] == ADDITION_OPERATOR) {
				[newString appendString:@"+"];
			}
			else {
				[newString appendString:@"-"];	
			}
			[newString appendString:@" "];
		}
		
		[newString appendString:[[self termAtIndex:x] printStringValue]];

	}
	 
	return newString;
}

- (BOOL) replaceSubterm: (Term *) oldTerm withTerm: (Term *) newTerm {
	
	for (Term *t in termList) {
		if ([t replaceSubterm:oldTerm withTerm:newTerm]) {
			return YES;
		}
	}
	NSInteger index = [termList indexOfObject:oldTerm];
	
	if (index != NSNotFound) {
		
		// save  the operator
		NSInteger oper = [self getOperatorAtIndex:index];
		
		[self removeTerm:oldTerm];
		[oldTerm setParentTerm:nil];
		[self insertTerm:newTerm atIndex:index Operator:oper];
		[newTerm setParentTerm:self];
		return YES;
	}
	
	return NO;
}

- (Term *) factorOutTerm: (Term *) t1 fromTerm: (Term *) t2 {
	
	// simple terms
	if ([t1 isSimpleTerm] && t1 == t2) {
		
		return [[[Integer alloc] initWithInt:1] autorelease];
	}
	
	// multiplication
	if ([t2 isKindOfClass:[Multiplication class]] && [t1 parentTerm] == t2) {
		
		Multiplication *m = (Multiplication *) t2;
		return [[m copyRemovingTerm:t1] autorelease];
	}
	
	// powers
	if ([t2 isKindOfClass:[Power class]] && [(Power *) t2 base] == t1) {
		
		return [[(Power *) t2 copyDecrementingExponent] autorelease];
	}
	
	return nil;
	
}

- (BOOL) canBeFactored: (Term *) term {
	
	Term *parent = [term parentTerm];
	
	// must have a parent
	if (!parent) {
		return NO;
	}
	
	if ((parent == self && [term isSimpleTerm]) || // simple term in addition
		([parent isKindOfClass:[Multiplication class]] && [parent parentTerm] == self) || // member of multiplication
		([parent isKindOfClass:[Power class]] && [parent parentTerm] == self && [(Power *) parent base] == term) // base of power in addition
		){
		
		return YES;
	}
	
	return NO;
}

//The net operator for negated terms. Net operator of x in y - (-x) is addition
- (NSUInteger) netOperator:(Term *) t{
	
	if ([t isOpposite]) {
		
		return [self getOperatorAtIndex:[self indexOfTerm:t]] == SUBTRACTION_OPERATOR ? ADDITION_OPERATOR : SUBTRACTION_OPERATOR;
	}
	else {
		return [self getOperatorAtIndex:[self indexOfTerm:t]];
	}
	
	
}

- (Term *) leftMostTermOf: (Term *) t1 and: (Term *) t2 {
	
	return [self indexOfTerm:t1] < [self indexOfTerm:t2] ? t1 : t2;
	
}

- (Term *) rightMostTermOf: (Term *) t1 and: (Term *) t2 {
	
	return [self indexOfTerm:t1] > [self indexOfTerm:t2] ? t1 : t2;
	
}

- (Term *) createSimplifiedTermFromPower: (Power *) power withExponent: (int) exp ignoreParent: (BOOL) ip {
	
	Term *t;
	if (exp == 0) {
		t = [[[Integer alloc] initWithInt:1] autorelease];
	}
	else if (exp == 1) {
		
		t = [[[power base] copy] autorelease];
	}
	else {
	
		t = [[Power alloc] initWithBase:[power base] andExponent:[[[Integer alloc] initWithInt:exp] autorelease]];
		
	}
	
	// adjust for negative powers
	if ([power isOpposite]) {
		[t opposite];
	}
	
	Term *newTerm;
	if ([[power parentTerm] isKindOfClass:[Multiplication class]] && !ip) {
		if ([t isKindOfClass:[Integer class]]) { // the only possible integer is 1
			newTerm = [[(Multiplication *) [power parentTerm] copyRemovingTerm:power] autorelease];
		}
		else {
			newTerm = [[(Multiplication *) [power parentTerm] copyReplacingTerm:power withTerm:t] autorelease];
		}
		
	}
	else {
		newTerm = t;
	}
	
	return [newTerm retain];
}

- (Term *) copyFactoringPower:(Power *) p1 andPower: (Power *) p2 withTarget: (Term *) target {
	
	// base and power may be in a multiplication
	
	// some convenience variables
	BOOL p1IsInMulti = [[p1 parentTerm] isKindOfClass:[Multiplication class]];
	BOOL p2IsInMulti = [[p2 parentTerm] isKindOfClass:[Multiplication class]];
	
	Term *p1ImmediateTerm = p1IsInMulti ? [p1 parentTerm] : p1;
	Term *p2ImmediateTerm = p2IsInMulti ? [p2 parentTerm] : p2;
	
	Term *sourceTerm = (target == p1ImmediateTerm) ? p2ImmediateTerm : p1ImmediateTerm;
	Term *leftMostTerm  = [self leftMostTermOf:p1ImmediateTerm and:p2ImmediateTerm];
	Term *rightMostTerm = [self rightMostTermOf:p1ImmediateTerm and:p2ImmediateTerm];
	
	// are both exponents integers and base terms are not negative?
	if ([[p1 exponent] isKindOfClass:[Integer class]] && ![[p1 base] isOpposite] &&
		[[p2 exponent] isKindOfClass:[Integer class]] && ![[p2 base] isOpposite]) {
		
		int p1Int = [(Integer *) [p1 exponent] rawValue];
		int p2Int = [(Integer *) [p2 exponent] rawValue];
		
		// positive exponents
		if (p1Int > 0 && p2Int > 0) {

			// adjust the exponent
			int minInt = MIN(p1Int, p2Int);
			p1Int = p1Int - minInt;
			p2Int = p2Int - minInt;
			
			// create the factored power, which will not be negated
			Term *factoredPower = [[self createSimplifiedTermFromPower:p1 withExponent:minInt ignoreParent:YES] autorelease];
			
			// create the reduced powers
			Term *newP1Term = [[self createSimplifiedTermFromPower:p1 withExponent:p1Int ignoreParent:NO] autorelease];
			Term *newP2Term = [[self createSimplifiedTermFromPower:p2 withExponent:p2Int ignoreParent:NO] autorelease];
			
			// create the new addition retaining term order
			Addition *newAdd;
			if (leftMostTerm == p1 || leftMostTerm == [p1 parentTerm]) {
				
				newAdd = [[[Addition alloc] init:newP1Term, newP2Term, nil] autorelease]; 
			}
			else {
				newAdd = [[[Addition alloc] init:newP2Term, newP1Term, nil] autorelease]; 
			}
			
			// if one or the other of the two terms being added are subtractions new addition will be subtraction
			if ([self getOperatorAtIndex:[self indexOfTerm:leftMostTerm]] == SUBTRACTION_OPERATOR ^
				[self getOperatorAtIndex:[self indexOfTerm:rightMostTerm]] == SUBTRACTION_OPERATOR) {
				[newAdd setOperator:SUBTRACTION_OPERATOR atIndex:1];
			}

			// the factored power in the multiplication will not be negative
			Multiplication *newMulti = [[[Multiplication alloc] init:factoredPower, newAdd, nil] autorelease];
			[[newMulti termAtIndex:0] setIsOpposite:NO];
			
			// copy and return
			return [self copyRemovingTerm:sourceTerm 
						 andReplacingTerm:target 
								 withTerm:newMulti 
							 withOperator:[self getOperatorAtIndex:[self indexOfTerm:leftMostTerm]]];
			
		}
	}
	
	return nil;
}

- (Term *) copyFactoringAPowerWithBase:(Term *) base andPower: (Power *) power withTarget: (Term *) target {
	
	// base and power may be in a multiplication
	
	// some convenience variables
	BOOL baseIsInMulti = [[base parentTerm] isKindOfClass:[Multiplication class]];
	BOOL powerIsInMulti = [[power parentTerm] isKindOfClass:[Multiplication class]];
	
	Term *baseImmediateTerm = baseIsInMulti ? [base parentTerm] : base;
	Term *powerImmediateTerm = powerIsInMulti ? [power parentTerm] : power;
	
	Term *sourceTerm = (target == baseImmediateTerm) ? powerImmediateTerm : baseImmediateTerm;
	Term *leftMostTerm  = [self leftMostTermOf:baseImmediateTerm and:powerImmediateTerm];
	Term *rightMostTerm = [self rightMostTermOf:baseImmediateTerm and:powerImmediateTerm];
	
	// create the base term used in the addition
	Term *baseAdditionTerm;
	if (baseIsInMulti) {
		baseAdditionTerm = [[(Multiplication *)[base parentTerm] copyRemovingTerm:base] autorelease];
	}
	else {
		baseAdditionTerm = [[[Integer alloc] initWithInt:1] autorelease];
	}
	if ([base isOpposite]) {
		[baseAdditionTerm opposite];
	}
	
	// create the power term used in the addtion
	Term *powerAdditionTerm;
	if (powerIsInMulti) {
		Power *newPower = [[power copyDecrementingExponent] autorelease];
		powerAdditionTerm = [[(Multiplication *) powerImmediateTerm copyReplacingTerm:power withTerm:newPower] autorelease];
	}
	else {
		powerAdditionTerm = [[power copyDecrementingExponent] autorelease];
	}
	
	// create the new addition retaining term order
	Addition *newAdd;
	if (leftMostTerm == base || leftMostTerm == [base parentTerm]) {
		
		newAdd = [[[Addition alloc] init:baseAdditionTerm, powerAdditionTerm, nil] autorelease]; 
	}
	else {
		newAdd = [[[Addition alloc] init:powerAdditionTerm, baseAdditionTerm, nil] autorelease]; 
	}
		
	// if one or the other of the two terms being added are subtractions new addition will be subtraction
	if ([self getOperatorAtIndex:[self indexOfTerm:leftMostTerm]] == SUBTRACTION_OPERATOR ^
		[self getOperatorAtIndex:[self indexOfTerm:rightMostTerm]] == SUBTRACTION_OPERATOR) {
		[newAdd setOperator:SUBTRACTION_OPERATOR atIndex:1];
	}
	
	// the factored base in the multiplication will not be negative
	Multiplication *newMulti = [[[Multiplication alloc] init:base, newAdd, nil] autorelease];
	[[newMulti termAtIndex:0] setIsOpposite:NO];
	
	// copy and return
	return [self copyRemovingTerm:sourceTerm 
				 andReplacingTerm:target 
						 withTerm:newMulti 
					 withOperator:[self getOperatorAtIndex:[self indexOfTerm:leftMostTerm]]];
	
}

- (Term	*) factorPowersWithSource:(Term *) source andTarget:(Term *) target {
	
	// pointers to the base terms in the addends 
	Term *sourceBaseTerm = [source isKindOfClass:[Power class]] ? [(Power *) source base] : source;
	Term *targetBaseTerm = [target isKindOfClass:[Power class]] ? [(Power *) target base] : target;
	
	// base terms must be equal
	if (![sourceBaseTerm isEquivalentIgnoringSign:targetBaseTerm]) {
		return nil;
	}
	
	// negated base terms cannot be factored (e.g. (-x)^2
	if (([source isKindOfClass:[Power class]] && [sourceBaseTerm isOpposite]) ||
		([target isKindOfClass:[Power class]] && [targetBaseTerm isOpposite])) {
		
		return nil;
	}
	
	// figure out the "state" of the powers
	// base        = term is equivalent to the base of the power selected in the other term
	// baseInMult  = same as "base" but the base is in a multiplication
	// power       = addend is a power and the base term is the base of that power
	// powerInMult = same as "power" but the power is in a multiplication
	enum  CaseState {
		base, baseInMulti, power, powerInMult, none
	} ;
	enum CaseState sourceState = none;
	enum CaseState targetState = none;
	
	// determine "state" of source and set the immediate source pointer
	Term *immediateSource;
	if ([[sourceBaseTerm parentTerm] isKindOfClass:[Power class]]) {
		
		if ([self isImmediateSubTerm:[sourceBaseTerm parentTerm]]) {
			sourceState = power;
			immediateSource = [sourceBaseTerm parentTerm];
		}
		else if ([[[sourceBaseTerm parentTerm] parentTerm] isKindOfClass:[Multiplication class]] && [self isImmediateSubTerm:[[sourceBaseTerm parentTerm] parentTerm]]) {
			sourceState = powerInMult;
			immediateSource = [[sourceBaseTerm parentTerm] parentTerm];
		}
	}
	else {
		if ([self isImmediateSubTerm:source]) {
			sourceState = base;
			immediateSource = source;

		}
		else if ([[sourceBaseTerm parentTerm] isKindOfClass:[Multiplication class]] && [self isImmediateSubTerm:[sourceBaseTerm parentTerm]]) {
			sourceState = baseInMulti;
			immediateSource = [sourceBaseTerm parentTerm];
		}
	}
	
	// repeat for target 
	Term *immediateTarget;
	if ([[targetBaseTerm parentTerm] isKindOfClass:[Power class]]) {
		
		if ([self isImmediateSubTerm:[targetBaseTerm parentTerm]]) {
			targetState = power;
			immediateTarget = [targetBaseTerm parentTerm];
		}
		else if ([[[targetBaseTerm parentTerm] parentTerm] isKindOfClass:[Multiplication class]] && [self isImmediateSubTerm:[[targetBaseTerm parentTerm] parentTerm]]) {
			targetState = powerInMult;
			immediateTarget = [[targetBaseTerm parentTerm] parentTerm];
		}
	}
	else {
		if ([self isImmediateSubTerm:targetBaseTerm]) {
			targetState = base;
			immediateTarget = target;

		}
		else if ([[targetBaseTerm parentTerm] isKindOfClass:[Multiplication class]] && [self isImmediateSubTerm:[targetBaseTerm parentTerm]]) {
			targetState = baseInMulti;
			immediateTarget = [targetBaseTerm parentTerm];
		}
	}
	
	// both numerator and denominator term states must be valid
	if (sourceState == none || targetState == none) {
		return nil;
	}
	
	// Case 1: base/power, power/base either of which may be in a multiplication
	// x + x^2 to x*(1 + x)
	if ((sourceState == base || sourceState == baseInMulti) && (targetState == power || targetState == powerInMult)) {
		
		return [self copyFactoringAPowerWithBase:sourceBaseTerm andPower:(Power *) [targetBaseTerm parentTerm] withTarget:immediateTarget];
	}
	else if ((targetState == base || targetState == baseInMulti) && (sourceState == power || sourceState == powerInMult)) {
		
		return [self copyFactoringAPowerWithBase:targetBaseTerm andPower:(Power *) [sourceBaseTerm parentTerm] withTarget:immediateTarget];
	}
	
	// Case 2: power/power, either of which may be in a multiplication
	// x^3 + x^2 to x^2*(x + 1)
	if ((sourceState == power || sourceState == powerInMult) && (targetState == power || targetState == powerInMult)) {
		
		return [self copyFactoringPower:(Power *) [sourceBaseTerm parentTerm] andPower:(Power *) [targetBaseTerm parentTerm] withTarget:immediateTarget];
	}

	return nil;
}

// is term of the form 2*x where 2 is any integer and x is any term
- (BOOL) isForm2xX: (Term *) t {
	
	if (![t isKindOfClass:[Multiplication class]]) {
		return NO;
	}
	
	Multiplication *m = (Multiplication *) t;
	
	return [m count] == 2 && 
		(([[m termAtIndex:0] isKindOfClass:[Integer class]] && ![[m termAtIndex:1] isKindOfClass:[Integer class]]) ||
		 ([[m termAtIndex:1] isKindOfClass:[Integer class]] && ![[m termAtIndex:0] isKindOfClass:[Integer class]]));
}

- (Term *) copyReducingWithSubTerm:(Term *) source andSubTerm:(Term *) target {

	if ([self isImmediateSubTerm:source] && [self isImmediateSubTerm:target]) {
		
		// mark the source and target signs
		// blah - s - t = (blah + -s + -t)
		// blah - s + t = (blah + -s +  t)
		// blah + s + t = (blah +  s +  t)
		// blah + s - t = (blah +  s + -t)
		NSInteger sourceSign = ([self getOperatorAtIndex:[self indexOfTerm:source]])== ADDITION_OPERATOR ? 1 : -1 ;
		NSInteger targetSign = ([self getOperatorAtIndex:[self indexOfTerm:target]])== ADDITION_OPERATOR ? 1 : -1 ;
		
		if ([source isKindOfClass:[Integer class]] && [target isKindOfClass:[Integer class]]) {
			
            // check for overflow -MAX_INTEGER to MAX_INTEGER
            NSInteger x = [(Integer *) source rawValue]*sourceSign;
            NSInteger y = [(Integer *) target rawValue]*targetSign;
            long z = x + y;
            
            if (z > MAX_INTEGER || z < -MAX_INTEGER) {
                return nil;
            }
            
			// create a new integer term by adding/subtracting the source (s) and target (t) terms
			Integer *i = [[[Integer alloc]initWithInt:(((Integer *) source).rawValue * sourceSign + ((Integer *) target).rawValue * targetSign)] autorelease];
			
			// two terms in parent?
			if ([termList count] == 2) {
				
				return [i retain];
			}
			// replace source and target with new term
			else {
				
				return [self copyRemovingTerm:source andReplacingTerm:target withTerm:i];
			}
		}
		
		// add real numbers
		else if ([source isKindOfClass:[RealNumber class]] && [target isKindOfClass:[RealNumber class]]) {
			
			RealNumber *rn = [[[RealNumber alloc]initWithInt:(((RealNumber *) source).rawValue + ((RealNumber *) target).rawValue)] autorelease];
			
			// only two terms?
			if ([termList count] == 2) {
				
				return [rn retain];
			}
			// replace source and target with new term
			else {
				return [self copyRemovingTerm:source andReplacingTerm:target withTerm:rn];
			}
		}
		
		// add zero integer source term
		else if (([source isKindOfClass:[Integer class]] && [(Integer *) source rawValue] == 0) ||
                 ([target isKindOfClass:[Integer class]] && [(Integer *) target rawValue] == 0)) {
				
                
            BOOL sourceIsZero = [source isKindOfClass:[Integer class]] && [(Integer *) source rawValue] == 0;
            Integer *zeroTerm = sourceIsZero ? (Integer *) source : (Integer *) target;
            
			// copy the parent term
			Addition *newAdditionTerm = [[self copy] autorelease];
			
			// remove the zero term
			[newAdditionTerm removeTermAtIndex:[self indexOfTerm:zeroTerm]];
			
			// if the zero term was in the first position, make sure the new first term is not being subtracted
			if ([newAdditionTerm getOperatorAtIndex:0] == SUBTRACTION_OPERATOR) {
				
				[newAdditionTerm setOperator:ADDITION_OPERATOR atIndex:0];
				[[newAdditionTerm termAtIndex:0] opposite];
			}
			
			if ([newAdditionTerm count] == 1) {
				
				[[newAdditionTerm termAtIndex:0] setParentTerm:nil];
				return [[newAdditionTerm termAtIndex:0] copy];
			}
			else {
				return [newAdditionTerm retain];
			}
		}
				
		// infinity
		else if ([source isEquivalent:[Constant infinity]] || [target isEquivalent:[Constant infinity]]) {
			
			return [[Constant infinity] copy];
		}

		// add two term multiplications of the form i1*x + i2*x
		// where i is any integer and x is any equivalent term
		else if([self isForm2xX:source] && [self isForm2xX:target]){
		
			Multiplication *s = (Multiplication *) source;
			Multiplication *t = (Multiplication *) target;
			
			// get the raw integer values and note the non-integer term
			int sInt;
			int tInt;
			Term *sNonInt;
			Term *tNonInt;
			if ([[s termAtIndex:0] isKindOfClass:[Integer class]]) {
				
				sInt = [(Integer *) [s termAtIndex:0] rawValue];
				sNonInt = [s termAtIndex:1];
				
			}
			else {
				sInt = [(Integer *) [s termAtIndex:1] rawValue];
				sNonInt = [s termAtIndex:0];
			}
			if ([[t termAtIndex:0] isKindOfClass:[Integer class]]) {
				
				tInt = [(Integer *) [t termAtIndex:0] rawValue];
				tNonInt = [t termAtIndex:1];
				
			}
			else {
				tInt = [(Integer *) [t termAtIndex:1] rawValue];
				tNonInt = [t termAtIndex:0];
			}
			
			// ensure non-integer terms are equivalent
			if ([sNonInt isEquivalent:tNonInt]) {
				
				// take the opposite if multiplication term is being subtracted
				if ([self getOperatorAtIndex:[self indexOfTerm:source]] == SUBTRACTION_OPERATOR){
					
					sInt *= -1;
				}
				if ([self getOperatorAtIndex:[self indexOfTerm:target]] == SUBTRACTION_OPERATOR){
					
					tInt *= -1;
				}
				
				// create the new multiplication
				Integer *i = [[[Integer alloc] initWithInt:(sInt + tInt)] autorelease];
				Multiplication *newMult = [[[Multiplication alloc] init: i, sNonInt, nil] autorelease];
				
				// return new term
				return [self copyRemovingTerm:source andReplacingTerm:target withTerm:newMult];
				
			}			
            // otherwise swap terms
            else {
                
                Addition *temp = [self copy];
                [temp exchangeTerm:[self indexOfTerm:source] andTerm:[self indexOfTerm:target]];
                return temp;
            }
		}
		
		// Add  "equivalent" terms (first x is source, second x is target)
		else if ([source isEquivalentIgnoringSign:target]) {
				
			// our new variables
			int	  newOperator;
			Term *t;
			
			// make zero and 2x terms once
			Integer		   *zero = [[[Integer alloc] initWithInt:0] autorelease];
			
			// copy the source term and add to the "twoX" term
			Term   *newX = [[source copy] autorelease];
			if ([source isKindOfClass:[SymbolicTerm class]] || [source isKindOfClass:[Power class]]) {
				[(SymbolicTerm *) newX setIsOpposite:NO];	// the 2 might be negative, but not the "x", so reset
			}
			Multiplication *twoX = [[[Multiplication alloc] init:[[[Integer alloc] initWithInt:2] autorelease], newX, nil] autorelease];
			
			// determine the new term operator and addition results
			// Here are expected results for all permutations of the term sign and operator
			// blah -   x  -   x  = (blah - 2x)
			// blah - (-x) -   x  = (blah + 0)
			// blah -   x  - (-x) = (blah + 0)
			// blah - (-x) - (-x) = (blah + 2x)
			
			// blah -   x  +   x  = (blah + 0)
			// blah - (-x) +   x  = (blah + 2x)
			// blah -   x  + (-x) = (blah - 2x)
			// blah - (-x) + (-x) = (blah + 0)
			
			// blah +   x  +   x  = (blah + 2x)
			// blah + (-x) +   x  = (blah + 0)
			// blah +   x  + (-x) = (blah + 0)
			// blah + (-x) + (-x) = (blah - 2x)
			
			// blah +   x  -   x  = (blah + 0)
			// blah + (-x) -   x  = (blah - 2x)
			// blah +   x  - (-x) = (blah + 2x)
			// blah + (-x) - (-x) = (blah + 0)
			if ([self netOperator:source] == [self netOperator:target]) {
				t = twoX;
				newOperator = [self netOperator:source];
			}
			else {
				t = zero;
				newOperator = ADDITION_OPERATOR;
			}

			return [self copyRemovingTerm:source andReplacingTerm:target withTerm:t withOperator:newOperator];
		}
		
		// add fractions if denominators are equal
		else if ([source isKindOfClass:[Fraction class]] && [target isKindOfClass:[Fraction class]] && 
				 [[(Fraction *) source denominator] isEquivalent:[(Fraction *) target denominator]]) {
			
			Fraction *s = (Fraction *) source;
			Fraction *t = (Fraction *) target;
			
			BOOL sourceIdxIsLess = [self indexOfTerm:source] < [self indexOfTerm:target];
			
			// create the new fraction's numerator
			Addition *newNum;
			if (sourceIdxIsLess) {
				newNum   = [[[Addition alloc] init:[s numerator], nil] autorelease];
				if ((targetSign == -1 && sourceSign == 1) || (sourceSign == -1 && targetSign == 1)) {
					[newNum appendTerm:[t numerator] Operator: SUBTRACTION_OPERATOR];
				}
				else {
					[newNum appendTerm:[t numerator] Operator: ADDITION_OPERATOR];
				}
			}
			else {
				newNum   = [[[Addition alloc] init:[t numerator], nil] autorelease];
				if ((targetSign == -1 && sourceSign == 1) || (sourceSign == -1 && targetSign == 1)) {
					[newNum appendTerm:[s numerator] Operator: SUBTRACTION_OPERATOR];
				}
				else {
					[newNum appendTerm:[s numerator] Operator: ADDITION_OPERATOR];
				}
			}
			
			// create the fraction
			Fraction *newFrac = [[[Fraction alloc] initWithNum:newNum andDenom:[s denominator]] autorelease];
			
			// clean up and return
			if ([termList count] == 2) {
				
				return [newFrac retain];
			}
			else {
				if (( sourceIdxIsLess && [self getOperatorAtIndex:[self indexOfTerm:source]] == SUBTRACTION_OPERATOR) ||
					(!sourceIdxIsLess && [self getOperatorAtIndex:[self indexOfTerm:target]] == SUBTRACTION_OPERATOR)){

					return [self copyRemovingTerm:target andReplacingTerm:source withTerm:newFrac withOperator: SUBTRACTION_OPERATOR];
				}
				else {
					return [self copyRemovingTerm:source andReplacingTerm:target withTerm:newFrac];
				}
			}
		}
		
		// factor powers
		else if([source isKindOfClass:[Power class]] ||
				[target isKindOfClass:[Power class]] ||
				[[source parentTerm] isKindOfClass:[Power class]] ||
				[[target parentTerm] isKindOfClass:[Power class]] 
				) {
			
			return [self factorPowersWithSource:source andTarget:target];
		}
		
		// otherwise swap terms
		else {
			
			Addition *temp = [self copy];
			[temp exchangeTerm:[self indexOfTerm:source] andTerm:[self indexOfTerm:target]];
			return temp;
		}
	}
	
	// cross multiply fractions
	else if ([[source parentTerm] isKindOfClass:[Fraction class]] && [self isImmediateSubTerm:[source parentTerm]] &&
			 [[target parentTerm] isKindOfClass:[Fraction class]] && [self isImmediateSubTerm:[target parentTerm]]) {

		Fraction *sourceFraction = (Fraction *) [source parentTerm];
		Fraction *targetFraction = (Fraction *) [target parentTerm];
		
		if ([sourceFraction denominator] == source && [targetFraction denominator] == target) {
			
			// create the numerator
			Multiplication *m1 = [[[Multiplication alloc] init:[sourceFraction numerator], [targetFraction denominator], nil] autorelease];
			Multiplication *m2 = [[[Multiplication alloc] init:[targetFraction numerator], [sourceFraction denominator], nil] autorelease];
			Addition *newNum;
			if ([self indexOfTerm:sourceFraction] < [self indexOfTerm:targetFraction]) {
				newNum = [[[Addition alloc] init: m1, m2, nil] autorelease];
			}
			else {
				newNum = [[[Addition alloc] init: m2, m1, nil] autorelease];
			}
			
			// set the numerator's operator
			NSInteger sourceSign = ([self getOperatorAtIndex:[self indexOfTerm:sourceFraction]])== ADDITION_OPERATOR ? 1 : -1 ;
			NSInteger targetSign = ([self getOperatorAtIndex:[self indexOfTerm:targetFraction]])== ADDITION_OPERATOR ? 1 : -1 ;
			if ((targetSign == -1 && sourceSign == 1) || (sourceSign == -1 && targetSign == 1)) {
				[newNum setOperator:SUBTRACTION_OPERATOR atIndex:1];
			}
			
			// create the denominator
			Multiplication *newDenom = [[[Multiplication alloc] init: [sourceFraction denominator], [targetFraction denominator], nil] autorelease];
			
			// create the new fraction
			Fraction *newFact = [[[Fraction alloc] initWithNum:newNum andDenom:newDenom] autorelease];
			
			// replace the fractions and return
			return [self copyRemovingTerm:sourceFraction andReplacingTerm:targetFraction withTerm:newFact];			
		}
	}

	// factor powers
	else if([source isKindOfClass:[Power class]] ||
			[target isKindOfClass:[Power class]] ||
			[[source parentTerm] isKindOfClass:[Power class]] ||
			[[target parentTerm] isKindOfClass:[Power class]] 
	   ) {
		
		return [self factorPowersWithSource:source andTarget:target];
	}
	
	// factor a common term
	else {
		
		// find the parent terms
		// if term is a simple term, use self for parent
		Term *sourceParent = [source parentTerm] == self ? source : [source parentTerm];
		Term *targetParent = [target parentTerm] == self ? target : [target parentTerm];
		
		// if terms are integers, we can factor out the greatest common divisor 
		// e.g. 10x + 8x to 2(5x + 4x)
		int intGCD = 0;
		int intSource;
		int intTarget;
		if ([source isKindOfClass:[Integer class]] && [target isKindOfClass:[Integer class]]) {
			int gcd = [Term gcdX:[(Integer *) source rawValue] Y:[(Integer *) target rawValue]];
			if (gcd > 1 && ![source isEquivalentIgnoringSign:target]) {
				intGCD = gcd;
				intSource = [(Integer *) source rawValue]/gcd;
				intTarget = [(Integer *) target rawValue]/gcd;
			}
		}
		
		if ([source isEquivalentIgnoringSign:target] || intGCD) {
			
			if ([self canBeFactored:source] && [self canBeFactored:target]) {

				// flags for negative terms
				BOOL sourceIsNeg    = NO;
				BOOL targetIsNeg    = NO;
				if ([source isKindOfClass:[SymbolicTerm class]]) {
					sourceIsNeg    = [(SymbolicTerm *) source isOpposite];
				}
				else if ([source isKindOfClass:[Integer class]]) {
					sourceIsNeg    = [(Integer *) source rawValue] < 0;
				}
				else if ([source isKindOfClass:[RealNumber class]]) {
					sourceIsNeg    = [(RealNumber *) source rawValue] < 0;
				}
				
				if ([target isKindOfClass:[SymbolicTerm class]]) {
					targetIsNeg    = [(SymbolicTerm *) target isOpposite];
				}
				else if ([target isKindOfClass:[Integer class]]) {
					targetIsNeg    = [(Integer *) target rawValue] < 0;
				}
				else if ([target isKindOfClass:[RealNumber class]]) {
					targetIsNeg    = [(RealNumber *) target rawValue] < 0;
				}
				
				// create the multiplication for the factored term
				Multiplication *newMult = [[[Multiplication alloc] init] autorelease];
								
				// if the source is negative and the target is not 
				// we will factor out the positive term so take the opposite 
				if (sourceIsNeg && !targetIsNeg) {
					if (intGCD) {
						[newMult appendTerm:[[[Integer alloc] initWithInt:intGCD]  autorelease]];
					}
					else {
						Term	*newSource = [[source copy] autorelease];
						[newSource opposite];
						[newMult appendTerm:newSource];
					}

				}
				else {
					if (intGCD) {
						[newMult appendTerm:[[[Integer alloc] initWithInt:intGCD] autorelease]];
					}
					else {
						[newMult appendTerm:source];
					}
				}
				
				// find the index of source and target parents in the addition
				int sourceParentIndex = [self indexOfTerm:sourceParent];
				int targetParentIndex = [self indexOfTerm:targetParent];
				NSInteger leadingSign;
				
				// find the leading sign (if blah - 2x + 3x and source and target terms are 2x and 3x
				// leading sign is "-"
				if (sourceParentIndex < targetParentIndex) {
					
					leadingSign = ([self getOperatorAtIndex:[self indexOfTerm:sourceParent]])== ADDITION_OPERATOR ? 1 : -1 ;
				}
				else {
					
					leadingSign = ([self getOperatorAtIndex:[self indexOfTerm:targetParent]])== ADDITION_OPERATOR ? 1 : -1 ;
				}
				
				// create the new source and target terms
				Term *sourceMult;
				Term *targetMult;
				if (intGCD) {
					if (![sourceParent isSimpleTerm]) {
						sourceMult = [[(Multiplication *) sourceParent copyReplacingTerm:source withTerm:[[Integer alloc] initWithInt: intSource]] autorelease];
					}
					else {
						sourceMult = [[[Integer alloc] initWithInt: intSource] autorelease];
					}
					if (![targetParent isSimpleTerm]) {
						targetMult = [[(Multiplication *) targetParent copyReplacingTerm:target withTerm:[[Integer alloc] initWithInt: intTarget]] autorelease];
					}
					else {
						targetMult = [[[Integer alloc] initWithInt: intTarget] autorelease];
					}
				}
				else {
					sourceMult = [self factorOutTerm:source fromTerm:sourceParent];
					targetMult = [self factorOutTerm:target fromTerm:targetParent];
				}
				
				// if factoring out a negative term, and both source and target are not negative
				// take the opposite the remaining term
				if (sourceIsNeg && !targetIsNeg && !intGCD) {
					[sourceMult opposite];
				}
				if (!sourceIsNeg && targetIsNeg && !intGCD) {
					[targetMult opposite];
				}
				
				// create the factored addition
				Addition *newAdd = [[[Addition alloc] init] autorelease];
				if (sourceParentIndex < targetParentIndex) {
					[newAdd appendTerm:sourceMult];
					if (leadingSign == -1) {
						
						// switch the sign on the target if the source multiplication is subtracted
						NSInteger newSign = [self getOperatorAtIndex:targetParentIndex] == SUBTRACTION_OPERATOR ? ADDITION_OPERATOR : SUBTRACTION_OPERATOR;
						[newAdd appendTerm:targetMult Operator:newSign];
					}
					else {
						[newAdd appendTerm:targetMult Operator:[self getOperatorAtIndex:targetParentIndex]];
					}
					
				}
				else {
					[newAdd appendTerm:targetMult];
					if (leadingSign == -1) {
						
						// switch the sign on the source if the target multiplication is subtracted
						NSInteger newSign = [self getOperatorAtIndex:sourceParentIndex] == SUBTRACTION_OPERATOR ? ADDITION_OPERATOR : SUBTRACTION_OPERATOR;
						[newAdd appendTerm:sourceMult Operator:newSign];
					}
					else {
						[newAdd appendTerm:sourceMult Operator:[self getOperatorAtIndex:sourceParentIndex]];
					}
				}
				
				// append the second term to the new multiplication
				[newMult appendTerm:newAdd];
				
				// only two terms in the addition - completely replace
				if ([termList count] == 2) {
					
					return [newMult retain];
				}
				
				// other wise replace target term with new addition and remove term
				else {
					
					// copy the addition
					Addition *newTerm = [[self copy] autorelease];
					
					// remove source and target multiplication terms
					if (sourceParentIndex < targetParentIndex) {
						[newTerm removeTermAtIndex:targetParentIndex];
						[newTerm removeTermAtIndex:sourceParentIndex];
						[newTerm insertTerm:newMult atIndex:sourceParentIndex Operator:(leadingSign == -1 ? SUBTRACTION_OPERATOR : ADDITION_OPERATOR)];
						
					}
					else {
						[newTerm removeTermAtIndex:sourceParentIndex];
						[newTerm removeTermAtIndex:targetParentIndex];
						[newTerm insertTerm:newMult atIndex:targetParentIndex Operator:(leadingSign == -1 ? SUBTRACTION_OPERATOR : ADDITION_OPERATOR)];
					}
					
					return [newTerm retain];
				}
			}
		}			
	}
	
	return nil;
}

- (Term *) copyRemovingTerm: (Term *) term {
	
	// copy the parent term
	Addition *newAddition = [[self copy]  autorelease];
	
	// remove the source term
	[newAddition removeTermAtIndex:[self indexOfTerm:term]];
	
	// if first term is now being subtracted, take the opposite instead
	if ([newAddition getOperatorAtIndex:0] == SUBTRACTION_OPERATOR) {
		[newAddition setOperator:ADDITION_OPERATOR atIndex:0];
		
		[[newAddition termAtIndex:0] opposite];
	}
	
	if ([newAddition count] == 1) {
		
		return [[newAddition termAtIndex:0] copy];
	}
	return [newAddition retain];
}


- (Term *) copyRemovingTerm: (Term *) removeTerm 
			   andReplacingTerm: (Term *) replaceTerm 
					   withTerm: (Term *) newTerm
				   withOperator: (NSUInteger) oper {
	
	// copy the parent term
	Addition *newAddition = [[self copy]  autorelease];
	
	// find the index of the source and target terms
	int removeTermIndex = [self indexOfTerm:removeTerm];
	int replaceTermIndex = [self indexOfTerm:replaceTerm];
	
	// replace target term with new term
	[newAddition removeTermAtIndex:replaceTermIndex];
	if (replaceTermIndex == 0 && oper == SUBTRACTION_OPERATOR) {
		
		// if first term is now being subtracted, take the opposite instead
		Term *t = [[newTerm copy] autorelease];
		[t opposite];
		[newAddition insertTerm:t atIndex:replaceTermIndex Operator:ADDITION_OPERATOR];
		
	}
	else {
		[newAddition insertTerm:newTerm atIndex:replaceTermIndex Operator:oper];
	}
	
	// remove the source term
	[newAddition removeTermAtIndex:removeTermIndex];
	
	// if first term is now being subtracted, take the opposite instead
	if ([newAddition getOperatorAtIndex:0] == SUBTRACTION_OPERATOR) {
		[newAddition setOperator:ADDITION_OPERATOR atIndex:0];
		
		[[newAddition termAtIndex:0] opposite];
	}
	
	if ([newAddition count] == 1) {
		
		return [[newAddition termAtIndex:0] copy];
	}
	return [newAddition retain];
}


- (Term *) copyRemovingTerm: (Term *) removeTerm 
			   andReplacingTerm: (Term *) replaceTerm 
					   withTerm: (Term *) newTerm {
	
	return [self copyRemovingTerm:removeTerm andReplacingTerm:replaceTerm withTerm:newTerm withOperator: ADDITION_OPERATOR];
}

- (void) opposite {
	
	// take the opposite of each term
	for (Term *t in termList) {
		[t opposite];
	}
}

// TODO: consolidate addition and multiplication to eliminate redundancy
- (BOOL) isEquivalent:(Term *) term {
	
	// make sure were the same type
	if ([term isKindOfClass:[Addition class]]) {
		
		// cast term to addition for simplicity
		Addition *a = (Addition *) term;
		int termCount = [termList count];
		
		if ([a count] == termCount) {
			
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
						if ([[self termAtIndex:x] isEquivalent:[a termAtIndex:y]]) {
							
							// make sure the addition operators are the same
							if ([self getOperatorAtIndex:x] == [a getOperatorAtIndex:y]) {
								match[y] = 1;
								termMatched = YES;
							}
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

- (void) exchangeTerm: (NSUInteger) t1 andTerm: (NSUInteger) t2 {
	
	// cannot subtract the first term, so take the opposite of the term instead
	if (t1 == 0 && [self getOperatorAtIndex:t2] == SUBTRACTION_OPERATOR) {
		Term *temp1 = [[[termList objectAtIndex:t1] copy] autorelease];
		Term *temp2 = [[[termList objectAtIndex:t2] copy] autorelease];
		[temp2 opposite];
		[self removeTerm:[termList objectAtIndex:t1]];
		[self insertTerm:temp2 atIndex:t1];
		[self removeTerm:[termList objectAtIndex:t2]];
		[self insertTerm:temp1 atIndex:t2];
		
	}
	else if (t2 == 0 && [self getOperatorAtIndex:t1] == SUBTRACTION_OPERATOR) {
		Term *temp1 = [[[termList objectAtIndex:t1] copy] autorelease];
		Term *temp2 = [[[termList objectAtIndex:t2] copy] autorelease];
		[temp1 opposite];
		[self removeTerm:[termList objectAtIndex:t2]];
		[self insertTerm:temp1 atIndex:t2];
		[self removeTerm:[termList objectAtIndex:t1]];
		[self insertTerm:temp2 atIndex:t1];
	}
	else {
		[termList exchangeObjectAtIndex:t1 withObjectAtIndex:t2];
		[operatorList exchangeObjectAtIndex:t1 withObjectAtIndex:t2];
	}
}

- (void) dealloc {
	
	[operatorList autorelease];
	[super dealloc];
}

- (id) copyWithZone:(NSZone *) zone {
	
	Addition *newTerm = [[Addition	alloc] initWithTermValue:termValue];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:nil];
	[newTerm setColor:color];
	[newTerm setFont:font];
	
	// copy the term and operator list arrays
	Term *t;
	for (int x = 0; x < [termList count]; x++) {
		t = [(Term *)[termList objectAtIndex:x] copyWithZone:zone];
		[newTerm appendTerm:t Operator:[self getOperatorAtIndex:x]];
		[t release];
	}
	
	return newTerm;
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	
	[super encodeWithCoder:coder];
	[coder encodeObject:operatorList forKey:@"operatorList"];
	
}

- (id) initWithCoder:(NSCoder *)coder { 
	
	// Init first.
	if (self = [super initWithCoder:coder]) {
		
		operatorList = [[coder decodeObjectForKey:@"operatorList"] retain];
	}
	
	return self;
}

@end
