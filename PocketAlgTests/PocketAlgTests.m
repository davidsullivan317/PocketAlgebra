//
//  PocketAlgTests.m
//  PocketAlgTests
//
//  Created by davidsullivan on 10/15/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "PocketAlgTests.h"
#import "Term.h"
#import "Integer.h"
#import "RealNumber.h"
#import "Constant.h"
#import "Variable.h"		
#import "Multiplication.h"
#import "Addition.h"
#import "Power.h"
#import "Fraction.h"
#import "Summation.h"
#import "TermParser.h"

// flag to print all tests
#define PRINT_ALL_TESTS NO

@implementation PocketAlgTests

- (void) setUp {
    
    if (!parser) {
        parser = [[TermParser alloc] init];
    }
}

- (void) dealloc {
    
    NSLog(@"Total tests run: %i", testCount);

    [super dealloc];
    [parser release];
}

- (NSString *) runTestBefore: (NSString *) before	// a nil term string mean before or expected is nil
		expected: (NSString *) expected 
	  sourceTerm: (NSString *) source 
	  targetTerm: (NSString *) target {
	
	// increment the test count
	testCount++;
	
	// parse the before term
	Term *beforeTerm;
	if (before) {
		beforeTerm = [parser parseTerm:before];
		if ([parser parseError]) {
            return [NSString stringWithFormat:@"%Before term failed to parse: %@ Error was: %@", before, [parser errorMessage]];
		}
	}
	else {
		beforeTerm = nil;
	}
    
	// parse the expected term
	Term *expectedTerm;
	if (expected) {
		expectedTerm = [parser parseTerm:expected];
		if ([parser parseError]) {
            return [NSString stringWithFormat:@"Expected term failed to parse: %@ Error was: %@", expected, [parser errorMessage]];
		}
	}
	else {
		expectedTerm = nil;
	}
	
	// reduce the before term
	Term *afterTerm = [Term copyTerm:beforeTerm reducingWithSubTerm:[beforeTerm termAtPath:source] andSubTerm:[beforeTerm termAtPath:target]];
	
	// some basic checks:
	// after term should not have a parent
	if ([afterTerm parentTerm]) {
        
		return [NSString stringWithFormat:@"After term has parent! Before: %@ After: %@ Expected: %@", [beforeTerm printStringValue], [afterTerm printStringValue], [expectedTerm printStringValue]];
	}
	
	// check for equivalency with the after term
	if (!((expected == nil && afterTerm == nil) || [expectedTerm isEquivalent:afterTerm])) {
		
		return [NSString stringWithFormat:@"%Before: %@ After: %@ Expected: %@", [beforeTerm printStringValue], [afterTerm printStringValue], [expectedTerm printStringValue]];
	}
    
    return nil; // nil = passed
}

- (void) testMultiplicationMoveMultiplicandToNumeratorOfFraction {
	
	STAssertNil(resultsString =[self runTestBefore: @"2*(1/2)" expected: @"(2*1)/2" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"2*(1/2)" expected: @"(2*1)/2" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"(1/2)*2" expected: @"1" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(1/2)*2" expected: @"1" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"(1/3)*2" expected: @"(1*2)/3" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(1/3)*2" expected: @"(1*2)/3" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"2*(1/2)*a" expected: @"((2*1)/2)*a" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"b*2*(1/2)*a" expected: @"b*((2*1)/2)*a" sourceTerm: @".1" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"b*2*(1/2)*a" expected: @"b*2*((1*a)/2)" sourceTerm: @".3" targetTerm: @".2.0"], resultsString);
}	

- (void) testMultiplicationByZero {
	
	// times 1
	STAssertNil(resultsString =[self runTestBefore: @"1*0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0*1" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	// times an integer
	STAssertNil(resultsString =[self runTestBefore: @"13*0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1231*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0*14" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0*(-6)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// times a constant
	STAssertNil(resultsString =[self runTestBefore: @"0*c" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// in any position
	STAssertNil(resultsString =[self runTestBefore: @"0*c*4*99" expected: @"0" sourceTerm: @".0" targetTerm: @".3"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0*c*4*99" expected: @"0" sourceTerm: @".3" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*0*4*99" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*0*4*99" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*0*4*99" expected: @"0" sourceTerm: @".3" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*0*4*99" expected: @"0" sourceTerm: @".1" targetTerm: @".3"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*4*99*0" expected: @"0" sourceTerm: @".3" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*4*99*0" expected: @"0" sourceTerm: @".3" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*4*99*0" expected: @"0" sourceTerm: @".0" targetTerm: @".3"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*4*99*0" expected: @"0" sourceTerm: @".1" targetTerm: @".3"], resultsString);
	
	// times a power
	STAssertNil(resultsString =[self runTestBefore: @"c^2*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^2*0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0*c^2" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0*c^2" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
	// times a variable
	STAssertNil(resultsString =[self runTestBefore: @"0*x" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// times a power
	STAssertNil(resultsString =[self runTestBefore: @"0*x^2" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0*(-(x^3))" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
}

- (void) testMultiplicationOfInteger {
	
	STAssertNil(resultsString =[self runTestBefore: @"1*1" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2*1" expected: @"2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2*3" expected: @"6" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"100*100" expected: @"10000" sourceTerm: @".0" targetTerm: @".1"], resultsString);

	STAssertNil(resultsString =[self runTestBefore: @"-1*1" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2*1" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2*3" expected: @"-6" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-100*100" expected: @"-10000" sourceTerm: @".0" targetTerm: @".1"], resultsString);

	STAssertNil(resultsString =[self runTestBefore: @"1*(-1)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2*(-1)" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2*(-3)" expected: @"-6" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"100*(-100)" expected: @"-10000" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
    // check for overflow
	STAssertNil(resultsString =[self runTestBefore: @"10000*100000" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"10000*(-100000)" expected:nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"10000*10000" expected: @"100000000" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"10000*(-10000)" expected: @"-100000000" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"999999999*1" expected: @"999999999" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"999999999*(-1)" expected: @"-999999999" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
}

- (void) testMultiplicationByOneAndNegativeOne {
	
	// times integers
	STAssertNil(resultsString =[self runTestBefore: @"1*1" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"12*1" expected: @"12" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1*(-1)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-1*10" expected: @"-10" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-1*1" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
	// times fractions
	STAssertNil(resultsString =[self runTestBefore: @"(1/2)*1" expected: @"1/2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(1/2)*1" expected: @"1/2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1*(1/2)" expected: @"1/2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-1*(1/2)" expected: @"-1/2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(1/2)*(-1)" expected: @"-1/2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(1/2)*(-1)" expected: @"-1/2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-1*(1/2)" expected: @"-1/2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-1*(1/2)" expected: @"-1/2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	// times addition
	STAssertNil(resultsString =[self runTestBefore: @"(1 + 2)*1" expected: @"1 + 2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(1 + 2)*1" expected: @"1 + 2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1*(1 + 2)" expected: @"1 + 2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1*(1 + 2)" expected: @"1 + 2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(1 + 2)*(-1)" expected: @"-1 + (-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(1 + 2)*(-1)" expected: @"-1 + (-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-1)*(1 + 2)" expected: @"-1 + (-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-1)*(1 + 2)" expected: @"-1 + (-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// times a constant
	STAssertNil(resultsString =[self runTestBefore: @"1*c" expected: @"c" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1*c" expected: @"c" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*(-1)" expected: @"-c" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c*(-1)" expected: @"-c" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// times a variable
	STAssertNil(resultsString =[self runTestBefore: @"1*x" expected: @"x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1*x" expected: @"x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*(-1)" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*(-1)" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// times a power
	STAssertNil(resultsString =[self runTestBefore: @"1*x^2" expected: @"x^2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-1*x^2" expected: @"-(x^2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
}

- (void) testMultiplicationOfSymbolicTerms {
	
	STAssertNil(resultsString =[self runTestBefore: @"x*x" expected: @"x^2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x*x" expected: @"-(x^2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*(-x)" expected: @"-(x^2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-x)*(-x)" expected: @"x^2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"x*x*x" expected: @"x*x^2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x*x*x" expected: @"-(x^2)*x" sourceTerm: @".0" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*x*(-x)" expected: @"-(x^2)*x" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*(-x)*(-x)" expected: @"x*x^2" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(-x)*(x^2)" expected: @"-(x^(2+1))" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-x)*(-(x^2))" expected: @"x^(2+1)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
}

- (void) testMultiplicationReduceMultiplicandsWithFractionDenominator {
	
	STAssertNil(resultsString =[self runTestBefore: @"a*b*(b/a)" expected: @"b*b" sourceTerm: @".0" targetTerm: @".2.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*b*(b/a)" expected: @"b*b" sourceTerm: @".2.1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"a*(b/a)*b" expected: @"b*b" sourceTerm: @".0" targetTerm: @".1.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(b/a)*b" expected: @"b*b" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(b/a)*a*b" expected: @"b*b" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(b/a)*a*b" expected: @"b*b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
}

- (void) testMultiplicationReduceTermsInFractionMultiplicands {
	
	STAssertNil(resultsString =[self runTestBefore: @"(a/b)*(b/a)" expected: @"(1/b)*b" sourceTerm: @".0.0" targetTerm: @".1.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a/b)*(b/a)" expected: @"(1/b)*b" sourceTerm: @".1.1" targetTerm: @".0.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a/b)*(b/a)" expected: @"a*(1/a)" sourceTerm: @".0.1" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a/b)*(b/a)" expected: @"a*(1/a)" sourceTerm: @".1.0" targetTerm: @".0.1"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"(a/(-b))*(b/a)" expected: nil sourceTerm: @".0.1" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a/b)*((-b)/a)" expected: nil sourceTerm: @".1.0" targetTerm: @".0.1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a/(b*c))*(b/a)" expected: @"(a/c)*(1/a)" sourceTerm: @".0.1.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a/(b*c))*(b/a)" expected: @"(a/c)*(1/a)" sourceTerm: @".1.0" targetTerm: @".0.1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((a*b)/c)*(a/b)" expected: @"(a/c)*a" sourceTerm: @".0.0.1" targetTerm: @".1.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((a*b)/c)*(a/b)" expected: @"(a/c)*a" sourceTerm: @".1.1" targetTerm: @".0.0.1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((a*b)/c)*((a*d)/b)" expected: @"(a/c)*a*d" sourceTerm: @".0.0.1" targetTerm: @".1.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((a*b)/c)*((a*d)/b)" expected: @"(a/c)*a*d" sourceTerm: @".1.1" targetTerm: @".0.0.1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((x*a)/b)*((y*b)/a)" expected: @"x*a*(y/a)" sourceTerm: @".0.1" targetTerm: @".1.0.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((x*a)/b)*((y*b)/a)" expected: @"x*a*(y/a)" sourceTerm: @".1.0.1" targetTerm: @".0.1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((x*a*b)/b)*((y*b)/a)" expected: @"x*a*b*(y/a)" sourceTerm: @".0.1" targetTerm: @".1.0.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((x*a*b)/b)*((y*b)/a)" expected: @"x*a*b*(y/a)" sourceTerm: @".1.0.1" targetTerm: @".0.1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((x*a)/b)*((y*b*x)/a)" expected: @"x*a*(y*x/a)" sourceTerm: @".0.1" targetTerm: @".1.0.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((x*a)/b)*((y*b*x)/a)" expected: @"x*a*(y*x/a)" sourceTerm: @".1.0.1" targetTerm: @".0.1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((x*a)/(b*x))*((y*b*x)/a)" expected: @"((x*a)/x)*(y*x/a)" sourceTerm: @".0.1.0" targetTerm: @".1.0.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((x*a)/(b*x))*((y*b*x)/a)" expected: @"((x*a)/x)*(y*x/a)" sourceTerm: @".1.0.1" targetTerm: @".0.1.0"], resultsString);
	
}	

- (void) testMultiplicationOfPowers {
	
	STAssertNil(resultsString =[self runTestBefore: @"(a^0)*(a^0)" expected: @"a^(0+0)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a^0)*(a^0)" expected: @"a^(0+0)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a^1)*(a^0)" expected: @"a^(1+0)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a^0)*(a^1)" expected: @"a^(0+1)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a^2)*(a^2)" expected: @"a^(2+2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a^2)*(a^2)" expected: @"a^(2+2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-(a^2)*(a^2)" expected: @"-(a^(2+2))" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a^2)*(-(a^2))" expected: @"-(a^(2+2))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-(a^2)*(-(a^2))" expected: @"a^(2+2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-(a^2)*(-(a^2))" expected: @"a^(2+2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(-a)^2*(-a)^2" expected: @"(-a)^(2+2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-a)^2*a^2" expected: @"(a*(-a))^2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a^2)*a" expected: @"a^(2 + 1)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*(a^2)" expected: @"-(a^(2 + 1))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((-a)^0)*((-a)^0)" expected: @"(-a)^(0+0)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((-a)^0)*((-a)^0)" expected: @"(-a)^(0+0)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"((-a)^0)*(a^0)" expected: @"(-a*a)^0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a^0)*((-a)^0)" expected: @"(-a*a)^0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((-a)^1)*(a^2)" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a^2)*((-a)^1)" expected: nil sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"x^(2+1)*x^(3+4)" expected: @"x^(2+1+3+4)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x^(2*1)*x^(3*4)" expected: @"x^(2*1+3*4)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x^(2/1)*x^(3/4)" expected: @"x^(2/1+3/4)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x^(x^2)*x^(x^2)" expected: @"x^(x^2+x^2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
}

- (void) testMultiplicationOfPowerByBase {
	
	STAssertNil(resultsString =[self runTestBefore: @"a*(a^0)" expected: @"a^(0+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(a^0)" expected: @"a^(0+1)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(a^0)" expected: @"a^(0+1)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(a^0)" expected: @"a^(0+1)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-a*(a^0)" expected: @"-(a^(0 + 1))" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*(a^0)" expected: @"-(a^(0 + 1))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-a*((-a)^0)" expected: @"(-a)^(0+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*((-a)^0)" expected: @"(-a)^(0+1)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*((-a)^0)" expected: @"(-a)^(0+1)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*((-a)^0)" expected: @"(-a)^(0+1)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-a*(-(a^2))" expected: @"a^(2+1)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(-(a^2))"  expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*(a^2)"    expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-a*((-a)^2)"    expected: @"(-a)^(2+1)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*(-((-a)^2))" expected: @"-((-a)^(2+1))" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"a*((-a)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(-((-a)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*((-a)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(-((-a)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"-a*(-(a^2))" expected: @"a^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(-(a^2))"  expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*(a^2)"    expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-a*((-a)^2)"    expected: @"(-a)^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*(-((-a)^2))" expected: @"-((-a)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"a*((-a)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(-((-a)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"-a*(-(a^2))" expected: @"a^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(-(a^2))"  expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a*(a^2)"    expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"3*((-3)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"3*(-((-3)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"3*((-3)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"3*(-((-3)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-3*(-(3^2))" expected: @"3^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"3*(-(3^2))"  expected: @"-(3^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-3*(3^2)"    expected: @"-(3^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-3*((-3)^2)"    expected: @"(-3)^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-3*(-((-3)^2))" expected: @"-((-3)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"3*((-3)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"3*(-((-3)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-3*(-(3^2))" expected: @"3^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"3*(-(3^2))"  expected: @"-(3^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-3*(3^2)"    expected: @"-(3^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*((-(x^2))^2)"    expected: @"(x*(-(x^2)))^2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*(-((-(x^2))^2))" expected: @"-((x*(-(x^2)))^2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*((-(x^2))^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*(-((-(x^2))^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-(x^2)*(-((x^2)^2))" expected: @"(x^2)^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*(-((x^2)^2))"  expected: @"-((x^2)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-(x^2)*((x^2)^2)"    expected: @"-((x^2)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-(x^2)*((-(x^2))^2)"    expected: @"(-(x^2))^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-(x^2)*(-((-(x^2))^2))" expected: @"-((-(x^2))^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*((-(x^2))^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*(-((-(x^2))^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-(x^2)*(-((x^2)^2))" expected: @"(x^2)^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*(-((x^2)^2))"  expected: @"-((x^2)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-(x^2)*((x^2)^2)"    expected: @"-((x^2)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
}

- (void) testMultiplicationMoveMultiplicandsToBaseOfExponenial {
	
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*(y^2)" expected: @"(x*y)^2" sourceTerm: @".0.1" targetTerm: @".1.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x^2)*(y^2)" expected: @"(x*y)^2" sourceTerm: @".1.1" targetTerm: @".0.1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(x^(2+1))*(y^(2+1))" expected: @"(x*y)^(2+1)" sourceTerm: @".1.1" targetTerm: @".0.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a*(x^2)*(y^2)" expected: @"a*(x*y)^2" sourceTerm: @".1.1" targetTerm: @".2.1"], resultsString);
}

- (void) testFractionNumAndDenomAreEquivalent {
	
	STAssertNil(resultsString =[self runTestBefore: @"a/a" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a/a" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"-a/a" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a/a" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"a/(-a)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a/(-a)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"(-a)/(-a)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-a)/(-a)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"1/1" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1/1" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"-1/1" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-1/1" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"1/(-1)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1/(-1)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(-1)/(-1)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-1)/(-1)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a + a)/(a + a)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a + a)/(a + a)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"(a*a)/(a*a)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a*a)/(a*a)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/(c^2)" expected: @"c^(2 - 2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/(c^2)" expected: @"c^(2 - 2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(1/2)/(1/2)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(1/2)/(1/2)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
}

- (void) testFractionTermInNumAndDenomReducesToOne {
	
	STAssertNil(resultsString =[self runTestBefore: @"a/(a*b)" expected: @"1/b" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a/(a*b)" expected: @"1/b" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"-a/(a*b)" expected: @"-1/b" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-a/(a*b)" expected: @"-1/b" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"a/((-a)*b)" expected: @"-1/b" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a/((-a)*b)" expected: @"-1/b" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"2/(2*b)" expected: @"1/b" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2/(2*b)" expected: @"1/b" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-2/(2*b)" expected: @"-1/b" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2/(2*b)" expected: @"-1/b" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"2/(-2*b)" expected: @"-1/b" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2/(-2*b)" expected: @"-1/b" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"a/(a*b*c)" expected: @"1/(b*c)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a/(a*b*c)" expected: @"1/(b*c)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"a/1" expected: @"a" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a/1" expected: @"a" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a*b)/a" expected: @"b" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a*b)/a" expected: @"b" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a*b*c)/a" expected: @"b*c" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a*b*c)/a" expected: @"b*c" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a*b*c)/(a*b*c)" expected: @"(a*b)/(a*b)" sourceTerm: @".0.2" targetTerm: @".1.2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a*b*c)/(a*b*c)" expected: @"(a*b)/(a*b)" sourceTerm: @".1.2" targetTerm: @".0.2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a*b*c)/(a*b*c)" expected: @"(a*c)/(a*c)" sourceTerm: @".0.1" targetTerm: @".1.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a*b*c)/(a*b*c)" expected: @"(a*c)/(a*c)" sourceTerm: @".1.1" targetTerm: @".0.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a*b*c)/(a*b*c)" expected: @"(b*c)/(b*c)" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a*b*c)/(a*b*c)" expected: @"(b*c)/(b*c)" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	
}

- (void) testFractionZerosInFractions {
	
    Fraction *f1;
    Integer *zero = [[Integer alloc] initWithInt:0];
    Constant *a = [[Constant alloc] initWithTermValue:@"a"];

	// a/0 throws exception
	BOOL testPassed = NO;
	@try { 
		f1 = [[Fraction alloc] initWithNum:a andDenom:zero];
	}
	@catch (NSException *exception) { 
		
		testPassed = YES;
	}
    STAssertTrue(testPassed, @"TEST did not throw exception");
	
	// 0/0 is unchanged
	testPassed = NO;
	@try { 
		f1 = [[Fraction alloc] initWithNum:zero andDenom:zero];
	}
	@catch (NSException *exception) { 
		
		testPassed = YES;
	}
    STAssertTrue(testPassed, @"TEST did not throw exception");
	
	STAssertNil(resultsString =[self runTestBefore: @"0/a" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0/a" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"0/1" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0/1" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
}

- (void) testFractionIntegerFractions {
	
	STAssertNil(resultsString =[self runTestBefore: @"2/2" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2/2" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"2/4" expected: @"1/2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2/4" expected: @"1/2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-2/4" expected: @"-1/2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2/4" expected: @"-1/2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"2/(-4)" expected: @"1/(-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2/(-4)" expected: @"1/(-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"4/2" expected: @"2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"4/2" expected: @"2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-4/2" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-4/2" expected: @"-2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"4/(-2)" expected: @"2/(-1)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"4/(-2)" expected: @"2/(-1)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"4/12" expected: @"1/3" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"4/12" expected: @"1/3" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"8/12" expected: @"2/3" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"8/12" expected: @"2/3" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-8/12" expected: @"-2/3" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-8/12" expected: @"-2/3" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"8/(-12)" expected: @"2/(-3)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"8/(-12)" expected: @"2/(-3)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
}

- (void) testFractionPowers {
	
	STAssertNil(resultsString =[self runTestBefore: @"1/a" expected: @"a^(-1)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"1/a" expected: @"a^(-1)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// powers are not equivalent
	STAssertNil(resultsString =[self runTestBefore: @"c^2/c^3" expected: @"c^(2-3)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^2/c^3" expected: @"c^(2-3)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"c^(a-h)/c^3" expected: @"c^(a-h-3)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^(a-h)/c^3" expected: @"c^(a-h-3)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"(x^2*3)/x^3" expected: @"(x^(2-3)*3)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x^2*3)/x^3" expected: @"(x^(2-3)*3)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"x^3/(x^2*3)" expected: @"(x^(3-2)/3)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x^3/(x^2*3)" expected: @"(x^(3-2)/3)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(x^4*3)/(x^2*3)" expected: @"((x^(4-2)*3)/3)" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x^4*3)/(x^2*3)" expected: @"((x^(4-2)*3)/3)" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	
}

- (void) testFractionReducePowersInNumOrDenom {
	
    // Case 1: base/power 
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^2)" expected: @"c^(1-2)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^2)" expected: @"c^(1-2)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^2)" expected: @"c^(1-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^2)" expected: @"c^(1-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^a)" expected: @"c^(1-a)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^a)" expected: @"c^(1-a)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^(1/2))" expected: @"c^(1-(1/2))" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^(1/2))" expected: @"c^(1-(1/2))" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^(1+2))" expected: @"c^(1-1-2)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^(1+2))" expected: @"c^(1-1-2)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^(x*y))" expected: @"c^(1-x*y)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/(c^(x*y))" expected: @"c^(1-x*y)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a+b+c)/((a+b+c)^2)" expected: @"(a+b+c)^(1-2)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a+b+c)/((a+b+c)^2)" expected: @"(a+b+c)^(1-2)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(3/4)/((3/4)^2)" expected: @"(3/4)^(1-2)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(3/4)/((3/4)^2)" expected: @"(3/4)^(1-2)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(3*4)/((3*4)^2)" expected: @"(3*4)^(1-2)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(3*4)/((3*4)^2)" expected: @"(3*4)^(1-2)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
	
	// Case 2: power/base 
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/c" expected: @"c^(2-1)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/c" expected: @"c^(2-1)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/c" expected: @"c^(2-1)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/c" expected: @"c^(2-1)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(c^a)/c" expected: @"c^(a-1)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^a)/c" expected: @"c^(a-1)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(c^(1/2))/c" expected: @"c^((1/2)-1)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^(1/2))/c" expected: @"c^((1/2)-1)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(c^(1+2))/c" expected: @"c^(1+2-1)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^(1+2))/c" expected: @"c^(1+2-1)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(c^(x*y))/c" expected: @"c^(x*y-1)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^(x*y))/c" expected: @"c^(x*y-1)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((a+b+c)^2)/(a+b+c)" expected: @"(a+b+c)^(2-1)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((a+b+c)^2)/(a+b+c)" expected: @"(a+b+c)^(2-1)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((3/4)^2)/(3/4)" expected: @"(3/4)^(2-1)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((3/4)^2)/(3/4)" expected: @"(3/4)^(2-1)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"((3*4)^2)/(3*4)" expected: @"(3*4)^(2-1)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((3*4)^2)/(3*4)" expected: @"(3*4)^(2-1)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	
	// Case 3: baseInMulti/power 
	STAssertNil(resultsString =[self runTestBefore: @"(c*d)/(c^2)" expected: @"c^(1-2)*d" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c*d)/(c^2)" expected: @"c^(1-2)*d" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c*d)/(c^2)" expected: @"c^(1-2)*d" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c*d)/(c^2)" expected: @"c^(1-2)*d" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	
	// Case 4: power/baseInMulti
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/(c*d)" expected: @"c^(2-1)/d" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/(c*d)" expected: @"c^(2-1)/d" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/(c*d)" expected: @"c^(2-1)/d" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^2)/(c*d)" expected: @"c^(2-1)/d" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	
	// Case 5: power/power
	STAssertNil(resultsString =[self runTestBefore: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"c^a/c^b" expected: @"c^(a-b)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^a/c^b" expected: @"c^(a-b)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"c^(1/2)/c^(2/3)" expected: @"c^(1/2-2/3)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^(1/2)/c^(2/3)" expected: @"c^(1/2-2/3)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"c^(1+2)/c^(2-3)" expected: @"c^(1+2-2+3)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^(1+2)/c^(2-3)" expected: @"c^(1+2-2+3)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"c^(1*2)/c^(2*3)" expected: @"c^(1*2-2*3)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^(1*2)/c^(2*3)" expected: @"c^(1*2-2*3)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// different bases
	STAssertNil(resultsString =[self runTestBefore: @"(a+b)^3/(a+b)^2" expected: @"(a+b)^(3-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a+b)^3/(a+b)^2" expected: @"(a+b)^(3-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a/b)^3/(a/b)^2" expected: @"(a/b)^(3-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a/b)^3/(a/b)^2" expected: @"(a/b)^(3-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a*b)^3/(a*b)^2" expected: @"(a*b)^(3-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a*b)^3/(a*b)^2" expected: @"(a*b)^(3-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(a^b)^3/(a^b)^2" expected: @"(a^b)^(3-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(a^b)^3/(a^b)^2" expected: @"(a^b)^(3-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// Case 6: powerInMulti/base
	STAssertNil(resultsString =[self runTestBefore: @"((c^2)*d)/c" expected: @"c^(2-1)*d" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((c^2)*d)/c" expected: @"c^(2-1)*d" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((c^2)*d)/c" expected: @"c^(2-1)*d" sourceTerm: @".0.0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((c^2)*d)/c" expected: @"c^(2-1)*d" sourceTerm: @".1" targetTerm: @".0.0.0"], resultsString);
	
	// Case 7: base/powerInMulti
	STAssertNil(resultsString =[self runTestBefore: @"c/((c^2)*d)" expected: @"c^(1-2)/d" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/((c^2)*d)" expected: @"c^(1-2)/d" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/((c^2)*d)" expected: @"c^(1-2)/d" sourceTerm: @".0" targetTerm: @".1.0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c/((c^2)*d)" expected: @"c^(1-2)/d" sourceTerm: @".1.0.0" targetTerm: @".0"], resultsString);
	
	// Case 8: powerInMulti/baseInMulti
	STAssertNil(resultsString =[self runTestBefore: @"((c^2)*d)/(c*d)" expected: @"(c^(2-1)*d)/d" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((c^2)*d)/(c*d)" expected: @"(c^(2-1)*d)/d" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((c^2)*d)/(c*d)" expected: @"(c^(2-1)*d)/d" sourceTerm: @".0.0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"((c^2)*d)/(c*d)" expected: @"(c^(2-1)*d)/d" sourceTerm: @".1.0" targetTerm: @".0.0.0"], resultsString);
    
	// Case 9: baseInMulti/powerInMulti
	STAssertNil(resultsString =[self runTestBefore: @"(c*d)/((c^2)*d)" expected: @"(c^(1-2)*d)/d" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c*d)/((c^2)*d)" expected: @"(c^(1-2)*d)/d" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c*d)/((c^2)*d)" expected: @"(c^(1-2)*d)/d" sourceTerm: @".0.0" targetTerm: @".1.0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c*d)/((c^2)*d)" expected: @"(c^(1-2)*d)/d" sourceTerm: @".1.0.0" targetTerm: @".0.0"], resultsString);
    
	// Case 10: powerInMulti/power
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".0.0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".1" targetTerm: @".0.0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".0.0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".1.0" targetTerm: @".0.0.0"], resultsString);
	
	// Case 11: power/powerInMulti
	STAssertNil(resultsString =[self runTestBefore: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".0" targetTerm: @".1.0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".1.0.0" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".0.0" targetTerm: @".1.0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".1.0.0" targetTerm: @".0.0"], resultsString);
	
	// Case 12: powerInMult/powerInMulti
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".0.0" targetTerm: @".1.0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".1.0.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".0.0.0" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".1.0" targetTerm: @".0.0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".0.0.0" targetTerm: @".1.0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".1.0.0" targetTerm: @".0.0.0"], resultsString);
	
}

- (void) testAdditionAddingSymbolicTermsInTwoTermAdditions {
	
	STAssertNil(resultsString =[self runTestBefore: @"a+a" expected: @"2*a" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a+a" expected: @"2*a" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"a-a" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"a-a" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-x+x" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x+x" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"x+(-x)" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x+(-x)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-x+(-x)" expected: @"-2*x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x+(-x)" expected: @"-2*x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"x-x" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x-x" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-x-x" expected: @"-2*x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x-x" expected: @"-2*x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"x-(-x)" expected: @"2*x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x-(-x)" expected: @"2*x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-x-(-x)" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x-(-x)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"0 + x" expected: @"x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0 + x" expected: @"x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x + 0" expected: @"x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x + 0" expected: @"x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"0 - x" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0 - x" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x - 0" expected: @"x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x - 0" expected: @"x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"0 - (-x)" expected: @"x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0 - (-x)" expected: @"x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x - 0" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x - 0" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"0 + (-x)" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0 + (-x)" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x + 0" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x + 0" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"0 - x + 1 " expected: @"-x + 1" sourceTerm: @".0" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0 - x + 1 " expected: @"1 - x" sourceTerm: @".2" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0 - x + 1 " expected: @"-x + 1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"0 - x + 1 " expected: @"-x + 1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
}

- (void) testAdditionAddingSymbolicTermsInThreeTermAdditions {
		
	STAssertNil(resultsString =[self runTestBefore: @"y + x + x" expected: @"y + 2*x" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x + x" expected: @"y + 2*x" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + x" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + x" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x + (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x + (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + (-x)" expected: @"y - 2*x" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + (-x)" expected: @"y - 2*x" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x + (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x + (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) - x" expected: @"y - 2*x" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) - x" expected: @"y - 2*x" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x - (-x)" expected: @"y + 2*x" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x - (-x)" expected: @"y + 2*x" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) - (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) - (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + x" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + x" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) + x" expected: @"y + 2*x" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) + x" expected: @"y + 2*x" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - x + (-x)" expected: @"y - 2*x" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - x + (-x)" expected: @"y - 2*x" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) + (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) + (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - x - (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - x - (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - x" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - x" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - (-x)" expected: @"y + 2*x" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - (-x)" expected: @"y + 2*x" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-x + x + (-x)" expected: @"x - 2*x" sourceTerm: @".0" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-x + x + (-x)" expected: @"-2*x + x" sourceTerm: @".2" targetTerm: @".0"], resultsString);
	
} 

- (void) testAdditionAddingSymbolicsTermsInFourTermAdditions {
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x + x - z" expected: @"y + 2*x - z" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x + x - z" expected: @"y + 2*x - z" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + x - z" expected: @"y + 0 - z" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + x - z" expected: @"y + 0 - z" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x + (-x) - z" expected: @"y + 0 - z" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x + (-x) - z" expected: @"y + 0 - z" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + (-x) - z" expected: @"y - 2*x - z" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + (-x) - z" expected: @"y - 2*x - z" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - x - x + z" expected: @"y - 2*x + z" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - x - x + z" expected: @"y - 2*x + z" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - x + z" expected: @"y + 0 + z" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - x + z" expected: @"y + 0 + z" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - x - (-x) + z" expected: @"y + 0 + z" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - x - (-x) + z" expected: @"y + 0 + z" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - (-x) + z" expected: @"y + 2*x + z" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - (-x) + z" expected: @"y + 2*x + z" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
}

- (void) testAdditionFactorTermFromTwoTermAddition {
    
	STAssertNil(resultsString =[self runTestBefore: @"x*y + x*y" expected: @"2*x*y" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*y + x*y" expected: @"2*x*y" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"x*y + x*y" expected: @"x*(y + y)" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*y + x*y" expected: @"x*(y + y)" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"x*y - x*y" expected: @"x*(y - y)" sourceTerm: @".1.0" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*y - x*y" expected: @"x*(y - y)" sourceTerm: @".0.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"x*y + x*y" expected: @"y*(x + x)" sourceTerm: @".1.1" targetTerm: @".0.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*y + x*y" expected: @"y*(x + x)" sourceTerm: @".0.1" targetTerm: @".1.1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"x*y - x*y" expected: @"y*(x - x)" sourceTerm: @".1.1" targetTerm: @".0.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x*y - x*y" expected: @"y*(x - x)" sourceTerm: @".0.1" targetTerm: @".1.1"], resultsString);
	
}

- (void) testAdditionFactorSymbolicTermsMixingPositiveAndNegativeTerms {
		
	STAssertNil(resultsString =[self runTestBefore: @"y + x*y + x*y" expected: @"y + x*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x*y + x*y" expected: @"y + x*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x*y - x*y" expected: @"y + x*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x*y - x*y" expected: @"y + x*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - x*y + x*y" expected: @"y - x*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - x*y + x*y" expected: @"y - x*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - x*y - x*y" expected: @"y - x*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - x*y - x*y" expected: @"y - x*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x*y + (-x)*y" expected: @"y + x*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x*y + (-x)*y" expected: @"y + x*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x*y - (-x)*y" expected: @"y + x*(y - (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x*y - (-x)*y" expected: @"y + x*(y - (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - x*y + (-x)*y" expected: @"y - x*(y - (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - x*y + (-x)*y" expected: @"y - x*(y - (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - x*y - (-x)*y" expected: @"y - x*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - x*y - (-x)*y" expected: @"y - x*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*y + x*y" expected: @"y + x*(-y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*y + x*y" expected: @"y + x*(-y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*y - x*y" expected: @"y + x*(-y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*y - x*y" expected: @"y + x*(-y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x)*y + x*y" expected: @"y - x*(-y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x)*y + x*y" expected: @"y - x*(-y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x)*y - x*y" expected: @"y - x*(-y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x)*y - x*y" expected: @"y - x*(-y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*y + (-x)*y" expected: @"y + (-x)*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*y + (-x)*y" expected: @"y + (-x)*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*y - (-x)*y" expected: @"y + (-x)*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*y - (-x)*y" expected: @"y + (-x)*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x)*y + (-x)*y" expected: @"y - (-x)*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x)*y + (-x)*y" expected: @"y - (-x)*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x)*y - (-x)*y" expected: @"y - (-x)*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x)*y - (-x)*y" expected: @"y - (-x)*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
}

- (void) testAdditionTestFactorIntegersMixingPositiveAndNegativeIntegers {
	
	STAssertNil(resultsString =[self runTestBefore: @"y + 2*y + 2*y" expected: @"y + 2*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + 2*y + 2*y" expected: @"y + 2*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + 2*y - 2*y" expected: @"y + 2*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + 2*y - 2*y" expected: @"y + 2*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - 10*y + 10*y" expected: @"y - 10*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - 10*y + y*10" expected: @"y - 10*(y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - 1*y - 1*y" expected: @"y - 1*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - 1*y - y*1" expected: @"y - 1*(y + y)" sourceTerm: @".2.1" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + 2*y + (-2)*y" expected: @"y + 2*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + 2*y + (-2)*y" expected: @"y + 2*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + 2*y + (-2)*y" expected: @"y + 2*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + 2*y + (-2)*y" expected: @"y + 2*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + 4*y - (-4)*y" expected: @"y + 4*(y - (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + 4*y - (-4)*y" expected: @"y + 4*(y - (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - 10*y + (-10)*y" expected: @"y - 10*(y - (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - 10*y + (-10)*y" expected: @"y - 10*(y - (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - 1*y - (-1)*y" expected: @"y - 1*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - 1*y - (-1)*y" expected: @"y - 1*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-2)*y + 2*y" expected: @"y + 2*(-y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-2)*y + y*2" expected: @"y + 2*(-y + y)" sourceTerm: @".2.1" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-4)*y - 4*y" expected: @"y + 4*(-y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-4)*y - y*4" expected: @"y + 4*(-y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-10)*y + 10*y" expected: @"y - 10*(-y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-10)*y + y*10" expected: @"y - 10*(-y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-1)*y - 1*y" expected: @"y - 1*(-y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-1)*y - y*1" expected: @"y - 1*(-y + y)" sourceTerm: @".2.1" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-2)*y + (-2)*y" expected: @"y + (-2)*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-2)*y + y*(-2)" expected: @"y + (-2)*(y + y)" sourceTerm: @".2.1" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-4)*y - (-4)*y" expected: @"y + (-4)*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-4)*y - y*(-4)" expected: @"y + (-4)*(y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-10)*y + (-10)*y" expected: @"y - (-10)*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-10)*y + y*(-10)" expected: @"y - (-10)*(y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y - (-1)*y - (-1)*y" expected: @"y - (-1)*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-1)*y - (-1)*y" expected: @"y - (-1)*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"-3 - x*9" expected: @"3*(-1 - x*3)" sourceTerm: @".0.0" targetTerm: @".1.1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-3 - x*9" expected: @"3*(-1 - x*3)" sourceTerm: @".1.1" targetTerm: @".0.0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"2*(x+6) - 14" expected: @"2*(x + 6 - 7)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2*(x+6) - 14" expected: @"2*(x + 6 - 7)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2*(x+6) + (-14)" expected: @"2*(x + 6 + (-7))" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2*(x+6) + (-14)" expected: @"2*(x + 6 + (-7))" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2*(x+6) - 14" expected: @"2*(-1*(x + 6) - 7)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2*(x+6) - 14" expected: @"2*(-1*(x + 6) - 7)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2*(x+6) + (-14)" expected: @"2*(-1*(x + 6) + (-7))" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2*(x+6) + (-14)" expected: @"2*(-1*(x + 6) + (-7))" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"2*(x+6) + 14" expected:nil sourceTerm: @".0.1.1" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2*(x+6) + 14" expected:nil sourceTerm: @".1" targetTerm: @".0.1.1"], resultsString);
}

- (void) testAdditionTestAddingOrFactoringPowers {
	
	// adding/factoring powers of the form y + n + n^2 = y + n*(1 + n) ++++");
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x^2" expected: @"y + 2*x^2" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x^2" expected: @"y + 2*x^2" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - x^2" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - x^2" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-(x^2)) + x^2" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-(x^2)) + x^2" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + (-(x^2))" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + (-(x^2))" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x" expected: @"y + x*(x + 1)" sourceTerm: @".1.0" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x" expected: @"y + x*(x + 1)" sourceTerm: @".2" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x" expected: @"y + x*(x + 1)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x" expected: @"y + x*(x + 1)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - x" expected: @"y + x*(x - 1)" sourceTerm: @".1.0" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - x" expected: @"y + x*(x - 1)" sourceTerm: @".2" targetTerm: @".1.0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - x" expected: @"y + x*(x - 1)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - x" expected: @"y + x*(x - 1)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + x + x^2" expected: @"y + x*(1 + x)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x + x^2" expected: @"y + x*(1 + x)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x - x^2" expected: @"y + x*(1 - x)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + x - x^2" expected: @"y + x*(1 - x)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + x^2" expected: @"y + x*(-1 + x)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) + x^2" expected: @"y - x*(-1 - x)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) - x^2" expected: @"y + x*(-1 - x)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - x^2" expected: @"y - x*(-1 + x)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + (-x^2)" expected: @"y + x*(-1 + (-x))" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) + (-x^2)" expected: @"y - x*(-1 - (-x))" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) - (-x^2)" expected: @"y + x*(-1 - (-x))" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - (-x^2)" expected: @"y - x*(-1 + (-x))" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) + (-x)^2" expected: nil sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y -   x  + (-x)^2" expected: nil sourceTerm: @".2" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y + (-x) - (-x)^2" expected: nil sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y -   x  - (-x)^2" expected: nil sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"x + x^2" expected: @"x*(1 + x)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"x - x^2" expected: @"x*(1 - x)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-x) + x^2" expected: @"x*(-1 + x)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-x) - x^2" expected: @"x*(-1 - x)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-x) + (-x^2)" expected: @"x*(-1 + (-x))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(-x) - (-x^2)" expected: @"x*(-1 - (-x))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"2 + 2^3" expected: @"2*(1 + 2^2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2 + 2^3" expected: @"2*(-1 + 2^2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"2 - 2^3" expected: @"2*(1 - 2^2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"-2 - 2^3" expected: @"2*(-1 - 2^2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - 2 + 2^3" expected: @"y - 2*(1 - 2^2)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-2) + 2^3" expected: @"y - 2*(-1 - 2^2)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - 2 - 2^3" expected: @"y - 2*(1 + 2^2)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (-2) - 2^3" expected: @"y - 2*(-1 + 2^2)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
	STAssertNil(resultsString =[self runTestBefore: @"(x*y) + (x*y)^3" expected: @"x*y*(1 + (x*y)^2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"(x*y) - (x*y)^3" expected: @"x*y*(1 - (x*y)^2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (x*y) + (x*y)^3" expected: @"y - x*y*(1 - (x*y)^2)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (x*y) - (x*y)^3" expected: @"y - x*y*(1 + (x*y)^2)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
    
	STAssertNil(resultsString =[self runTestBefore: @"y - (1/2) + (1/2)^3" expected: @"y - (1/2)*(1 - (1/2)^2)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	STAssertNil(resultsString =[self runTestBefore: @"y - (1/2) - (1/2)^3" expected: @"y - (1/2)*(1 + (1/2)^2)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
}

- (void) testAdditionFactoringPowers1 {
	
	// factoring powers of the form y + n*m + n^2 = y + n*(m + n)
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x*m" expected: @"y + x*(x + m)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x*m" expected: @"y + x*(x + m)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x*m" expected: @"y + x*(x + m)" sourceTerm: @".1" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x*m" expected: @"y + x*(x + m)" sourceTerm: @".2.0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"y - x^2 + x*m" expected: @"y - x*(x - m)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - x^2 + x*m" expected: @"y - x*(x - m)" sourceTerm: @".2.0" targetTerm: @".1.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - x*m" expected: @"y + x*(x - m)" sourceTerm: @".1" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - x*m" expected: @"y + x*(x - m)" sourceTerm: @".2.0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"y + m*(-x) + x^2" expected: @"y + x*(-m + x)" sourceTerm: @".1.1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - m*(-x) + x^2" expected: @"y - x*(-m - x)" sourceTerm: @".2" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + (-m)*(-x) - x^2" expected: @"y + x*(m - x)" sourceTerm: @".1.1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - (-m)*(-x) - x^2" expected: @"y - x*(m + x)" sourceTerm: @".2" targetTerm: @".1.1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"y + m*(-x) + (-x^2)" expected: @"y + x*(-m + (-x))" sourceTerm: @".1.1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - m*(-x) + (-x^2)" expected: @"y - x*(-m - (-x))" sourceTerm: @".2" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*(-m) - (-x^2)" expected: @"y + x*(m - (-x))" sourceTerm: @".1.0" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - (-x)*(-m) - (-x^2)" expected: @"y - x*(m + (-x))" sourceTerm: @".2" targetTerm: @".1.0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"y + m*(-x) + (-x)^2" expected: nil sourceTerm: @".1.1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y -  m*x  + (-x)^2" expected: nil sourceTerm: @".2" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + (-x)*(-m) - (-x)^2" expected: nil	sourceTerm: @".1.0" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - x*(-m)  - (-x)^2" expected: nil sourceTerm: @".2" targetTerm: @".1.0"], resultsString);
}

- (void) testAdditionFactoringPowers2 {
	
	// factoring powers of the form y + n*m + x*n^2 = y + n*(m + x*n) 
    STAssertNil(resultsString =[self runTestBefore: @"y + z*x^2 + x*m" expected: @"y + x*(z*x + m)" sourceTerm: @".1.1" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + z*x^2 + x*m" expected: @"y + x*(z*x + m)" sourceTerm: @".2.0" targetTerm: @".1.1.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2*z + x*m" expected: @"y + x*(x*z + m)" sourceTerm: @".1.0" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2*z + x*m" expected: @"y + x*(x*z + m)" sourceTerm: @".2.0" targetTerm: @".1.0.0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"y - z*x^2 + x" expected: @"y - x*(z*x - 1)" sourceTerm: @".1.1.0" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - x^2*z + x" expected: @"y - x*(z*x - 1)" sourceTerm: @".2" targetTerm: @".1.0.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + z*x^2 - x" expected: @"y + x*(x*z - 1)" sourceTerm: @".1.1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2*z - x" expected: @"y + x*(x*z - 1)" sourceTerm: @".2" targetTerm: @".1.0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"y + m*(-x) + z*(-x)^2" expected: nil sourceTerm: @".1.1" targetTerm: @".2.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y -  m*x  + (-x)^2*z" expected: nil sourceTerm: @".2.0" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + (-x) - z*(-x)^2" expected: nil sourceTerm: @".1" targetTerm: @".2.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - x - (-x)^2*z" expected: nil sourceTerm: @".2.0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"y + z*(a+b)^2 + (a+b)*m" expected: @"y + (a+b)*(z*(a+b) + m)" sourceTerm: @".1.1" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + z*(a/b)^2 + (a/b)*m" expected: @"y + (a/b)*(z*(a/b) + m)" sourceTerm: @".2.0" targetTerm: @".1.1.0"], resultsString);
	
}

- (void) testAdditionFactoringPowers3 {
	
	// factoring powers of the form y + n^3*m + x*n^2 = y + n^2*(n*m + x)
	
    STAssertNil(resultsString =[self runTestBefore: @"y + z*x^0 + x^1*m" expected: nil sourceTerm: @".2.0" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + z*x^1 + x^2*m" expected: @"y + x*(z + x*m)" sourceTerm: @".1.1" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + z*x^2 + x^3*m" expected: @"y + x^2*(z + x*m)" sourceTerm: @".2.0" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + z*x^3 + x^5*m" expected: @"y + x^3*(z + x^2*m)" sourceTerm: @".1.1" targetTerm: @".2.0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"y + x^0 + x^1" expected: nil sourceTerm: @".2" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^1 + x^2" expected: @"y + x*(1 + x)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 + x^3" expected: @"y + x^2*(1 + x)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^3 + x^5" expected: @"y + x^3*(1 + x^2)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"y - x^1 + x^2" expected: @"y - x*(1 - x)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - x^3" expected: @"y + x^2*(1 - x)" sourceTerm: @".2" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - x^3 - x^5" expected: @"y - x^3*(1 + x^2)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"y - (-x)^1 + x^2" expected: nil sourceTerm: @".1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - (-x)^3" expected: nil sourceTerm: @".2" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - x^3 - (-x)^5" expected: nil sourceTerm: @".1" targetTerm: @".2"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"y - (-(x^1)) + x^2" expected: @"y - x*(-1 - x)" sourceTerm: @".1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + x^2 - (-(x^3))" expected: @"y + x^2*(1 - (-x))" sourceTerm: @".2" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - x^3 - (-(x^5))" expected: @"y - x^3*(1 + (-(x^2)))" sourceTerm: @".1" targetTerm: @".2"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"y + z*(a+b)^0 + (a+b)^1*m" expected: nil sourceTerm: @".2.0" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + z*(a*b)^1 + (a*b)^2*m" expected: @"y + (a*b)*(z + a*b*m)" sourceTerm: @".1.1" targetTerm: @".2.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + z*(y^2)^2 + (y^2)^3*m" expected: @"y + (y^2)^2*(z + (y^2)*m)" sourceTerm: @".2.0" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y + z*(1/2)^3 + (1/2)^5*m" expected: @"y + (1/2)^3*(z + (1/2)^2*m)" sourceTerm: @".1.1" targetTerm: @".2.0"], resultsString);
	
}	

- (void) testAdditionFactorSymbolicTermsFromTwoTermAdditions1 {
    
	// factor symbolic terms, both terms have multiple terms, from two-term addition
    STAssertNil(resultsString =[self runTestBefore: @"y + z*(1/2)^3 + (1/2)^5*m" expected: @"y + (1/2)^3*(z + (1/2)^2*m)" sourceTerm: @".1.1" targetTerm: @".2.0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + x*y*z" expected: @"2*x*y*z" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + x*y*z" expected: @"2*x*y*z" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z - x*y*z" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z - x*y*z" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + z*y*x" expected: @"x*(y*z + z*y)" sourceTerm: @".0.0" targetTerm: @".1.2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + z*y*x" expected: @"x*(y*z + z*y)" sourceTerm: @".1.2" targetTerm: @".0.0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + z*y*x" expected: @"y*(x*z + z*x)" sourceTerm: @".0.1" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + z*y*x" expected: @"y*(x*z + z*x)" sourceTerm: @".1.1" targetTerm: @".0.1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + z*y*x" expected: @"z*(x*y + y*x)" sourceTerm: @".0.2" targetTerm: @".1.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + z*y*x" expected: @"z*(x*y + y*x)" sourceTerm: @".1.0" targetTerm: @".0.2"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z - z*y*x" expected: @"x*(y*z - z*y)" sourceTerm: @".0.0" targetTerm: @".1.2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z - z*y*x" expected: @"x*(y*z - z*y)" sourceTerm: @".1.2" targetTerm: @".0.0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z - z*y*x" expected: @"y*(x*z - z*x)" sourceTerm: @".0.1" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z - z*y*x" expected: @"y*(x*z - z*x)" sourceTerm: @".1.1" targetTerm: @".0.1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z - z*y*x" expected: @"z*(x*y - y*x)" sourceTerm: @".0.2" targetTerm: @".1.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z - z*y*x" expected: @"z*(x*y - y*x)" sourceTerm: @".1.0" targetTerm: @".0.2"], resultsString);
	
}

- (void) testAdditionFactorSymbolicTermsFromTwoTermAdditions2 {
	
	// factor symbolic terms, mixing single and multiple terms, from two-term addition
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + x" expected: @"x*(y*z + 1)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + x" expected: @"x*(y*z + 1)" sourceTerm: @".1" targetTerm: @".0.0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + y" expected: @"y*(x*z + 1)" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + y" expected: @"y*(x*z + 1)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + z" expected: @"z*(x*y + 1)" sourceTerm: @".0.2" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y*z + z" expected: @"z*(x*y + 1)" sourceTerm: @".1" targetTerm: @".0.2"], resultsString);

    STAssertNil(resultsString =[self runTestBefore: @"x - x*y*z" expected: @"x*(1 - y*z)" sourceTerm: @".0" targetTerm: @".1.0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x - x*y*z" expected: @"x*(1 - y*z)" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"y - x*y*z" expected: @"y*(1 - x*z)" sourceTerm: @".0" targetTerm: @".1.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - x*y*z" expected: @"y*(1 - x*z)" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"z - x*y*z" expected: @"z*(1 - x*y)" sourceTerm: @".0" targetTerm: @".1.2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"z - x*y*z" expected: @"z*(1 - x*y)" sourceTerm: @".1.2" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - 2*x" expected: @"y - x*(-1 + 2)" sourceTerm: @".1" targetTerm: @".2.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"y - (-x) - 2*x" expected: @"y - x*(-1 + 2)" sourceTerm: @".2.1" targetTerm: @".1"], resultsString);
	
}

- (void) testAdditionAddSimpleIntegers {
	
    STAssertNil(resultsString =[self runTestBefore: @"0 + 0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0 + 0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 + 0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 + 0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"0 + 1" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0 + 1" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"0 + (-1)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0 + (-1)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 + (-1)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 + (-1)" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-1 + (-1)" expected: @"-2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-1 + (-1)" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 + (-1)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 + (-1)" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
	// test for rollover beyond 9 digits (-999999999 to 999999999)
    STAssertNil(resultsString =[self runTestBefore: @"-999999999 - 1" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-999999999 - 100" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-999999999 - 10000" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-999999999 - 100000000" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-999999999 - 0" expected: @"-999999999" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-999999999 + 1" expected: @"-999999998" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"999999999 + 1" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"999999999 + 100" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"999999999 + 10000" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"999999999 + 100000000" expected: nil sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"999999999 + 0" expected: @"999999999" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"999999999 - 1" expected: @"999999998" sourceTerm: @".0" targetTerm: @".1"], resultsString);
}

- (void) testAdditionSubtractingSimpleIntegers {
	
    STAssertNil(resultsString =[self runTestBefore: @"0 - 0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0 - 0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"0 - 1" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0 - 1" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"5 - 2" expected: @"3" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"5 - 2" expected: @"3" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"1 - (-1)" expected: @"2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 - (-1)" expected: @"2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-1 - 1" expected: @"-2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-1 - 1" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"2 - 2" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"2 - 2" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
}

- (void) testAdditionAddingFractions {
	
    STAssertNil(resultsString =[self runTestBefore: @"1/2 + 2/2" expected: @"(1 + 2)/2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1/2 + 2/2" expected: @"(1 + 2)/2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1/2 - 2/2" expected: @"(1 - 2)/2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1/2 - 2/2" expected: @"(1 - 2)/2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 + 1/2 + 2/2" expected: @"1 + (1 + 2)/2" sourceTerm: @".1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 + 1/2 + 2/2" expected: @"1 + (1 + 2)/2" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 + 1/2 - 2/2" expected: @"1 + (1 - 2)/2" sourceTerm: @".1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 + 1/2 - 2/2" expected: @"1 + (1 - 2)/2" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 - 1/2 + 2/2" expected: @"1 - (1 - 2)/2" sourceTerm: @".1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 - 1/2 + 2/2" expected: @"1 - (1 - 2)/2" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 + 1/2 - 2/2" expected: @"1 + (1 - 2)/2" sourceTerm: @".1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 + 1/2 - 2/2" expected: @"1 + (1 - 2)/2" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 - 1/2 - 2/2" expected: @"1 - (1 + 2)/2" sourceTerm: @".1" targetTerm: @".2"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 - 1/2 - 2/2" expected: @"1 - (1 + 2)/2" sourceTerm: @".2" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a/c + b/c" expected: @"(a + b)/c" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a/c + b/c" expected: @"(a + b)/c" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a/b - (c - d)/b" expected:@"(a - c + d)/b" sourceTerm:@".0" targetTerm:@".1"], resultsString);
}

- (void) testAdditionTestSwapTheOrderOfTheTerms {
	
    STAssertNil(resultsString =[self runTestBefore: @"a - b + c - 1 + 2 - 3" expected: @"-3 - b + c - 1 + 2 + a" sourceTerm: @".0" targetTerm: @".5"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a - b + c - 1 + 2 - 3" expected: @"-3 - b + c - 1 + 2 + a" sourceTerm: @".5" targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"a - b + c - 1 + 2 - 3" expected: @"a + 2 + c - 1 - b - 3" sourceTerm: @".1" targetTerm: @".4"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a - b + c - 1 + 2 - 3" expected: @"a - b + c - 1 + 2 - 3" sourceTerm: @".4" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"a - b + c - 1 + 2 - 3" expected: @"a - b - 1 + c + 2 - 3" sourceTerm: @".2" targetTerm: @".3"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a - b + c - 1 + 2 - 3" expected: @"a - b - 1 + c + 2 - 3" sourceTerm: @".3" targetTerm: @".2"], resultsString);
    
}

- (void) testAdditionAppendingAdditions {
	
    Integer *one			= [[Integer alloc] initWithInt:1];
    Constant *x = [[Variable alloc] initWithTermValue:@"x"];

	// TEST 1
	// 1 + (x + 1) = 1 + x + 1
	Addition *a1 = [[Addition alloc] init:one, nil];
	Addition *a2 = [[Addition alloc] init: x, one, nil];
	[a1 appendTerm:a2];
	Addition *a3 = [[Addition alloc] init: one, x, one, nil];
    STAssertTrue([a1 isEquivalent:a3], @"Before: %@ After: %@ Expected: %@", [a1 printStringValue], [a1 printStringValue], [a3 printStringValue]);
	[a1 release];
	[a2 release];	
	[a3 release];	
	
	// TEST 2
	// 1 + (x - 1) = 1 + x - 1
	a1 = [[Addition alloc] init:one, nil];
	a2 = [[Addition alloc] init: x, one, nil];
	[a2 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	[a1 appendTerm:a2];
	a3 = [[Addition alloc] init: one, x, one, nil];
	[a3 setOperator:SUBTRACTION_OPERATOR atIndex:2];
    STAssertTrue([a1 isEquivalent:a3], @"Before: %@ After: %@ Expected: %@", [a1 printStringValue], [a1 printStringValue], [a3 printStringValue]);
	[a1 release];
	[a2 release];	
	[a3 release];	
	
	// TEST 3
	// 1 - (x - 1) = 1 - x + 1
	a1 = [[Addition alloc] init:one, nil];
	a2 = [[Addition alloc] init: x, one, nil];
	[a2 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	[a1 appendTerm:a2 Operator:SUBTRACTION_OPERATOR];
	a3 = [[Addition alloc] init: one, x, one, nil];
	[a3 setOperator:SUBTRACTION_OPERATOR atIndex:1];
    STAssertTrue([a1 isEquivalent:a3], @"Before: %@ After: %@ Expected: %@", [a1 printStringValue], [a1 printStringValue], [a3 printStringValue]);
	[a1 release];
	[a2 release];	
	[a3 release];	
	
	// TEST 4
	// 1 - (x + 1) = 1 - x - 1
	a1 = [[Addition alloc] init:one, nil];
	a2 = [[Addition alloc] init: x, one, nil];
	[a1 appendTerm:a2 Operator:SUBTRACTION_OPERATOR];
	a3 = [[Addition alloc] init: one, x, one, nil];
	[a3 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	[a3 setOperator:SUBTRACTION_OPERATOR atIndex:2];
    STAssertTrue([a1 isEquivalent:a3], @"Before: %@ After: %@ Expected: %@", [a1 printStringValue], [a1 printStringValue], [a3 printStringValue]);
	[a1 release];
	[a2 release];	
	[a3 release];	
    
	// TEST 11
	// x - (1 - x)*1 to x - 1 + x
	a1 = [[Addition alloc] init:one, x, nil];
	[a1 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	Multiplication *m1 = [[Multiplication alloc] init:a1, one, nil];
	a2 = [[Addition alloc] init: x, m1, nil];
	[a2 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	a3 = [[Addition alloc] init: x, one, x, nil];
	[a3 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	Term *t1 = [Term copyTerm:a2 reducingWithSubTerm:[a2 termAtPath:@".1.1"] andSubTerm:[a2 termAtPath:@".1.0"]];
    STAssertTrue([t1 isEquivalent:a3], @"Before: %@ After: %@ Expected: %@", [a2 printStringValue], [t1 printStringValue], [a3 printStringValue]);
	[t1 release];
	[m1 release];
	[a1 release];
	[a2 release];	
	[a3 release];	
    
}

- (void) testAdditionAddTermsOfTheFormNXplusNX {
	
    STAssertNil(resultsString =[self runTestBefore: @"a - b + c - 1 + 2 - 3" expected: @"-3 - b + c - 1 + 2 + a" sourceTerm: @".0" targetTerm: @".5"], resultsString);

    STAssertNil(resultsString =[self runTestBefore: @"1*x + 2*x" expected: @"3*x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1*x + 2*x" expected: @"3*x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"0*x + 2*x" expected: @"2*x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"2*x + 0*x" expected: @"2*x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"0*x + 0*x" expected: @"0*x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0*x + 0*x" expected: @"0*x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-1*x + 1*x" expected: @"0*x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1*x + (-1)*x" expected: @"0*x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-1*x + (-1)*x" expected: @"-2*x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-1*x + x*(-1)" expected: @"-2*x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1*y + 2*x" expected: @"2*x + 1*y" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1*y + x*2" expected: @"x*2 + 1*y" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1*(2 + 4) + 1*(2 + 4)" expected: @"2*(2 + 4)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1*(2 + 4) + (2 + 4)*1" expected: @"2*(2 + 4)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1*(c^2) + 1*(c^2)" expected: @"2*(c^2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1*(c^2) + (c^2)*1" expected: @"2*(c^2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1*(c/x) + 1*(c/x)" expected: @"2*(c/x)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1*(c/x) + (c/x)*1" expected: @"2*(c/x)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	
}

- (void) testPowerExpandOneZeroAndMinusOne {
	
    STAssertNil(resultsString =[self runTestBefore: @"1^1" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(-1)^1" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0^1" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a+b)^1" expected: @"(a+b)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a*b)^1" expected: @"(a*b)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(2^3)^1" expected: @"2^3" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x^1" expected: @"x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c^1" expected: @"c" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"1^1" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(-1)^1" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0^1" expected: @"0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a+b)^1" expected: @"(a+b)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a*b)^1" expected: @"(a*b)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(2^3)^1" expected: @"2^3" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x^1" expected: @"x" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c^1" expected: @"c" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"1^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(-1)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a+b)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a*b)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(2^3)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"1^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(-1)^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a+b)^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a*b)^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(2^3)^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"1^(-1)" expected: @"1/1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(-1)^(-1)" expected: @"1/(-1)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0^(-1)" expected: nil sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a+b)^(-1)" expected: @"1/(a+b)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a*b)^(-1)" expected: @"1/(a*b)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(2^3)^(-1)" expected: @"2^(3*(-1))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x^(-1)" expected: @"1/x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c^(-1)" expected: @"1/c" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
}	

- (void) testPowerTestExpandPowersTwoToTen {
	
    STAssertNil(resultsString =[self runTestBefore: @"1^2" expected: @"1*1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1^3" expected: @"1*1*1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1^10" expected: @"1*1*1*1*1*1*1*1*1*1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^2" expected: @"a*a" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^3" expected: @"a*a*a" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^10" expected: @"a*a*a*a*a*a*a*a*a*a" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"1^2" expected: @"1*1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1^3" expected: @"1*1*1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1^10" expected: @"1*1*1*1*1*1*1*1*1*1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^2" expected: @"a*a" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^3" expected: @"a*a*a" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^10" expected: @"a*a*a*a*a*a*a*a*a*a" sourceTerm: @".1" targetTerm: @".0`"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"1^(-2)" expected: @"1/(1^2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1^(-3)" expected: @"1/(1^3)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1^(-10)" expected: @"1/(1^10)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^(-2)" expected: @"1/(a^2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^(-3)" expected: @"1/(a^3)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^(-10)" expected: @"1/(a^10)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
}

- (void) testPowerRaiseAPowerToAPower {
	
    STAssertNil(resultsString =[self runTestBefore: @"(a^2)^3" expected: @"a^(2*3)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a^(-1))^3" expected: @"a^((-1)*3)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a^0)^3" expected: @"a^(0*3)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"((a+1)^2)^3" expected: @"(a+1)^(2*3)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"((a*1)^2)^3" expected: @"(a*1)^(2*3)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    
}	

- (void) testPowerDistributeAPowerAcrossAMultiplication {
	
    STAssertNil(resultsString =[self runTestBefore: @"(a*a)^11" expected: @"(a^11)*(a^11)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a*a*b*c)^(1+2)" expected: @"(a^(1+2))*(a^(1+2))*(b^(1+2))*(c^(1+2))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a*(1/2))^x" expected: @"(a^x)*((1/2)^x)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
}

- (void) testPowerDistributeAPowerAcrossAFraction {
	
    STAssertNil(resultsString =[self runTestBefore: @"(1/2)^11" expected: @"(1^11)/(2^11)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"((a*a)/(b*c))^(1+2)" expected: @"(a*a)^(1+2)/(b*c)^(1+2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x/y)^x" expected: @"(x^x)/(y^x)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
}

- (void) testPowerRootsOfRadicals {
	
    STAssertNil(resultsString =[self runTestBefore: @"4^(1/1)" expected: @"4" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"4^(1/1)" expected: @"4" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"4^(0/1)" expected:nil sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"4^(0/1)" expected:nil sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"0^(1/2)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1^(1/2)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"4^(1/2)" expected: @"2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"8^(1/2)" expected: @"2*(2^(1/2))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"27^(1/3)" expected: @"3" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"54^(1/3)" expected: @"3*(2^(1/3))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"21^(1/2)" expected: nil sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"9^(1/3)" expected: nil sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
	// negative number
    STAssertNil(resultsString =[self runTestBefore: @"(-4)^(1/2)" expected: nil sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(-4)^(1/3)" expected: nil sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
	// roots of inverse powers
    STAssertNil(resultsString =[self runTestBefore: @"(x^2)^(1/2)" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x^3)^(1/3)" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x^(a*b))^(1/(a*b))" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x^(a+b))^(1/(a+b))" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x^y)^(1/y)" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    
	// roots of multiplications
    STAssertNil(resultsString =[self runTestBefore: @"(a*b)^(1/2)" expected:@"a^(1/2)*b^(1/2)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"((a+b)*b^2*(1/3))^(1/2)" expected:@"(a+b)^(1/2)*(b^2)^(1/2)*(1/3)^(1/2)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    
	// negative roots
    STAssertNil(resultsString =[self runTestBefore: @"a^(1/(-1))" expected:nil sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^(1/(-2))" expected:nil sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a^(1/(-20))" expected:nil sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
	
	// roots of powers
    STAssertNil(resultsString =[self runTestBefore: @"(x^2)^(1/3)" expected:@"x^(2/3)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x^(1/2))^(1/3)" expected:@"x^((1/2)/3)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x^a)^(1/b)" expected:@"x^(a/b)" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x^(1+2))^(1/(a*b))" expected:@"x^((1+2)/(a*b))" sourceTerm: @".1" targetTerm: @".0.1"], resultsString);
    
}

- (void) testPowerOppositeExponentials {
	
    STAssertNil(resultsString =[self runTestBefore: @"-(2^2)*2^2" expected: @"-(2^(2+2))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"2^2*(-(2^2))" expected: @"-(2^(2+2))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-(2^2)" expected: @"-2*2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(2^2)" expected: @"-2*2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-((-2)^2)" expected: @"2*(-2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-((-2)^2)" expected: @"2*(-2)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"-(2^1)" expected: @"-2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(2^1)" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-((-2)^1)" expected: @"2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-((-2)^1)" expected: @"2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-((-2)^0)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-((-2)^0)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"-(2^0)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(2^0)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-(2^(-1))" expected: @"-1/2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(2^(-1))" expected: @"-1/2" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"-(8^(1/3))" expected: @"-2" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"-((2*2)^(1/2))" expected: @"-(2^(1/2))*(2^(1/2))" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-((2/4)^(1/2))" expected: @"-(2^(1/2))/(4^(1/2))" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"-((x^2)^(1/2))" expected: @"-x" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"-(2^(1/1))" expected: @"-2" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(4^(1/2))" expected: @"-2" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"-(12^(1/2))" expected: @"(-2)*3^(1/2)" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-((x^4)^(1/2))" expected: @"-(x^(4/2))" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);

    STAssertNil(resultsString =[self runTestBefore: @"-(x*y)^(1/2)" expected: @"-(x^(1/2))*y^(1/2)" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(x*y)^2" expected: @"-(x^2)*y^2" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(x*y)^a" expected: @"-(x^a)*y^a" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
    
    
	// raise a power to a power
    STAssertNil(resultsString =[self runTestBefore: @"(x^2)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(x^2)^0" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x^2)^1" expected: @"x^2" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(x^2)^1" expected: @"-(x^2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(x^2)^2" expected: @"x^(2*2)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(x^2)^2" expected: @"-(x^(2*2))" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    
    // "distribute" a power across a multiplication - (c*b)^a -> (c^a)*(b^a)
    STAssertNil(resultsString =[self runTestBefore: @"(a*b)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(a*b)^0" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a*b)^1" expected: @"a*b" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(a*b)^1" expected: @"-a*b" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"(a*b)^x" expected: @"a^x*b^x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(a*b)^x" expected: @"-(a^x)*b^x" sourceTerm: @".1" targetTerm: @".0"], resultsString);

    // "distribute" a power across a fraction - (c/b)^a -> (c^a)/(b^a)
    STAssertNil(resultsString =[self runTestBefore: @"(a/b)^x" expected: @"a^x/b^x" sourceTerm: @".1" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-(a/b)^x" expected: @"-(a^x)/b^x" sourceTerm: @".1" targetTerm: @".0"], resultsString);

    // addition
    STAssertNil(resultsString =[self runTestBefore: @"-(a+b)^2" expected: @"(-a+(-b))*(a+b)" sourceTerm: @".1" targetTerm: @".0"], resultsString);
}

- (void) tstEquationMoveLHSRHSToOtherSideOfTheEquation {
	
    STAssertNil(resultsString =[self runTestBefore: @"0 = 0" expected:@"0 = 0" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0 = 0" expected:@"0 = 0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 = 0" expected:@"0 = 1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 = 0" expected:@"0 = 1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-1 = 0" expected:@"0 = -1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-1 = 0" expected:@"0 = -1" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a + b = 0" expected:@"0 = a + b" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a + b = 0" expected:@"0 = a + b" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-1 = 1" expected: @"0 = 1 - (-1)" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-1 = 1" expected: @"-1 - 1 = 0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 = 1" expected: @"0 = 1 - 1" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 = 1" expected: @"1 - 1 = 0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a + b = c" expected: @"0 = c - a - b" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a + b = c" expected: @"a + b - c = 0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a - b = c" expected: @"0 = c - a + b" sourceTerm: @".0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a - b = c" expected: @"a - b - c = 0" sourceTerm: @".1" targetTerm: @".0"], resultsString);
	
}

- (void) testEquationMoveAddendToTheOtherSideOfTheEquation {
	
    STAssertNil(resultsString =[self runTestBefore: @"0 + 0 = 0" expected:nil sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0 + 0 = 0" expected:nil sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"0 = 0 + 0" expected:nil sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0 = 0 + 0" expected:nil sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"0 = 1 + 0" expected:@"-1 = 0" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0 = 0 + 1" expected:@"-1 = 0" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1 + 1 = 0" expected:@"1 = -1" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1 + 1 = 0" expected:@"1 = -1" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a + b = 0" expected:@"b = -a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a + b = 0" expected:@"a = -b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a - b = 0" expected:@"-b = -a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a - b = 0" expected:@"a = b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-a - b = 0" expected:@"-b = a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-a - b = 0" expected:@"-a = b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-a - (-b) = 0" expected:@"b = a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-a - (-b) = 0" expected:@"-a = -b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-a + (-b) = 0" expected:@"-b = a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"-a + (-b) = 0" expected:@"-a = b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"c + a - b = 0" expected:@"c - b = -a" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c + a - b = 0" expected:@"c + a = b" sourceTerm: @".0.2" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"c + (-a) - b = 0" expected:@"c - b = a" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c + (-a) - b = 0" expected:@"c + (-a) = b" sourceTerm: @".0.2" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"c + (-a) - (-b) = 0" expected:@"c - (-b) = a" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c + (-a) - (-b) = 0" expected:@"c + (-a) = -b" sourceTerm: @".0.2" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"c + (-a) + (-b) = 0" expected:@"c + (-b) = a" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c + (-a) + (-b) = 0" expected:@"c + (-a) = b" sourceTerm: @".0.2" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a + b = c" expected:@"b = c - a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a + b = c" expected:@"a = c - b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"c = a + b" expected:@"c - a = b" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"c = a + b" expected:@"c - b = a" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a - b = c" expected:@"-b = c - a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a - b = c" expected:@"a = c + b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"-a + b = c" expected:@"b = c - (-a)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a + (-b) = c" expected:@"a = c - (-b)" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a + b + c = d" expected:@"b + c = d - a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a + b + c = d" expected:@"a + c = d - b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a - b - c = d" expected:@"-b - c = d - a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a - b - c = d" expected:@"a - c = d + b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a + b = c + d" expected:@"b = c + d - a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a + b = c + d" expected:@"a = c + d - b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a - b = c - d" expected:@"-b = c - d - a" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a - b = c - d" expected:@"a = c - d + b" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
}

- (void) testEquationDivideBothSidesOfEquationByAMultiplicandOnTheSourceSide {
	
    STAssertNil(resultsString =[self runTestBefore: @"0*0 = 0" expected:nil sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"0*0 = 0" expected:nil sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"0*1 = 1" expected:nil sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1*0 = 1" expected:nil sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1*2 = 1" expected:@"2 = 1/1" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1*2 = 0" expected:@"1 = 0/2" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a = b*c" expected:@"a/b = c" sourceTerm: @".1.0" targetTerm: @".0"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a = b*c" expected:@"a/c = b" sourceTerm: @".1.1" targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"a*b = c/d" expected:@"b = c/(d*a)" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"a*b = c/(d*e)" expected:@"a = c/(d*e*b)" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1*2 = c*d"   expected:@"2 = (c*d)/1" sourceTerm: @".0.0" targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"1*2 = c*d*e" expected:@"1 = (c*d*e)/2" sourceTerm: @".0.1" targetTerm: @".1"], resultsString);
	
}

- (void) testEquationMoveDenominatorToTheOtherSideOfTheEquations {
	
    STAssertNil(resultsString =[self runTestBefore: @"1/2 = x" expected:@"1 = 2*x" sourceTerm:@".0.1"  targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x = a/b" expected:@"x*b = a" sourceTerm:@".1.1"  targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"1/2 = x*y" expected:@"1 = x*y*2" sourceTerm:@".0.1"  targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y = a/b" expected:@"x*y*b = a" sourceTerm:@".1.1"  targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"(1/2)*z = x*y" expected:@"z = x*y*2" sourceTerm:@".0.0.1"  targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y = (a/b)*z" expected:@"x*y*b = a*z" sourceTerm:@".1.0.1"  targetTerm: @".0"], resultsString);
    
    STAssertNil(resultsString =[self runTestBefore: @"(1/2)*z = a/b" expected:@"z = (a/b)*2" sourceTerm:@".0.0.1"  targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*(a/b) = (a/b)*z" expected:@"x*(a/b)*b = a*z" sourceTerm:@".1.0.1"  targetTerm: @".0"], resultsString);
	
    STAssertNil(resultsString =[self runTestBefore: @"1/(2*y) = x*y" expected:@"1/y = x*y*2" sourceTerm:@".0.1.0"  targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x*y = a/(x*b)" expected:@"x*y*b = a/x" sourceTerm:@".1.1.1"  targetTerm: @".0"], resultsString);
	
}

- (void) testEquationMoveNumeratorToTheOtherSideOfTheEquations {
	
    STAssertNil(resultsString =[self runTestBefore: @"(1*2)/3 = x" expected:@"1/3 = x/2" sourceTerm:@".0.0.1"  targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x = (1*2)/3" expected:@"x/2 = 1/3" sourceTerm:@".1.0.1"  targetTerm: @".0"], resultsString);

    STAssertNil(resultsString =[self runTestBefore: @"(1*2)/3 = x" expected:@"2/3 = x/1" sourceTerm:@".0.0.0"  targetTerm: @".1"], resultsString);
    STAssertNil(resultsString =[self runTestBefore: @"x = (1*2)/3" expected:@"x/1 = 2/3" sourceTerm:@".1.0.0"  targetTerm: @".0"], resultsString);
}

@end
