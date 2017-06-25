//
//  UnitTests.m
//  TouchAlgebra
//
//  Created by David Sullivan on 1/15/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "UnitTests.h"

// flag to print all tests
#define PRINT_ALL_TESTS NO

// shared local variables
Addition *a1;
Addition *a2;
Addition *a3;
Multiplication *m1;
Multiplication *m2;
Multiplication *m3;
Term	 *t1;
Term	 *t2;
Fraction *f1;
Fraction *f2;
Fraction *f3;
Power	 *p1;
Power	 *p2;

@implementation UnitTests

- (id) init {
	
	if (self = [super init]) {
		
		// create the parser
		parser = [[TermParser alloc] init];

		// initialize integers
		one			= [[Integer alloc] initWithInt:1];
		two			= [[Integer alloc] initWithInt:2];
		three		= [[Integer alloc] initWithInt:3];
		zero		= [[Integer alloc] initWithInt:0];
		minusOne	= [[Integer alloc] initWithInt:-1];
		minusTwo	= [[Integer alloc] initWithInt:-2];
		minusThree	= [[Integer alloc] initWithInt:-3];

		// initialize constants
		a = [[Constant alloc] initWithTermValue:@"a"];
		b = [[Constant alloc] initWithTermValue:@"b"];
		c = [[Constant alloc] initWithTermValue:@"c"];
		minusa = [[Constant alloc] initWithTermValue:@"a"]; 
		[minusa setIsOpposite:YES];
		minusb = [[Constant alloc] initWithTermValue:@"b"];
		[minusb setIsOpposite:YES];
		minusc = [[Constant alloc] initWithTermValue:@"c"];
		[minusc setIsOpposite:YES];
		
		// initialize variables
		x = [[Variable alloc] initWithTermValue:@"x"];
		y = [[Variable alloc] initWithTermValue:@"y"];
		z = [[Variable alloc] initWithTermValue:@"z"];
		minusx = [[Variable alloc] initWithTermValue:@"x"];
		[minusx setIsOpposite:YES];
		minusy = [[Variable alloc] initWithTermValue:@"y"];
		[minusy setIsOpposite:YES];
		minusz = [[Variable alloc] initWithTermValue:@"z"];
		[minusz setIsOpposite:YES];

		twox = [[Multiplication alloc] init];
		[twox appendTerm:two];
		[twox appendTerm:x];
		
		xyz = [[Multiplication alloc] init];
		[xyz appendTerm:x];
		[xyz appendTerm:y];
		[xyz appendTerm:z];
		
		zyx = [[Multiplication alloc] init];
		[zyx appendTerm:z];
		[zyx appendTerm:y];
		[zyx appendTerm:x];
		
		xy = [[Multiplication alloc] init];
		[xy appendTerm:x];
		[xy appendTerm:y];
		
		xz = [[Multiplication alloc] init];
		[xz appendTerm:x];
		[xz appendTerm:z];
		
		zx = [[Multiplication alloc] init];
		[zx appendTerm:z];
		[zx appendTerm:x];
		
		zy = [[Multiplication alloc] init];
		[zy appendTerm:z];
		[zy appendTerm:y];
		
		yz = [[Multiplication alloc] init];
		[yz appendTerm:y];
		[yz appendTerm:z];
		
		yx = [[Multiplication alloc] init];
		[yx appendTerm:y];
		[yx appendTerm:x];
		
		testCount = 0;
}
	
	return self;
}

- (void) printTestCount {
	
	NSLog(@"Total unit tests run: %i", testCount);
}

- (void) printTestResults: (NSString *) testName before: (Term *) before after: (Term *) after expected: (Term *) expected {
	
	// index the test counter
	testCount++;
	
	if ((expected == nil && after == nil) || [expected isEquivalent:after]) {
		
		if (PRINT_ALL_TESTS) {
			NSLog(@"%@ - Passed", testName);
		}
	}
	else {
		NSLog(@"%@ - Failed! Before: %@ After: %@ Expected: %@", testName, [before printStringValue], [after printStringValue], [expected printStringValue]);
	}
	
	
}

- (void) runTest: (NSString *) name 
		  before: (NSString *) before	// a nil term string mean before or expected is nil
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
			NSLog(@"%@ - Before term failed to parse: %@", name, before);
			NSLog(@"     Error was: %@", [parser errorMessage]);
			return;
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
			NSLog(@"%@ - Expected term failed to parse: %@", name, expected);
			NSLog(@"     Error was: %@", [parser errorMessage]);
			return;
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

		NSLog(@"%@ - Failed! - after term has parent! Before: %@ After: %@ Expected: %@", name, [beforeTerm printStringValue], [afterTerm printStringValue], [expectedTerm printStringValue]);
	}
	
	// check for equivalency with the after term
	else if ((expected == nil && afterTerm == nil) || [expectedTerm isEquivalent:afterTerm]) {
		
		if (PRINT_ALL_TESTS) {
			NSLog(@"%@ - Passed", name);
		}
	}
	else {
		NSLog(@"%@ - Failed! Before: %@ After: %@ Expected: %@", name, [beforeTerm printStringValue], [afterTerm printStringValue], [expectedTerm printStringValue]);
	}
}

- (void) MultiplicationTest1 {
	
	NSLog(@"+++++ Multiplication Test Suite 1 - move a multiplicand to the numerator of a fraction ++++");
	
	[self runTest: @"Multiplication test 1.1" before: @"2*(1/2)" expected: @"(2*1)/2" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 1.2" before: @"2*(1/2)" expected: @"(2*1)/2" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 2.1" before: @"(1/2)*2" expected: @"1" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Multiplication test 2.2" before: @"(1/2)*2" expected: @"1" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Multiplication test 3.1" before: @"(1/3)*2" expected: @"(1*2)/3" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Multiplication test 3.2" before: @"(1/3)*2" expected: @"(1*2)/3" sourceTerm: @".0.0" targetTerm: @".1"];
	
	[self runTest: @"Multiplication test 4.1" before: @"2*(1/2)*a" expected: @"((2*1)/2)*a" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 4.2" before: @"b*2*(1/2)*a" expected: @"b*((2*1)/2)*a" sourceTerm: @".1" targetTerm: @".2.0"];
	[self runTest: @"Multiplication test 4.3" before: @"b*2*(1/2)*a" expected: @"b*2*((1*a)/2)" sourceTerm: @".3" targetTerm: @".2.0"];
}	

- (void) MultiplicationTest2 {
	
	NSLog(@"+++++ Multiplication Test Suite 2 - Multiply infinity ++++");
	
	// TEST 1
	// 1 + ∞ = ∞
	m1 = [[Multiplication alloc] init:one, [Constant infinity], nil];
	t1 = [Term copyTerm:m1 reducingWithSubTerm:[m1 termAtPath:@".0"] andSubTerm:[m1 termAtPath:@".1"]];
	[self printTestResults:@"Multiplication test 1" before:m1 after:t1 expected:[Constant infinity]];	
	[m1 release];
	[t1 release];	
	
	// TEST 2
	// 1 + c + a + ∞ = ∞
	m1 = [[Multiplication alloc] init:one, c, a, [Constant infinity], nil];
	t1 = [Term copyTerm:m1 reducingWithSubTerm:[m1 termAtPath:@".2"] andSubTerm:[m1 termAtPath:@".3"]];
	[self printTestResults:@"Multiplication test 2" before:m1 after:t1 expected:[Constant infinity]];	
	[m1 release];
	[t1 release];	
}

- (void) MultiplicationTest3 {
	
	NSLog(@"+++++ Multiplication Test Suite 3 - Multiply by zero ++++");
	
	// times 1
	[self runTest: @"Multiplication test 1.1" before: @"1*0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 1.2" before: @"1*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 1.3" before: @"0*1" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 1.4" before: @"0*1" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];

	// times an integer
	[self runTest: @"Multiplication test 2.1" before: @"13*0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 2.2" before: @"1231*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 2.3" before: @"0*14" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 2.4" before: @"0*(-6)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	
	// times a constant
	[self runTest: @"Multiplication test 3.1" before: @"0*c" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 3.2" before: @"c*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	
	// in any position
	[self runTest: @"Multiplication test 4.1" before: @"0*c*4*99" expected: @"0" sourceTerm: @".0" targetTerm: @".3"];
	[self runTest: @"Multiplication test 4.2" before: @"0*c*4*99" expected: @"0" sourceTerm: @".3" targetTerm: @".0"];
	[self runTest: @"Multiplication test 4.3" before: @"c*0*4*99" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 4.4" before: @"c*0*4*99" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 4.5" before: @"c*0*4*99" expected: @"0" sourceTerm: @".3" targetTerm: @".1"];
	[self runTest: @"Multiplication test 4.6" before: @"c*0*4*99" expected: @"0" sourceTerm: @".1" targetTerm: @".3"];
	[self runTest: @"Multiplication test 4.7" before: @"c*4*99*0" expected: @"0" sourceTerm: @".3" targetTerm: @".0"];
	[self runTest: @"Multiplication test 4.8" before: @"c*4*99*0" expected: @"0" sourceTerm: @".3" targetTerm: @".1"];
	[self runTest: @"Multiplication test 4.9" before: @"c*4*99*0" expected: @"0" sourceTerm: @".0" targetTerm: @".3"];
	[self runTest: @"Multiplication test 4.10" before: @"c*4*99*0" expected: @"0" sourceTerm: @".1" targetTerm: @".3"];
	
	// times a power
	[self runTest: @"Multiplication test 5.1" before: @"c^2*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 5.2" before: @"c^2*0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 5.3" before: @"0*c^2" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 5.4" before: @"0*c^2" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	
	// times a variable
	[self runTest: @"Multiplication test 6.1" before: @"0*x" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 6.2" before: @"x*0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	
	// TODO: times a power
	
	// times an equation
		
}

- (void) MultiplicationTest4 {
	
	NSLog(@"+++++ Multiplication Test Suite 4 - Multiply by one and negative one ++++");
	
	// times integers
	[self runTest: @"Multiplication test 1.1" before: @"1*1" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 1.2" before: @"12*1" expected: @"12" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 1.3" before: @"1*(-1)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 1.4" before: @"-1*10" expected: @"-10" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 1.5" before: @"-1*1" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];

	// times fractions
	[self runTest: @"Multiplication test 2.1" before: @"(1/2)*1" expected: @"1/2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 2.2" before: @"(1/2)*1" expected: @"1/2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 2.3" before: @"1*(1/2)" expected: @"1/2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 2.4" before: @"-1*(1/2)" expected: @"-1/2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 2.5" before: @"(1/2)*(-1)" expected: @"-1/2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 2.6" before: @"(1/2)*(-1)" expected: @"-1/2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 2.7" before: @"-1*(1/2)" expected: @"-1/2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 2.8" before: @"-1*(1/2)" expected: @"-1/2" sourceTerm: @".1" targetTerm: @".0"];

	// times addition
	[self runTest: @"Multiplication test 3.1" before: @"(1 + 2)*1" expected: @"1 + 2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 3.2" before: @"(1 + 2)*1" expected: @"1 + 2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 3.3" before: @"1*(1 + 2)" expected: @"1 + 2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 3.4" before: @"1*(1 + 2)" expected: @"1 + 2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 3.5" before: @"(1 + 2)*(-1)" expected: @"-1 + (-2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 3.6" before: @"(1 + 2)*(-1)" expected: @"-1 + (-2)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 3.7" before: @"(-1)*(1 + 2)" expected: @"-1 + (-2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 3.8" before: @"(-1)*(1 + 2)" expected: @"-1 + (-2)" sourceTerm: @".1" targetTerm: @".0"];
	
	// times a constant
	[self runTest: @"Multiplication test 4.1" before: @"1*c" expected: @"c" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 4.2" before: @"1*c" expected: @"c" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 4.3" before: @"c*(-1)" expected: @"-c" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 4.4" before: @"c*(-1)" expected: @"-c" sourceTerm: @".1" targetTerm: @".0"];
	
	// times a variable
	[self runTest: @"Multiplication test 5.1" before: @"1*x" expected: @"x" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 5.2" before: @"1*x" expected: @"x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 5.3" before: @"x*(-1)" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 5.4" before: @"x*(-1)" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"];
	
	// TODO: times a power
	
	// times an equation
	
}

- (void) MultiplicationTest5 {
	
	NSLog(@"+++++ Multiplication Test Suite 5 - Multiply symbolic terms ++++");
	
	[self runTest: @"Multiplication test 1.1" before: @"x*x" expected: @"x^2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 1.2" before: @"-x*x" expected: @"-(x^2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 1.3" before: @"x*(-x)" expected: @"-(x^2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 1.4" before: @"(-x)*(-x)" expected: @"x^2" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Multiplication test 2.1" before: @"x*x*x" expected: @"x*x^2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 2.2" before: @"-x*x*x" expected: @"-(x^2)*x" sourceTerm: @".0" targetTerm: @".2"];
	[self runTest: @"Multiplication test 2.3" before: @"x*x*(-x)" expected: @"-(x^2)*x" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Multiplication test 2.4" before: @"x*(-x)*(-x)" expected: @"x*x^2" sourceTerm: @".1" targetTerm: @".2"];
	
	[self runTest: @"Multiplication test 2.1" before: @"(-x)*(x^2)" expected: @"-(x^(2+1))" sourceTerm: @".0" targetTerm: @".1"];
}

- (void) MultiplicationTest6 {
	
	NSLog(@"+++++ Multiplication Test Suite 6 - Reduce multiplicands with a fraction's denominator ++++");
	
	[self runTest: @"Multiplication test 1.1" before: @"a*b*(b/a)" expected: @"b*b" sourceTerm: @".0" targetTerm: @".2.1"];
	[self runTest: @"Multiplication test 1.2" before: @"a*b*(b/a)" expected: @"b*b" sourceTerm: @".2.1" targetTerm: @".0"];

	[self runTest: @"Multiplication test 2.1" before: @"a*(b/a)*b" expected: @"b*b" sourceTerm: @".0" targetTerm: @".1.1"];
	[self runTest: @"Multiplication test 2.2" before: @"a*(b/a)*b" expected: @"b*b" sourceTerm: @".1.1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 3.1" before: @"(b/a)*a*b" expected: @"b*b" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Multiplication test 3.2" before: @"(b/a)*a*b" expected: @"b*b" sourceTerm: @".0.1" targetTerm: @".1"];
	
}

- (void) MultiplicationTest7 {
	
	NSLog(@"+++++ Multiplication Test Suite 7 - Reduce terms in fraction multiplicands ++++");
	
	[self runTest: @"Multiplication test 1.1" before: @"(a/b)*(b/a)" expected: @"(1/b)*b" sourceTerm: @".0.0" targetTerm: @".1.1"];
	[self runTest: @"Multiplication test 1.2" before: @"(a/b)*(b/a)" expected: @"(1/b)*b" sourceTerm: @".1.1" targetTerm: @".0.0"];
	
	[self runTest: @"Multiplication test 2.1" before: @"(a/b)*(b/a)" expected: @"a*(1/a)" sourceTerm: @".0.1" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 2.2" before: @"(a/b)*(b/a)" expected: @"a*(1/a)" sourceTerm: @".1.0" targetTerm: @".0.1"];

	[self runTest: @"Multiplication test 2.1.1" before: @"(a/(-b))*(b/a)" expected: nil sourceTerm: @".0.1" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 2.2.1" before: @"(a/b)*((-b)/a)" expected: nil sourceTerm: @".1.0" targetTerm: @".0.1"];
	
	[self runTest: @"Multiplication test 3.1" before: @"(a/(b*c))*(b/a)" expected: @"(a/c)*(1/a)" sourceTerm: @".0.1.0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 3.2" before: @"(a/(b*c))*(b/a)" expected: @"(a/c)*(1/a)" sourceTerm: @".1.0" targetTerm: @".0.1.0"];
	
	[self runTest: @"Multiplication test 4.1" before: @"((a*b)/c)*(a/b)" expected: @"(a/c)*a" sourceTerm: @".0.0.1" targetTerm: @".1.1"];
	[self runTest: @"Multiplication test 4.2" before: @"((a*b)/c)*(a/b)" expected: @"(a/c)*a" sourceTerm: @".1.1" targetTerm: @".0.0.1"];
	
	[self runTest: @"Multiplication test 5.1" before: @"((a*b)/c)*((a*d)/b)" expected: @"(a/c)*a*d" sourceTerm: @".0.0.1" targetTerm: @".1.1"];
	[self runTest: @"Multiplication test 5.2" before: @"((a*b)/c)*((a*d)/b)" expected: @"(a/c)*a*d" sourceTerm: @".1.1" targetTerm: @".0.0.1"];
	
}	
	
- (void) MultiplicationTest8 {
	
	NSLog(@"+++++ TODO - Multiplication Test Suite 8 - Multiply powers ++++");
	
	[self runTest: @"Multiplication test 1.1" before: @"(a^0)*(a^0)" expected: @"a^(0+0)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 1.2" before: @"(a^0)*(a^0)" expected: @"a^(0+0)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 2.1" before: @"(a^1)*(a^0)" expected: @"a^(1+0)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 2.2" before: @"(a^0)*(a^1)" expected: @"a^(0+1)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 3.1" before: @"(a^2)*(a^2)" expected: @"a^(2+2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 3.2" before: @"(a^2)*(a^2)" expected: @"a^(2+2)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 4.1" before: @"-(a^2)*(a^2)" expected: @"-(a^(2+2))" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 4.2" before: @"(a^2)*(-(a^2))" expected: @"-(a^(2+2))" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 5.1" before: @"-(a^2)*(-(a^2))" expected: @"a^(2+2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 5.2" before: @"-(a^2)*(-(a^2))" expected: @"a^(2+2)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 6.1" before: @"(-a)^2*(-a)^2" expected: @"(-a)^(2+2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 6.2" before: @"(-a)^2*a^2" expected: @"(a*(-a))^2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 6.3" before: @"(a^2)*a" expected: @"a^(2 + 1)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Multiplication test 6.4" before: @"-a*(a^2)" expected: @"-(a^(2 + 1))" sourceTerm: @".1" targetTerm: @".0"];
	
	// TODO: finish me
	[self runTest: @"Multiplication test 7.1" before: @"((-a)^0)*((-a)^0)" expected: @"(-a)^(0+0)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 7.2" before: @"((-a)^0)*((-a)^0)" expected: @"(-a)^(0+0)" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Multiplication test 8.1" before: @"((-a)^0)*(a^0)" expected: @"(-a*a)^0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 8.2" before: @"(a^0)*((-a)^0)" expected: @"(-a*a)^0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 9.1" before: @"((-a)^1)*(a^2)" expected: nil sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 9.2" before: @"(a^2)*((-a)^1)" expected: nil sourceTerm: @".1" targetTerm: @".0"];
	
	
}

- (void) MultiplicationTest9 {
	
	NSLog(@"+++++ Multiplication Test Suite 9 - Multiply a power by the base ++++");
	
	[self runTest: @"Multiplication test 1.1" before: @"a*(a^0)" expected: @"a^(0+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 1.2" before: @"a*(a^0)" expected: @"a^(0+1)" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Multiplication test 1.3" before: @"a*(a^0)" expected: @"a^(0+1)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 1.4" before: @"a*(a^0)" expected: @"a^(0+1)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 2.1" before: @"-a*(a^0)" expected: @"-(a^(0 + 1))" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 2.2" before: @"-a*(a^0)" expected: @"-(a^(0 + 1))" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 3.1" before: @"-a*((-a)^0)" expected: @"(-a)^(0+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 3.2" before: @"-a*((-a)^0)" expected: @"(-a)^(0+1)" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Multiplication test 3.3" before: @"-a*((-a)^0)" expected: @"(-a)^(0+1)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 3.4" before: @"-a*((-a)^0)" expected: @"(-a)^(0+1)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Multiplication test 4.1" before: @"-a*(-(a^2))" expected: @"a^(2+1)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 4.2" before: @"a*(-(a^2))"  expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 4.3" before: @"-a*(a^2)"    expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Multiplication test 5.1" before: @"-a*((-a)^2)"    expected: @"(-a)^(2+1)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 5.1" before: @"-a*(-((-a)^2))" expected: @"-((-a)^(2+1))" sourceTerm: @".0" targetTerm: @".1"];

	[self runTest: @"Multiplication test 6.1" before: @"a*((-a)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 6.2" before: @"a*(-((-a)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 6.3" before: @"a*((-a)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 6.4" before: @"a*(-((-a)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"];

	[self runTest: @"Multiplication test 7.1" before: @"-a*(-(a^2))" expected: @"a^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 7.2" before: @"a*(-(a^2))"  expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 7.3" before: @"-a*(a^2)"    expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 8.1" before: @"-a*((-a)^2)"    expected: @"(-a)^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 8.1" before: @"-a*(-((-a)^2))" expected: @"-((-a)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 9.1" before: @"a*((-a)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 9.2" before: @"a*(-((-a)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"];

	[self runTest: @"Multiplication test 10.1" before: @"-a*(-(a^2))" expected: @"a^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 10.2" before: @"a*(-(a^2))"  expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 10.3" before: @"-a*(a^2)"    expected: @"-(a^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];

	[self runTest: @"Multiplication test 11.1" before: @"3*((-3)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 11.2" before: @"3*(-((-3)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 11.3" before: @"3*((-3)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 11.3" before: @"3*(-((-3)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 12.1" before: @"-3*(-(3^2))" expected: @"3^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 12.2" before: @"3*(-(3^2))"  expected: @"-(3^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 12.3" before: @"-3*(3^2)"    expected: @"-(3^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 13.1" before: @"-3*((-3)^2)"    expected: @"(-3)^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 13.1" before: @"-3*(-((-3)^2))" expected: @"-((-3)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 14.1" before: @"3*((-3)^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 14.2" before: @"3*(-((-3)^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 15.1" before: @"-3*(-(3^2))" expected: @"3^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 15.2" before: @"3*(-(3^2))"  expected: @"-(3^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 15.3" before: @"-3*(3^2)"    expected: @"-(3^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];

	[self runTest: @"Multiplication test 16.1" before: @"(x^2)*((-(x^2))^2)"    expected: @"(x*(-(x^2)))^2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 16.2" before: @"(x^2)*(-((-(x^2))^2))" expected: @"-((x*(-(x^2)))^2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Multiplication test 16.3" before: @"(x^2)*((-(x^2))^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 16.3" before: @"(x^2)*(-((-(x^2))^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 17.1" before: @"-(x^2)*(-((x^2)^2))" expected: @"(x^2)^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 17.2" before: @"(x^2)*(-((x^2)^2))"  expected: @"-((x^2)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 17.3" before: @"-(x^2)*((x^2)^2)"    expected: @"-((x^2)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 18.1" before: @"-(x^2)*((-(x^2))^2)"    expected: @"(-(x^2))^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 18.1" before: @"-(x^2)*(-((-(x^2))^2))" expected: @"-((-(x^2))^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 19.1" before: @"(x^2)*((-(x^2))^2)"    expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 14.2" before: @"(x^2)*(-((-(x^2))^2))" expected: nil sourceTerm: @".0" targetTerm: @".1.0"];
	
	[self runTest: @"Multiplication test 20.1" before: @"-(x^2)*(-((x^2)^2))" expected: @"(x^2)^(2+1)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 20.2" before: @"(x^2)*(-((x^2)^2))"  expected: @"-((x^2)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Multiplication test 20.3" before: @"-(x^2)*((x^2)^2)"    expected: @"-((x^2)^(2+1))" sourceTerm: @".0" targetTerm: @".1.0"];
}

- (void) FractionTest1 {
	
	NSLog(@"+++++ Fraction Test Suite 1 - numerator and denominator are equivalent ++++");
	
	[self runTest: @"Fraction test 1.1" before: @"a/a" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 1.2" before: @"a/a" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Fraction test 2.1" before: @"-a/a" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 2.2" before: @"-a/a" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Fraction test 3.1" before: @"a/(-a)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 3.2" before: @"a/(-a)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Fraction test 4.1" before: @"(-a)/(-a)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 4.2" before: @"(-a)/(-a)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 5.1" before: @"1/1" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.2" before: @"1/1" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Fraction test 6.1" before: @"-1/1" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 6.2" before: @"-1/1" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Fraction test 7.1" before: @"1/(-1)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 7.2" before: @"1/(-1)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 8.1" before: @"(-1)/(-1)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 8.2" before: @"(-1)/(-1)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 9.1" before: @"(a + a)/(a + a)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 9.2" before: @"(a + a)/(a + a)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Fraction test 10.1" before: @"(a*a)/(a*a)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 10.2" before: @"(a*a)/(a*a)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 11.1" before: @"(c^2)/(c^2)" expected: @"c^(2 - 2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 11.2" before: @"(c^2)/(c^2)" expected: @"c^(2 - 2)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 11.1" before: @"(1/2)/(1/2)" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 11.2" before: @"(1/2)/(1/2)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
}

- (void) FractionTest2 {
	
	NSLog(@"+++++ Fraction Test Suite 2 - term in the numerator or denoninator reduces to one ++++");
	
	[self runTest: @"Fraction test 1.1" before: @"a/(a*b)" expected: @"1/b" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 1.2" before: @"a/(a*b)" expected: @"1/b" sourceTerm: @".1.0" targetTerm: @".0"];

	[self runTest: @"Fraction test 2.1" before: @"-a/(a*b)" expected: @"-1/b" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 2.2" before: @"-a/(a*b)" expected: @"-1/b" sourceTerm: @".1.0" targetTerm: @".0"];

	[self runTest: @"Fraction test 3.1" before: @"a/((-a)*b)" expected: @"-1/b" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 3.2" before: @"a/((-a)*b)" expected: @"-1/b" sourceTerm: @".1.0" targetTerm: @".0"];

	[self runTest: @"Fraction test 4.1" before: @"2/(2*b)" expected: @"1/b" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 4.2" before: @"2/(2*b)" expected: @"1/b" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 5.1" before: @"-2/(2*b)" expected: @"-1/b" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 5.2" before: @"-2/(2*b)" expected: @"-1/b" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 6.1" before: @"2/(-2*b)" expected: @"-1/b" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 6.2" before: @"2/(-2*b)" expected: @"-1/b" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 7.1" before: @"a/(a*b*c)" expected: @"1/(b*c)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 7.2" before: @"a/(a*b*c)" expected: @"1/(b*c)" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 8.1" before: @"a/1" expected: @"a" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 8.2" before: @"a/1" expected: @"a" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 9.1" before: @"(a*b)/a" expected: @"b" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 9.2" before: @"(a*b)/a" expected: @"b" sourceTerm: @".1" targetTerm: @".0.0"];
	
	[self runTest: @"Fraction test 10.1" before: @"(a*b*c)/a" expected: @"b*c" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 10.2" before: @"(a*b*c)/a" expected: @"b*c" sourceTerm: @".1" targetTerm: @".0.0"];
	
	[self runTest: @"Fraction test 11.1" before: @"(a*b*c)/(a*b*c)" expected: @"(a*b)/(a*b)" sourceTerm: @".0.2" targetTerm: @".1.2"];
	[self runTest: @"Fraction test 11.2" before: @"(a*b*c)/(a*b*c)" expected: @"(a*b)/(a*b)" sourceTerm: @".1.2" targetTerm: @".0.2"];
	[self runTest: @"Fraction test 11.3" before: @"(a*b*c)/(a*b*c)" expected: @"(a*c)/(a*c)" sourceTerm: @".0.1" targetTerm: @".1.1"];
	[self runTest: @"Fraction test 11.4" before: @"(a*b*c)/(a*b*c)" expected: @"(a*c)/(a*c)" sourceTerm: @".1.1" targetTerm: @".0.1"];
	[self runTest: @"Fraction test 11.5" before: @"(a*b*c)/(a*b*c)" expected: @"(b*c)/(b*c)" sourceTerm: @".0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 11.6" before: @"(a*b*c)/(a*b*c)" expected: @"(b*c)/(b*c)" sourceTerm: @".1.0" targetTerm: @".0.0"];
	
}

- (void) FractionTest3 {
	
	NSLog(@"+++++ Fraction Test Suite 3 - zeros in fractions ++++");
	
	// TEST 1
	// a/0 throws exception
	BOOL testPassed = NO;
	@try { 
		f1 = [[Fraction alloc] initWithNum:a andDenom:zero];
	}
	@catch (NSException *exception) { 
		
		testPassed = YES;
	}
	if (!testPassed) {
		NSLog(@"Failed! TEST 1 did not throw exception");
	}		
	
	// 0/0 is unchanged
	testPassed = NO;
	@try { 
		f1 = [[Fraction alloc] initWithNum:zero andDenom:zero];
	}
	@catch (NSException *exception) { 
		
		testPassed = YES;
	}
	if (!testPassed) {
		NSLog(@"Failed! TEST 1a did not throw exception");
	}
	
	[self runTest: @"Fraction test 1.1" before: @"0/a" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 1.2" before: @"0/a" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Fraction test 2.1" before: @"0/1" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 2.2" before: @"0/1" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
}

- (void) FractionTest4 {
	
	NSLog(@"+++++ Fraction Test Suite 4 - integer fractions ++++");
	
	[self runTest: @"Fraction test 1.1" before: @"2/2" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 1.2" before: @"2/2" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 2.1" before: @"2/4" expected: @"1/2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 2.2" before: @"2/4" expected: @"1/2" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 3.1" before: @"-2/4" expected: @"-1/2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 3.2" before: @"-2/4" expected: @"-1/2" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 4.1" before: @"2/(-4)" expected: @"1/(-2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 4.2" before: @"2/(-4)" expected: @"1/(-2)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 5.1" before: @"4/2" expected: @"2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.2" before: @"4/2" expected: @"2" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 6.1" before: @"-4/2" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 6.2" before: @"-4/2" expected: @"-2" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 7.1" before: @"4/(-2)" expected: @"2/(-1)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 7.2" before: @"4/(-2)" expected: @"2/(-1)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 8.1" before: @"4/12" expected: @"1/3" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 8.2" before: @"4/12" expected: @"1/3" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 9.1" before: @"8/12" expected: @"2/3" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 9.2" before: @"8/12" expected: @"2/3" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 10.1" before: @"-8/12" expected: @"-2/3" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 10.2" before: @"-8/12" expected: @"-2/3" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 11.1" before: @"8/(-12)" expected: @"2/(-3)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 11.2" before: @"8/(-12)" expected: @"2/(-3)" sourceTerm: @".1" targetTerm: @".0"];
	
}

- (void) FractionTest5 {
	
	NSLog(@"+++++ Fraction Test Suite 5 - powers ++++");
	
	[self runTest: @"Fraction test 1.1" before: @"1/a" expected: @"a^(-1)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 1.2" before: @"1/a" expected: @"a^(-1)" sourceTerm: @".1" targetTerm: @".0"];
	
	// powers are not equivalent
	[self runTest: @"Fraction test 6.1" before: @"c^2/c^3" expected: @"c^(2-3)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 6.2" before: @"c^2/c^3" expected: @"c^(2-3)" sourceTerm: @".1" targetTerm: @".0"];
		
	[self runTest: @"Fraction test 7.1" before: @"c^(a-h)/c^3" expected: @"c^(a-h-3)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 7.2" before: @"c^(a-h)/c^3" expected: @"c^(a-h-3)" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Fraction test 8.1" before: @"(x^2*3)/x^3" expected: @"(x^(2-3)*3)" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 8.2" before: @"(x^2*3)/x^3" expected: @"(x^(2-3)*3)" sourceTerm: @".1" targetTerm: @".0.0"];

	[self runTest: @"Fraction test 9.1" before: @"x^3/(x^2*3)" expected: @"(x^(3-2)/3)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 9.2" before: @"x^3/(x^2*3)" expected: @"(x^(3-2)/3)" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 10.1" before: @"(x^4*3)/(x^2*3)" expected: @"((x^(4-2)*3)/3)" sourceTerm: @".0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 10.2" before: @"(x^4*3)/(x^2*3)" expected: @"((x^(4-2)*3)/3)" sourceTerm: @".1.0" targetTerm: @".0.0"];
	
}

- (void) FractionTest6 {
	
	NSLog(@"+++++ Fraction Test Suite 6 - reducing with infinity ++++");
	
	// TEST 1
	// 1/∞ to 0
	f1 = [[Fraction alloc] initWithNum:one andDenom:[Constant infinity]];
	t1 = [Term copyTerm:f1 reducingWithSubTerm:[f1 termAtPath:@".0"] andSubTerm:[f1 termAtPath:@".1"]];
	[self printTestResults:@"Fraction test 1" before:f1 after:t1 expected:zero];
	[t1 release];
	t1 = [Term copyTerm:f1 reducingWithSubTerm:[f1 termAtPath:@".1"] andSubTerm:[f1 termAtPath:@".0"]];
	[self printTestResults:@"Fraction test 1a" before:f1 after:t1 expected:zero];
	[t1 release];
	[f1 release];
	
	// TEST 2
	// ∞/1 to ∞
	f1 = [[Fraction alloc] initWithNum:[Constant infinity] andDenom:one];
	t1 = [Term copyTerm:f1 reducingWithSubTerm:[f1 termAtPath:@".0"] andSubTerm:[f1 termAtPath:@".1"]];
	[self printTestResults:@"Fraction test 2" before:f1 after:t1 expected:[Constant infinity]];
	[t1 release];
	t1 = [Term copyTerm:f1 reducingWithSubTerm:[f1 termAtPath:@".1"] andSubTerm:[f1 termAtPath:@".0"]];
	[self printTestResults:@"Fraction test 2a" before:f1 after:t1 expected:[Constant infinity]];
	[t1 release];
	[f1 release];
	
	// TEST 3
	// ∞/∞ to ∞
	f1 = [[Fraction alloc] initWithNum:[Constant infinity] andDenom:[Constant infinity]];
	t1 = [Term copyTerm:f1 reducingWithSubTerm:[f1 termAtPath:@".0"] andSubTerm:[f1 termAtPath:@".1"]];
	[self printTestResults:@"Fraction test 3" before:f1 after:t1 expected:nil];
	[t1 release];
	t1 = [Term copyTerm:f1 reducingWithSubTerm:[f1 termAtPath:@".1"] andSubTerm:[f1 termAtPath:@".0"]];
	[self printTestResults:@"Fraction test 3a" before:f1 after:t1 expected:nil];
	[t1 release];
	[f1 release];
	
	// TEST 4
	// 0/∞ to 0
	f1 = [[Fraction alloc] initWithNum:zero andDenom:[Constant infinity]];
	t1 = [Term copyTerm:f1 reducingWithSubTerm:[f1 termAtPath:@".0"] andSubTerm:[f1 termAtPath:@".1"]];
	[self printTestResults:@"Fraction test 4" before:f1 after:t1 expected:zero];
	[t1 release];
	t1 = [Term copyTerm:f1 reducingWithSubTerm:[f1 termAtPath:@".1"] andSubTerm:[f1 termAtPath:@".0"]];
	[self printTestResults:@"Fraction test 4a" before:f1 after:t1 expected:zero];
	[t1 release];
	[f1 release];
	
}

- (void) FractionTest7 {
	
	NSLog(@"+++++ Fraction Test Suite 7 - reduce powers in the numerator or the denominator ++++");
	
	// Case 1: base/power 
	[self runTest: @"Fraction test 1.1.1" before: @"c/(c^2)" expected: @"c^(1-2)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 1.1.2" before: @"c/(c^2)" expected: @"c^(1-2)" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Fraction test 1.1.3" before: @"c/(c^2)" expected: @"c^(1-2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 1.1.4" before: @"c/(c^2)" expected: @"c^(1-2)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 1.2.1" before: @"c/(c^a)" expected: @"c^(1-a)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 1.2.2" before: @"c/(c^a)" expected: @"c^(1-a)" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 1.3.1" before: @"c/(c^(1/2))" expected: @"c^(1-(1/2))" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 1.3.2" before: @"c/(c^(1/2))" expected: @"c^(1-(1/2))" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 1.4.1" before: @"c/(c^(1+2))" expected: @"c^(1-1-2)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 1.4.2" before: @"c/(c^(1+2))" expected: @"c^(1-1-2)" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 1.5.1" before: @"c/(c^(x*y))" expected: @"c^(1-x*y)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 1.5.2" before: @"c/(c^(x*y))" expected: @"c^(1-x*y)" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 1.7.1" before: @"(a+b+c)/((a+b+c)^2)" expected: @"(a+b+c)^(1-2)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 1.7.2" before: @"(a+b+c)/((a+b+c)^2)" expected: @"(a+b+c)^(1-2)" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 1.8.1" before: @"(3/4)/((3/4)^2)" expected: @"(3/4)^(1-2)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 1.8.2" before: @"(3/4)/((3/4)^2)" expected: @"(3/4)^(1-2)" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 1.9.1" before: @"(3*4)/((3*4)^2)" expected: @"(3*4)^(1-2)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 1.9.2" before: @"(3*4)/((3*4)^2)" expected: @"(3*4)^(1-2)" sourceTerm: @".1.0" targetTerm: @".0"];
	
	
	// Case 2: power/base 
	[self runTest: @"Fraction test 2.1.1" before: @"(c^2)/c" expected: @"c^(2-1)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 2.1.2" before: @"(c^2)/c" expected: @"c^(2-1)" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 2.1.3" before: @"(c^2)/c" expected: @"c^(2-1)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Fraction test 2.1.3" before: @"(c^2)/c" expected: @"c^(2-1)" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Fraction test 2.2.1" before: @"(c^a)/c" expected: @"c^(a-1)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 2.2.2" before: @"(c^a)/c" expected: @"c^(a-1)" sourceTerm: @".0.0" targetTerm: @".1"];
	
	[self runTest: @"Fraction test 2.3.1" before: @"(c^(1/2))/c" expected: @"c^((1/2)-1)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 2.3.2" before: @"(c^(1/2))/c" expected: @"c^((1/2)-1)" sourceTerm: @".0.0" targetTerm: @".1"];
	
	[self runTest: @"Fraction test 2.4.1" before: @"(c^(1+2))/c" expected: @"c^(1+2-1)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 2.4.2" before: @"(c^(1+2))/c" expected: @"c^(1+2-1)" sourceTerm: @".0.0" targetTerm: @".1"];
	
	[self runTest: @"Fraction test 2.5.1" before: @"(c^(x*y))/c" expected: @"c^(x*y-1)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 2.5.2" before: @"(c^(x*y))/c" expected: @"c^(x*y-1)" sourceTerm: @".0.0" targetTerm: @".1"];
	
	[self runTest: @"Fraction test 2.7.1" before: @"((a+b+c)^2)/(a+b+c)" expected: @"(a+b+c)^(2-1)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 2.7.2" before: @"((a+b+c)^2)/(a+b+c)" expected: @"(a+b+c)^(2-1)" sourceTerm: @".0.0" targetTerm: @".1"];
	
	[self runTest: @"Fraction test 2.8.1" before: @"((3/4)^2)/(3/4)" expected: @"(3/4)^(2-1)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 2.8.2" before: @"((3/4)^2)/(3/4)" expected: @"(3/4)^(2-1)" sourceTerm: @".0.0" targetTerm: @".1"];
	
	[self runTest: @"Fraction test 2.9.1" before: @"((3*4)^2)/(3*4)" expected: @"(3*4)^(2-1)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 2.9.2" before: @"((3*4)^2)/(3*4)" expected: @"(3*4)^(2-1)" sourceTerm: @".0.0" targetTerm: @".1"];
	
	// Case 3: baseInMulti/power 
	[self runTest: @"Fraction test 3.1" before: @"(c*d)/(c^2)" expected: @"c^(1-2)*d" sourceTerm: @".0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 3.2" before: @"(c*d)/(c^2)" expected: @"c^(1-2)*d" sourceTerm: @".1.0" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 3.3" before: @"(c*d)/(c^2)" expected: @"c^(1-2)*d" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 3.4" before: @"(c*d)/(c^2)" expected: @"c^(1-2)*d" sourceTerm: @".1" targetTerm: @".0.0"];
	
	// Case 4: power/baseInMulti
	[self runTest: @"Fraction test 4.1" before: @"(c^2)/(c*d)" expected: @"c^(2-1)/d" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 4.2" before: @"(c^2)/(c*d)" expected: @"c^(2-1)/d" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Fraction test 4.3" before: @"(c^2)/(c*d)" expected: @"c^(2-1)/d" sourceTerm: @".1.0" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 4.4" before: @"(c^2)/(c*d)" expected: @"c^(2-1)/d" sourceTerm: @".0.0" targetTerm: @".1.0"];
	
	// Case 5: power/power
	[self runTest: @"Fraction test 5.1.1" before: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.1.2" before: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Fraction test 5.1.3" before: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.1.4" before: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 5.1.5" before: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 5.1.6" before: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Fraction test 5.1.7" before: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 5.1.8" before: @"c^3/c^2" expected: @"c^(3-2)" sourceTerm: @".1.0" targetTerm: @".0.0"];
	
	[self runTest: @"Fraction test 5.2.1" before: @"c^a/c^b" expected: @"c^(a-b)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.2.2" before: @"c^a/c^b" expected: @"c^(a-b)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 5.3.1" before: @"c^(1/2)/c^(2/3)" expected: @"c^(1/2-2/3)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.3.2" before: @"c^(1/2)/c^(2/3)" expected: @"c^(1/2-2/3)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 5.4.1" before: @"c^(1+2)/c^(2-3)" expected: @"c^(1+2-2+3)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.4.2" before: @"c^(1+2)/c^(2-3)" expected: @"c^(1+2-2+3)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 5.5.1" before: @"c^(1*2)/c^(2*3)" expected: @"c^(1*2-2*3)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.5.2" before: @"c^(1*2)/c^(2*3)" expected: @"c^(1*2-2*3)" sourceTerm: @".1" targetTerm: @".0"];
	
	// different bases
	[self runTest: @"Fraction test 5.6.1" before: @"(a+b)^3/(a+b)^2" expected: @"(a+b)^(3-2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.6.2" before: @"(a+b)^3/(a+b)^2" expected: @"(a+b)^(3-2)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 5.7.1" before: @"(a/b)^3/(a/b)^2" expected: @"(a/b)^(3-2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.7.2" before: @"(a/b)^3/(a/b)^2" expected: @"(a/b)^(3-2)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 5.8.1" before: @"(a*b)^3/(a*b)^2" expected: @"(a*b)^(3-2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.8.2" before: @"(a*b)^3/(a*b)^2" expected: @"(a*b)^(3-2)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Fraction test 5.9.1" before: @"(a^b)^3/(a^b)^2" expected: @"(a^b)^(3-2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Fraction test 5.9.2" before: @"(a^b)^3/(a^b)^2" expected: @"(a^b)^(3-2)" sourceTerm: @".1" targetTerm: @".0"];
	
	// Case 6: powerInMulti/base
	[self runTest: @"Fraction test 6.1" before: @"((c^2)*d)/c" expected: @"c^(2-1)*d" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 6.2" before: @"((c^2)*d)/c" expected: @"c^(2-1)*d" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 6.3" before: @"((c^2)*d)/c" expected: @"c^(2-1)*d" sourceTerm: @".0.0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 6.4" before: @"((c^2)*d)/c" expected: @"c^(2-1)*d" sourceTerm: @".1" targetTerm: @".0.0.0"];
	
	// Case 7: base/powerInMulti
	[self runTest: @"Fraction test 7.1" before: @"c/((c^2)*d)" expected: @"c^(1-2)/d" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 7.2" before: @"c/((c^2)*d)" expected: @"c^(1-2)/d" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Fraction test 7.3" before: @"c/((c^2)*d)" expected: @"c^(1-2)/d" sourceTerm: @".0" targetTerm: @".1.0.0"];
	[self runTest: @"Fraction test 7.4" before: @"c/((c^2)*d)" expected: @"c^(1-2)/d" sourceTerm: @".1.0.0" targetTerm: @".0"];
	
	// Case 8: powerInMulti/baseInMulti
	[self runTest: @"Fraction test 8.1" before: @"((c^2)*d)/(c*d)" expected: @"(c^(2-1)*d)/d" sourceTerm: @".0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 8.2" before: @"((c^2)*d)/(c*d)" expected: @"(c^(2-1)*d)/d" sourceTerm: @".1.0" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 8.3" before: @"((c^2)*d)/(c*d)" expected: @"(c^(2-1)*d)/d" sourceTerm: @".0.0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 8.4" before: @"((c^2)*d)/(c*d)" expected: @"(c^(2-1)*d)/d" sourceTerm: @".1.0" targetTerm: @".0.0.0"];

	// Case 9: baseInMulti/powerInMulti
	[self runTest: @"Fraction test 9.1" before: @"(c*d)/((c^2)*d)" expected: @"(c^(1-2)*d)/d" sourceTerm: @".0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 9.2" before: @"(c*d)/((c^2)*d)" expected: @"(c^(1-2)*d)/d" sourceTerm: @".1.0" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 9.3" before: @"(c*d)/((c^2)*d)" expected: @"(c^(1-2)*d)/d" sourceTerm: @".0.0" targetTerm: @".1.0.0"];
	[self runTest: @"Fraction test 9.4" before: @"(c*d)/((c^2)*d)" expected: @"(c^(1-2)*d)/d" sourceTerm: @".1.0.0" targetTerm: @".0.0"];

	// Case 10: powerInMulti/power
	[self runTest: @"Fraction test 10.1" before: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 10.2" before: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 10.3" before: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".0.0.0" targetTerm: @".1"];
	[self runTest: @"Fraction test 10.4" before: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".1" targetTerm: @".0.0.0"];
	[self runTest: @"Fraction test 10.5" before: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 10.6" before: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".1.0" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 10.7" before: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".0.0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 10.8" before: @"(c^3*d)/c^2" expected: @"c^(3-2)*d" sourceTerm: @".1.0" targetTerm: @".0.0.0"];
	
	// Case 11: power/powerInMulti
	[self runTest: @"Fraction test 11.1" before: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 11.2" before: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Fraction test 11.3" before: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".0" targetTerm: @".1.0.0"];
	[self runTest: @"Fraction test 11.4" before: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".1.0.0" targetTerm: @".0"];
	[self runTest: @"Fraction test 11.5" before: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 11.6" before: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".1.0" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 11.7" before: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".0.0" targetTerm: @".1.0.0"];
	[self runTest: @"Fraction test 11.8" before: @"c^3/(c^2*d)" expected: @"c^(3-2)/d" sourceTerm: @".1.0.0" targetTerm: @".0.0"];
	
	// Case 12: powerInMult/powerInMulti
	[self runTest: @"Fraction test 12.1" before: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 12.2" before: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".1.0" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 12.3" before: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".0.0" targetTerm: @".1.0.0"];
	[self runTest: @"Fraction test 12.4" before: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".1.0.0" targetTerm: @".0.0"];
	[self runTest: @"Fraction test 12.5" before: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".0.0.0" targetTerm: @".1.0"];
	[self runTest: @"Fraction test 12.6" before: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".1.0" targetTerm: @".0.0.0"];
	[self runTest: @"Fraction test 12.7" before: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".0.0.0" targetTerm: @".1.0.0"];
	[self runTest: @"Fraction test 12.8" before: @"(c^3*d)/(c^2*d)" expected: @"c^(3-2)*d/d" sourceTerm: @".1.0.0" targetTerm: @".0.0.0"];
	
//	[self runTest: @"Power test 6.1" before: @"((x^2)^2)/(x^2)" expected: @"(x^2)^(2-1)" sourceTerm: @".1" targetTerm: @".0.0"];
//	[self runTest: @"Power test 6.2" before: @"((x^2)^2)/(x^2)" expected: @"(x^2)^(2-1)" sourceTerm: @".0.0" targetTerm: @".1"];
//	[self runTest: @"Fraction test 1.6.1" before: @"(x^2)/((x^2)^2)" expected: @"1/(x^2)^(2-1)" sourceTerm: @".0" targetTerm: @".1.0"];
//	[self runTest: @"Fraction test 1.6.2" before: @"(x^2)/((x^2)^2)" expected: @"1/(x^2)^(2-1)" sourceTerm: @".1.0" targetTerm: @".0"];

	
}

- (void) AdditionTest1 {
	
	NSLog(@"+++++ Addition Test Suite 1 - adding symbolic terms in two-term additions ++++");
		
	[self runTest: @"Addition test 1.1" before: @"a+a" expected: @"2*a" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 1.2" before: @"a+a" expected: @"2*a" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Addition test 2.1" before: @"a-a" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 2.2" before: @"a-a" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 3.1" before: @"-x+x" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 3.2" before: @"-x+x" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 4.1" before: @"x+(-x)" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 4.2" before: @"x+(-x)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 5.1" before: @"-x+(-x)" expected: @"-2*x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 5.2" before: @"-x+(-x)" expected: @"-2*x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 6.1" before: @"x-x" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 6.2" before: @"x-x" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 7.1" before: @"-x-x" expected: @"-2*x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 7.2" before: @"-x-x" expected: @"-2*x" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Addition test 8.1" before: @"x-(-x)" expected: @"2*x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 8.2" before: @"x-(-x)" expected: @"2*x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 9.1" before: @"-x-(-x)" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 9.2" before: @"-x-(-x)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 10.1" before: @"0 + x" expected: @"x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 10.2" before: @"0 + x" expected: @"x" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 10.3" before: @"x + 0" expected: @"x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 10.4" before: @"x + 0" expected: @"x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 11.1" before: @"0 - x" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 11.2" before: @"0 - x" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 11.3" before: @"x - 0" expected: @"x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 11.4" before: @"x - 0" expected: @"x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 12.1" before: @"0 - (-x)" expected: @"x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 12.2" before: @"0 - (-x)" expected: @"x" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 12.3" before: @"-x - 0" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 12.4" before: @"-x - 0" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 13.1" before: @"0 + (-x)" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 13.2" before: @"0 + (-x)" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 13.3" before: @"-x + 0" expected: @"-x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 13.4" before: @"-x + 0" expected: @"-x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 14.1" before: @"0 - x + 1 " expected: @"-x + 1" sourceTerm: @".0" targetTerm: @".2"];
	[self runTest: @"Addition test 14.2" before: @"0 - x + 1 " expected: @"1 - x" sourceTerm: @".2" targetTerm: @".0"];
	[self runTest: @"Addition test 14.3" before: @"0 - x + 1 " expected: @"-x + 1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 14.4" before: @"0 - x + 1 " expected: @"-x + 1" sourceTerm: @".1" targetTerm: @".0"];

}

- (void) AdditionTest2 {
	
	NSLog(@"+++++ Addition Test Suite 2 - adding symbolic terms in three-term additions ++++");
	
	[self runTest: @"Addition test 1.1" before: @"y + x + x" expected: @"y + 2*x" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 1.2" before: @"y + x + x" expected: @"y + 2*x" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 2.1" before: @"y + (-x) + x" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 2.2" before: @"y + (-x) + x" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 3.1" before: @"y + x + (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 3.2" before: @"y + x + (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 4.1" before: @"y + (-x) + (-x)" expected: @"y - 2*x" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 4.2" before: @"y + (-x) + (-x)" expected: @"y - 2*x" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 5.1" before: @"y + x + (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 5.2" before: @"y + x + (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 6.1" before: @"y + (-x) - x" expected: @"y - 2*x" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 6.2" before: @"y + (-x) - x" expected: @"y - 2*x" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 7.1" before: @"y + x - (-x)" expected: @"y + 2*x" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 7.2" before: @"y + x - (-x)" expected: @"y + 2*x" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 8.1" before: @"y + (-x) - (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 8.2" before: @"y + (-x) - (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 9.1" before: @"y + (-x) + x" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 9.2" before: @"y + (-x) + x" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 10.1" before: @"y - (-x) + x" expected: @"y + 2*x" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 10.2" before: @"y - (-x) + x" expected: @"y + 2*x" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 11.1" before: @"y - x + (-x)" expected: @"y - 2*x" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 11.2" before: @"y - x + (-x)" expected: @"y - 2*x" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 12.1" before: @"y - (-x) + (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 12.2" before: @"y - (-x) + (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 13.1" before: @"y - x - (-x)" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 13.2" before: @"y - x - (-x)" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 14.1" before: @"y - (-x) - x" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 14.2" before: @"y - (-x) - x" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 15.1" before: @"y - (-x) - (-x)" expected: @"y + 2*x" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 15.2" before: @"y - (-x) - (-x)" expected: @"y + 2*x" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 16.1" before: @"-x + x + (-x)" expected: @"x - 2*x" sourceTerm: @".0" targetTerm: @".2"];
	[self runTest: @"Addition test 16.2" before: @"-x + x + (-x)" expected: @"-2*x + x" sourceTerm: @".2" targetTerm: @".0"];
	
} 

- (void) AdditionTest3 {
	
	NSLog(@"+++++ Addition Test Suite 3 - adding symbolic terms in four-term additions ++++");
	
	[self runTest: @"Addition test 1.1" before: @"y + x + x - z" expected: @"y + 2*x - z" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 1.2" before: @"y + x + x - z" expected: @"y + 2*x - z" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 2.1" before: @"y + (-x) + x - z" expected: @"y + 0 - z" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 2.2" before: @"y + (-x) + x - z" expected: @"y + 0 - z" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 3.1" before: @"y + x + (-x) - z" expected: @"y + 0 - z" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 3.2" before: @"y + x + (-x) - z" expected: @"y + 0 - z" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 4.1" before: @"y + (-x) + (-x) - z" expected: @"y - 2*x - z" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 4.2" before: @"y + (-x) + (-x) - z" expected: @"y - 2*x - z" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 5.1" before: @"y - x - x + z" expected: @"y - 2*x + z" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 5.2" before: @"y - x - x + z" expected: @"y - 2*x + z" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 6.1" before: @"y - (-x) - x + z" expected: @"y + 0 + z" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 6.2" before: @"y - (-x) - x + z" expected: @"y + 0 + z" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 7.1" before: @"y - x - (-x) + z" expected: @"y + 0 + z" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 7.2" before: @"y - x - (-x) + z" expected: @"y + 0 + z" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 8.1" before: @"y - (-x) - (-x) + z" expected: @"y + 2*x + z" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 8.2" before: @"y - (-x) - (-x) + z" expected: @"y + 2*x + z" sourceTerm: @".2" targetTerm: @".1"];
	
}

- (void) AdditionTest4 {

	NSLog(@"+++++ Addition Test Suite 4 - factor symbolic terms from two-term addition ++++");

	[self runTest: @"Addition test 1.1" before: @"x*y + x*y" expected: @"2*x*y" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 1.2" before: @"x*y + x*y" expected: @"2*x*y" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 2.1" before: @"x*y + x*y" expected: @"x*(y + y)" sourceTerm: @".1.0" targetTerm: @".0.0"];
	[self runTest: @"Addition test 2.2" before: @"x*y + x*y" expected: @"x*(y + y)" sourceTerm: @".0.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 3.1" before: @"x*y - x*y" expected: @"x*(y - y)" sourceTerm: @".1.0" targetTerm: @".0.0"];
	[self runTest: @"Addition test 3.2" before: @"x*y - x*y" expected: @"x*(y - y)" sourceTerm: @".0.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 4.1" before: @"x*y + x*y" expected: @"y*(x + x)" sourceTerm: @".1.1" targetTerm: @".0.1"];
	[self runTest: @"Addition test 4.2" before: @"x*y + x*y" expected: @"y*(x + x)" sourceTerm: @".0.1" targetTerm: @".1.1"];
	
	[self runTest: @"Addition test 5.1" before: @"x*y - x*y" expected: @"y*(x - x)" sourceTerm: @".1.1" targetTerm: @".0.1"];
	[self runTest: @"Addition test 5.2" before: @"x*y - x*y" expected: @"y*(x - x)" sourceTerm: @".0.1" targetTerm: @".1.1"];
	
}

- (void) AdditionTest4_1 {
	
	// TODO: finish me
	NSLog(@"+++++ Addition Test Suite 4_1 - factor symbolic terms, mixing positive and negative terms ++++");
	
	[self runTest: @"Addition test 1.1" before: @"y + x*y + x*y" expected: @"y + x*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 1.2" before: @"y + x*y + x*y" expected: @"y + x*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 2.1" before: @"y + x*y - x*y" expected: @"y + x*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 2.2" before: @"y + x*y - x*y" expected: @"y + x*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 3.1" before: @"y - x*y + x*y" expected: @"y - x*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 3.2" before: @"y - x*y + x*y" expected: @"y - x*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 4.1" before: @"y - x*y - x*y" expected: @"y - x*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 4.2" before: @"y - x*y - x*y" expected: @"y - x*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 5.1" before: @"y + x*y + (-x)*y" expected: @"y + x*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 5.2" before: @"y + x*y + (-x)*y" expected: @"y + x*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 6.1" before: @"y + x*y - (-x)*y" expected: @"y + x*(y - (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 6.2" before: @"y + x*y - (-x)*y" expected: @"y + x*(y - (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 7.1" before: @"y - x*y + (-x)*y" expected: @"y - x*(y - (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 7.2" before: @"y - x*y + (-x)*y" expected: @"y - x*(y - (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 8.1" before: @"y - x*y - (-x)*y" expected: @"y - x*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 8.2" before: @"y - x*y - (-x)*y" expected: @"y - x*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 9.1" before: @"y + (-x)*y + x*y" expected: @"y + x*(-y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 9.2" before: @"y + (-x)*y + x*y" expected: @"y + x*(-y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
		
	[self runTest: @"Addition test 10.1" before: @"y + (-x)*y - x*y" expected: @"y + x*(-y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 10.2" before: @"y + (-x)*y - x*y" expected: @"y + x*(-y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 11.1" before: @"y - (-x)*y + x*y" expected: @"y - x*(-y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 11.2" before: @"y - (-x)*y + x*y" expected: @"y - x*(-y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 12.1" before: @"y - (-x)*y - x*y" expected: @"y - x*(-y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 12.2" before: @"y - (-x)*y - x*y" expected: @"y - x*(-y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 13.1" before: @"y + (-x)*y + (-x)*y" expected: @"y + (-x)*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 13.2" before: @"y + (-x)*y + (-x)*y" expected: @"y + (-x)*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 14.1" before: @"y + (-x)*y - (-x)*y" expected: @"y + (-x)*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 14.2" before: @"y + (-x)*y - (-x)*y" expected: @"y + (-x)*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 15.1" before: @"y - (-x)*y + (-x)*y" expected: @"y - (-x)*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 15.2" before: @"y - (-x)*y + (-x)*y" expected: @"y - (-x)*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 16.1" before: @"y - (-x)*y - (-x)*y" expected: @"y - (-x)*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 16.2" before: @"y - (-x)*y - (-x)*y" expected: @"y - (-x)*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
}

- (void) AdditionTest4_2 {
	
	NSLog(@"+++++ Addition Test Suite 4_2 - factor integer terms, mixing positive and negative integers ++++");

	[self runTest: @"Addition test 1.1" before: @"y + 2*y + 2*y" expected: @"y + 2*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 1.2" before: @"y + 2*y + 2*y" expected: @"y + 2*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 2.1" before: @"y + 2*y - 2*y" expected: @"y + 2*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 2.2" before: @"y + 2*y - 2*y" expected: @"y + 2*(y - y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 3.1" before: @"y - 10*y + 10*y" expected: @"y - 10*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 3.2" before: @"y - 10*y + y*10" expected: @"y - 10*(y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 4.1" before: @"y - 1*y - 1*y" expected: @"y - 1*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 4.2" before: @"y - 1*y - y*1" expected: @"y - 1*(y + y)" sourceTerm: @".2.1" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 5.1" before: @"y + 2*y + (-2)*y" expected: @"y + 2*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 5.2" before: @"y + 2*y + (-2)*y" expected: @"y + 2*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 5.1" before: @"y + 2*y + (-2)*y" expected: @"y + 2*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 5.2" before: @"y + 2*y + (-2)*y" expected: @"y + 2*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 6.1" before: @"y + 4*y - (-4)*y" expected: @"y + 4*(y - (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 6.2" before: @"y + 4*y - (-4)*y" expected: @"y + 4*(y - (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 7.1" before: @"y - 10*y + (-10)*y" expected: @"y - 10*(y - (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 7.2" before: @"y - 10*y + (-10)*y" expected: @"y - 10*(y - (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 8.1" before: @"y - 1*y - (-1)*y" expected: @"y - 1*(y + (-y))" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 8.2" before: @"y - 1*y - (-1)*y" expected: @"y - 1*(y + (-y))" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 9.1" before: @"y + (-2)*y + 2*y" expected: @"y + 2*(-y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 9.2" before: @"y + (-2)*y + y*2" expected: @"y + 2*(-y + y)" sourceTerm: @".2.1" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 10.1" before: @"y + (-4)*y - 4*y" expected: @"y + 4*(-y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 10.2" before: @"y + (-4)*y - y*4" expected: @"y + 4*(-y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 11.1" before: @"y - (-10)*y + 10*y" expected: @"y - 10*(-y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 11.2" before: @"y - (-10)*y + y*10" expected: @"y - 10*(-y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 12.1" before: @"y - (-1)*y - 1*y" expected: @"y - 1*(-y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 12.2" before: @"y - (-1)*y - y*1" expected: @"y - 1*(-y + y)" sourceTerm: @".2.1" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 13.1" before: @"y + (-2)*y + (-2)*y" expected: @"y + (-2)*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 13.2" before: @"y + (-2)*y + y*(-2)" expected: @"y + (-2)*(y + y)" sourceTerm: @".2.1" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 14.1" before: @"y + (-4)*y - (-4)*y" expected: @"y + (-4)*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 14.2" before: @"y + (-4)*y - y*(-4)" expected: @"y + (-4)*(y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 15.1" before: @"y - (-10)*y + (-10)*y" expected: @"y - (-10)*(y - y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 15.2" before: @"y - (-10)*y + y*(-10)" expected: @"y - (-10)*(y - y)" sourceTerm: @".2.1" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 16.1" before: @"y - (-1)*y - (-1)*y" expected: @"y - (-1)*(y + y)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 16.2" before: @"y - (-1)*y - (-1)*y" expected: @"y - (-1)*(y + y)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 17.1" before: @"-3 - x*9" expected: @"3*(-1 - x*3)" sourceTerm: @".0.0" targetTerm: @".1.1"];
	[self runTest: @"Addition test 17.2" before: @"-3 - x*9" expected: @"3*(-1 - x*3)" sourceTerm: @".1.1" targetTerm: @".0.0"];
	
	[self runTest: @"Addition test 18.1" before: @"2*(x+6) - 14" expected: @"2*(x + 6 - 7)" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Addition test 18.2" before: @"2*(x+6) - 14" expected: @"2*(x + 6 - 7)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Addition test 18.3" before: @"2*(x+6) + (-14)" expected: @"2*(x + 6 + (-7))" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Addition test 18.4" before: @"2*(x+6) + (-14)" expected: @"2*(x + 6 + (-7))" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Addition test 18.5" before: @"-2*(x+6) - 14" expected: @"2*(-1*(x + 6) - 7)" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Addition test 18.6" before: @"-2*(x+6) - 14" expected: @"2*(-1*(x + 6) - 7)" sourceTerm: @".1" targetTerm: @".0.0"];
	[self runTest: @"Addition test 18.7" before: @"-2*(x+6) + (-14)" expected: @"2*(-1*(x + 6) + (-7))" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Addition test 18.8" before: @"-2*(x+6) + (-14)" expected: @"2*(-1*(x + 6) + (-7))" sourceTerm: @".1" targetTerm: @".0.0"];

	[self runTest: @"Addition test 19.1" before: @"2*(x+6) + 14" expected:nil sourceTerm: @".0.1.1" targetTerm: @".1"];
	[self runTest: @"Addition test 19.1" before: @"2*(x+6) + 14" expected:nil sourceTerm: @".1" targetTerm: @".0.1.1"];
}

- (void) AdditionTest4_3 {
	
	NSLog(@"+++++ Addition Test Suite 4_3 - adding/factoring powers of the form y + n + n^2 = y + n*(1 + n) ++++");
	
	[self runTest: @"Addition test 1.1" before: @"y + x^2 + x^2" expected: @"y + 2*x^2" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 1.2" before: @"y + x^2 + x^2" expected: @"y + 2*x^2" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 2.1" before: @"y + x^2 - x^2" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 2.2" before: @"y + x^2 - x^2" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 3.1" before: @"y + (-(x^2)) + x^2" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 3.2" before: @"y + (-(x^2)) + x^2" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 4.1" before: @"y + x^2 + (-(x^2))" expected: @"y + 0" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 4.2" before: @"y + x^2 + (-(x^2))" expected: @"y + 0" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 5.1" before: @"y + x^2 + x" expected: @"y + x*(x + 1)" sourceTerm: @".1.0" targetTerm: @".2"];
	[self runTest: @"Addition test 5.2" before: @"y + x^2 + x" expected: @"y + x*(x + 1)" sourceTerm: @".2" targetTerm: @".1.0"];
	[self runTest: @"Addition test 5.3" before: @"y + x^2 + x" expected: @"y + x*(x + 1)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 5.4" before: @"y + x^2 + x" expected: @"y + x*(x + 1)" sourceTerm: @".2" targetTerm: @".1"];
		
	[self runTest: @"Addition test 6.1" before: @"y + x^2 - x" expected: @"y + x*(x - 1)" sourceTerm: @".1.0" targetTerm: @".2"];
	[self runTest: @"Addition test 6.2" before: @"y + x^2 - x" expected: @"y + x*(x - 1)" sourceTerm: @".2" targetTerm: @".1.0"];
	[self runTest: @"Addition test 6.3" before: @"y + x^2 - x" expected: @"y + x*(x - 1)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 6.3" before: @"y + x^2 - x" expected: @"y + x*(x - 1)" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 7.1" before: @"y + x + x^2" expected: @"y + x*(1 + x)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 7.2" before: @"y + x + x^2" expected: @"y + x*(1 + x)" sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 7.3" before: @"y + x - x^2" expected: @"y + x*(1 - x)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 7.3" before: @"y + x - x^2" expected: @"y + x*(1 - x)" sourceTerm: @".2" targetTerm: @".1"];

	[self runTest: @"Addition test 8.1" before: @"y + (-x) + x^2" expected: @"y + x*(-1 + x)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 8.2" before: @"y - (-x) + x^2" expected: @"y - x*(-1 - x)" sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 8.3" before: @"y + (-x) - x^2" expected: @"y + x*(-1 - x)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 8.4" before: @"y - (-x) - x^2" expected: @"y - x*(-1 + x)" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 9.1" before: @"y + (-x) + (-x^2)" expected: @"y + x*(-1 + (-x))" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 9.2" before: @"y - (-x) + (-x^2)" expected: @"y - x*(-1 - (-x))" sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 9.3" before: @"y + (-x) - (-x^2)" expected: @"y + x*(-1 - (-x))" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 9.4" before: @"y - (-x) - (-x^2)" expected: @"y - x*(-1 + (-x))" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 9.1.1" before: @"y + (-x) + (-x)^2" expected: nil sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 9.1.2" before: @"y -   x  + (-x)^2" expected: nil sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 9.1.3" before: @"y + (-x) - (-x)^2" expected: nil sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 9.1.4" before: @"y -   x  - (-x)^2" expected: nil sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 10.1" before: @"x + x^2" expected: @"x*(1 + x)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 10.2" before: @"x - x^2" expected: @"x*(1 - x)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 10.3" before: @"(-x) + x^2" expected: @"x*(-1 + x)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 10.4" before: @"(-x) - x^2" expected: @"x*(-1 - x)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 10.5" before: @"(-x) + (-x^2)" expected: @"x*(-1 + (-x))" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 10.6" before: @"(-x) - (-x^2)" expected: @"x*(-1 - (-x))" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 11.1" before: @"2 + 2^3" expected: @"2*(1 + 2^2)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 11.2" before: @"-2 + 2^3" expected: @"2*(-1 + 2^2)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 11.3" before: @"2 - 2^3" expected: @"2*(1 - 2^2)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 11.4" before: @"-2 - 2^3" expected: @"2*(-1 - 2^2)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 11.5" before: @"y - 2 + 2^3" expected: @"y - 2*(1 - 2^2)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 11.6" before: @"y - (-2) + 2^3" expected: @"y - 2*(-1 - 2^2)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 11.7" before: @"y - 2 - 2^3" expected: @"y - 2*(1 + 2^2)" sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 11.8" before: @"y - (-2) - 2^3" expected: @"y - 2*(-1 + 2^2)" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 12.1" before: @"(x*y) + (x*y)^3" expected: @"x*y*(1 + (x*y)^2)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 12.2" before: @"(x*y) - (x*y)^3" expected: @"x*y*(1 - (x*y)^2)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 12.3" before: @"y - (x*y) + (x*y)^3" expected: @"y - x*y*(1 - (x*y)^2)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 12.4" before: @"y - (x*y) - (x*y)^3" expected: @"y - x*y*(1 + (x*y)^2)" sourceTerm: @".2" targetTerm: @".1"];

	[self runTest: @"Addition test 13.1" before: @"y - (1/2) + (1/2)^3" expected: @"y - (1/2)*(1 - (1/2)^2)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 13.2" before: @"y - (1/2) - (1/2)^3" expected: @"y - (1/2)*(1 + (1/2)^2)" sourceTerm: @".2" targetTerm: @".1"];
}

- (void) AdditionTest4_4 {
	
	NSLog(@"+++++ Addition Test Suite 4_4 - factoring powers of the form y + n*m + n^2 = y + n*(m + n) ++++");
	
	[self runTest: @"Addition test 1.1" before: @"y + x^2 + x*m" expected: @"y + x*(x + m)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 1.2" before: @"y + x^2 + x*m" expected: @"y + x*(x + m)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	[self runTest: @"Addition test 1.3" before: @"y + x^2 + x*m" expected: @"y + x*(x + m)" sourceTerm: @".1" targetTerm: @".2.0"];
	[self runTest: @"Addition test 1.4" before: @"y + x^2 + x*m" expected: @"y + x*(x + m)" sourceTerm: @".2.0" targetTerm: @".1"];

	[self runTest: @"Addition test 2.1" before: @"y - x^2 + x*m" expected: @"y - x*(x - m)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 2.2" before: @"y - x^2 + x*m" expected: @"y - x*(x - m)" sourceTerm: @".2.0" targetTerm: @".1.0"];
	[self runTest: @"Addition test 2.3" before: @"y + x^2 - x*m" expected: @"y + x*(x - m)" sourceTerm: @".1" targetTerm: @".2.0"];
	[self runTest: @"Addition test 2.4" before: @"y + x^2 - x*m" expected: @"y + x*(x - m)" sourceTerm: @".2.0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 3.1" before: @"y + m*(-x) + x^2" expected: @"y + x*(-m + x)" sourceTerm: @".1.1" targetTerm: @".2"];
	[self runTest: @"Addition test 3.2" before: @"y - m*(-x) + x^2" expected: @"y - x*(-m - x)" sourceTerm: @".2" targetTerm: @".1.1"];
	[self runTest: @"Addition test 3.3" before: @"y + (-m)*(-x) - x^2" expected: @"y + x*(m - x)" sourceTerm: @".1.1" targetTerm: @".2"];
	[self runTest: @"Addition test 3.4" before: @"y - (-m)*(-x) - x^2" expected: @"y - x*(m + x)" sourceTerm: @".2" targetTerm: @".1.1"];
	
	[self runTest: @"Addition test 4.1" before: @"y + m*(-x) + (-x^2)" expected: @"y + x*(-m + (-x))" sourceTerm: @".1.1" targetTerm: @".2"];
	[self runTest: @"Addition test 4.2" before: @"y - m*(-x) + (-x^2)" expected: @"y - x*(-m - (-x))" sourceTerm: @".2" targetTerm: @".1.1"];
	[self runTest: @"Addition test 4.3" before: @"y + (-x)*(-m) - (-x^2)" expected: @"y + x*(m - (-x))" sourceTerm: @".1.0" targetTerm: @".2"];
	[self runTest: @"Addition test 4.4" before: @"y - (-x)*(-m) - (-x^2)" expected: @"y - x*(m + (-x))" sourceTerm: @".2" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 5.1" before: @"y + m*(-x) + (-x)^2" expected: nil sourceTerm: @".1.1" targetTerm: @".2"];
	[self runTest: @"Addition test 5.2" before: @"y -  m*x  + (-x)^2" expected: nil sourceTerm: @".2" targetTerm: @".1.1"];
	[self runTest: @"Addition test 5.3" before: @"y + (-x)*(-m) - (-x)^2" expected: nil	sourceTerm: @".1.0" targetTerm: @".2"];
	[self runTest: @"Addition test 5.4" before: @"y - x*(-m)  - (-x)^2" expected: nil sourceTerm: @".2" targetTerm: @".1.0"];
}

- (void) AdditionTest4_5 {
	
	NSLog(@"+++++ Addition Test Suite 4_5 - factoring powers of the form y + n*m + x*n^2 = y + n*(m + x*n) ++++");
	
	[self runTest: @"Addition test 1.1" before: @"y + z*x^2 + x*m" expected: @"y + x*(z*x + m)" sourceTerm: @".1.1" targetTerm: @".2.0"];
	[self runTest: @"Addition test 1.2" before: @"y + z*x^2 + x*m" expected: @"y + x*(z*x + m)" sourceTerm: @".2.0" targetTerm: @".1.1.0"];
	[self runTest: @"Addition test 1.3" before: @"y + x^2*z + x*m" expected: @"y + x*(x*z + m)" sourceTerm: @".1.0" targetTerm: @".2.0"];
	[self runTest: @"Addition test 1.4" before: @"y + x^2*z + x*m" expected: @"y + x*(x*z + m)" sourceTerm: @".2.0" targetTerm: @".1.0.0"];
	
	[self runTest: @"Addition test 2.1" before: @"y - z*x^2 + x" expected: @"y - x*(z*x - 1)" sourceTerm: @".1.1.0" targetTerm: @".2"];
	[self runTest: @"Addition test 2.2" before: @"y - x^2*z + x" expected: @"y - x*(z*x - 1)" sourceTerm: @".2" targetTerm: @".1.0.0"];
	[self runTest: @"Addition test 2.3" before: @"y + z*x^2 - x" expected: @"y + x*(x*z - 1)" sourceTerm: @".1.1" targetTerm: @".2"];
	[self runTest: @"Addition test 2.4" before: @"y + x^2*z - x" expected: @"y + x*(x*z - 1)" sourceTerm: @".2" targetTerm: @".1.0"];
	
	[self runTest: @"Addition test 3.1" before: @"y + m*(-x) + z*(-x)^2" expected: nil sourceTerm: @".1.1" targetTerm: @".2.1"];
	[self runTest: @"Addition test 3.2" before: @"y -  m*x  + (-x)^2*z" expected: nil sourceTerm: @".2.0" targetTerm: @".1.1"];
	[self runTest: @"Addition test 3.3" before: @"y + (-x) - z*(-x)^2" expected: nil sourceTerm: @".1" targetTerm: @".2.1"];
	[self runTest: @"Addition test 3.4" before: @"y - x - (-x)^2*z" expected: nil sourceTerm: @".2.0" targetTerm: @".1"];

	[self runTest: @"Addition test 4.1" before: @"y + z*(a+b)^2 + (a+b)*m" expected: @"y + (a+b)*(z*(a+b) + m)" sourceTerm: @".1.1" targetTerm: @".2.0"];
	[self runTest: @"Addition test 4.2" before: @"y + z*(a/b)^2 + (a/b)*m" expected: @"y + (a/b)*(z*(a/b) + m)" sourceTerm: @".2.0" targetTerm: @".1.1.0"];
	
}

- (void) AdditionTest4_6 {
	
	NSLog(@"+++++ Addition Test Suite 4_6 - factoring powers of the form y + n^3*m + x*n^2 = y + n^2*(n*m + x) ++++");
	
	[self runTest: @"Addition test 1.1" before: @"y + z*x^0 + x^1*m" expected: nil sourceTerm: @".2.0" targetTerm: @".1.1"];
	[self runTest: @"Addition test 1.2" before: @"y + z*x^1 + x^2*m" expected: @"y + x*(z + x*m)" sourceTerm: @".1.1" targetTerm: @".2.0"];
	[self runTest: @"Addition test 1.3" before: @"y + z*x^2 + x^3*m" expected: @"y + x^2*(z + x*m)" sourceTerm: @".2.0" targetTerm: @".1.1"];
	[self runTest: @"Addition test 1.4" before: @"y + z*x^3 + x^5*m" expected: @"y + x^3*(z + x^2*m)" sourceTerm: @".1.1" targetTerm: @".2.0"];

	[self runTest: @"Addition test 2.1" before: @"y + x^0 + x^1" expected: nil sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 2.2" before: @"y + x^1 + x^2" expected: @"y + x*(1 + x)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 2.3" before: @"y + x^2 + x^3" expected: @"y + x^2*(1 + x)" sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 2.4" before: @"y + x^3 + x^5" expected: @"y + x^3*(1 + x^2)" sourceTerm: @".1" targetTerm: @".2"];

	[self runTest: @"Addition test 3.1" before: @"y - x^1 + x^2" expected: @"y - x*(1 - x)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 3.2" before: @"y + x^2 - x^3" expected: @"y + x^2*(1 - x)" sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 3.3" before: @"y - x^3 - x^5" expected: @"y - x^3*(1 + x^2)" sourceTerm: @".1" targetTerm: @".2"];
	
	[self runTest: @"Addition test 4.1" before: @"y - (-x)^1 + x^2" expected: nil sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 4.2" before: @"y + x^2 - (-x)^3" expected: nil sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 4.3" before: @"y - x^3 - (-x)^5" expected: nil sourceTerm: @".1" targetTerm: @".2"];

	[self runTest: @"Addition test 5.1" before: @"y - (-(x^1)) + x^2" expected: @"y - x*(-1 - x)" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 5.2" before: @"y + x^2 - (-(x^3))" expected: @"y + x^2*(1 - (-x))" sourceTerm: @".2" targetTerm: @".1"];
	[self runTest: @"Addition test 5.3" before: @"y - x^3 - (-(x^5))" expected: @"y - x^3*(1 + (-(x^2)))" sourceTerm: @".1" targetTerm: @".2"];
	
	// TODO: finish me
	
}	

- (void) AdditionTest5 {

	NSLog(@"+++++ Addition Test Suite 5 - factor symbolic terms, both terms have multiple terms, from two-term addition ++++");
		
	[self runTest: @"Addition test 1.1" before: @"x*y*z + x*y*z" expected: @"2*x*y*z" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 1.2" before: @"x*y*z + x*y*z" expected: @"2*x*y*z" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 2.1" before: @"x*y*z - x*y*z" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 2.2" before: @"x*y*z - x*y*z" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 3.1" before: @"x*y*z + z*y*x" expected: @"x*(y*z + z*y)" sourceTerm: @".0.0" targetTerm: @".1.2"];
	[self runTest: @"Addition test 3.2" before: @"x*y*z + z*y*x" expected: @"x*(y*z + z*y)" sourceTerm: @".1.2" targetTerm: @".0.0"];
	
	[self runTest: @"Addition test 4.1" before: @"x*y*z + z*y*x" expected: @"y*(x*z + z*x)" sourceTerm: @".0.1" targetTerm: @".1.1"];
	[self runTest: @"Addition test 4.2" before: @"x*y*z + z*y*x" expected: @"y*(x*z + z*x)" sourceTerm: @".1.1" targetTerm: @".0.1"];
	
	[self runTest: @"Addition test 5.1" before: @"x*y*z + z*y*x" expected: @"z*(x*y + y*x)" sourceTerm: @".0.2" targetTerm: @".1.0"];
	[self runTest: @"Addition test 5.2" before: @"x*y*z + z*y*x" expected: @"z*(x*y + y*x)" sourceTerm: @".1.0" targetTerm: @".0.2"];
	
	[self runTest: @"Addition test 6.1" before: @"x*y*z - z*y*x" expected: @"x*(y*z - z*y)" sourceTerm: @".0.0" targetTerm: @".1.2"];
	[self runTest: @"Addition test 6.2" before: @"x*y*z - z*y*x" expected: @"x*(y*z - z*y)" sourceTerm: @".1.2" targetTerm: @".0.0"];
	
	[self runTest: @"Addition test 7.1" before: @"x*y*z - z*y*x" expected: @"y*(x*z - z*x)" sourceTerm: @".0.1" targetTerm: @".1.1"];
	[self runTest: @"Addition test 7.2" before: @"x*y*z - z*y*x" expected: @"y*(x*z - z*x)" sourceTerm: @".1.1" targetTerm: @".0.1"];
	
	[self runTest: @"Addition test 8.1" before: @"x*y*z - z*y*x" expected: @"z*(x*y - y*x)" sourceTerm: @".0.2" targetTerm: @".1.0"];
	[self runTest: @"Addition test 8.2" before: @"x*y*z - z*y*x" expected: @"z*(x*y - y*x)" sourceTerm: @".1.0" targetTerm: @".0.2"];
	
}

- (void) AdditionTest6 {
	
	NSLog(@"+++++ Addition Test Suite 6 - factor symbolic terms, mixing single and multiple terms, from two-term addition ++++");

	[self runTest: @"Addition test 1.1" before: @"x*y*z + x" expected: @"x*(y*z + 1)" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Addition test 1.2" before: @"x*y*z + x" expected: @"x*(y*z + 1)" sourceTerm: @".1" targetTerm: @".0.0"];

	[self runTest: @"Addition test 2.1" before: @"x*y*z + y" expected: @"y*(x*z + 1)" sourceTerm: @".0.1" targetTerm: @".1"];
	[self runTest: @"Addition test 2.2" before: @"x*y*z + y" expected: @"y*(x*z + 1)" sourceTerm: @".1" targetTerm: @".0.1"];

	[self runTest: @"Addition test 3.1" before: @"x*y*z + z" expected: @"z*(x*y + 1)" sourceTerm: @".0.2" targetTerm: @".1"];
	[self runTest: @"Addition test 3.2" before: @"x*y*z + z" expected: @"z*(x*y + 1)" sourceTerm: @".1" targetTerm: @".0.2"];
	
	[self runTest: @"Addition test 4.1" before: @"x - x*y*z" expected: @"x*(1 - y*z)" sourceTerm: @".0" targetTerm: @".1.0"];
	[self runTest: @"Addition test 4.2" before: @"x - x*y*z" expected: @"x*(1 - y*z)" sourceTerm: @".1.0" targetTerm: @".0"];
	
	[self runTest: @"Addition test 5.1" before: @"y - x*y*z" expected: @"y*(1 - x*z)" sourceTerm: @".0" targetTerm: @".1.1"];
	[self runTest: @"Addition test 5.2" before: @"y - x*y*z" expected: @"y*(1 - x*z)" sourceTerm: @".1.1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 6.1" before: @"z - x*y*z" expected: @"z*(1 - x*y)" sourceTerm: @".0" targetTerm: @".1.2"];
	[self runTest: @"Addition test 6.2" before: @"z - x*y*z" expected: @"z*(1 - x*y)" sourceTerm: @".1.2" targetTerm: @".0"];
	
	[self runTest: @"Addition test 7.1" before: @"y - (-x) - 2*x" expected: @"y - x*(-1 + 2)" sourceTerm: @".1" targetTerm: @".2.1"];
	[self runTest: @"Addition test 7.2" before: @"y - (-x) - 2*x" expected: @"y - x*(-1 + 2)" sourceTerm: @".2.1" targetTerm: @".1"];
	
}

- (void) AdditionTest7 {
	
	NSLog(@"+++++ Addition Test Suite 7 - Adding simple integers ++++");

	[self runTest: @"Addition test 1.1" before: @"0 + 0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 1.2" before: @"0 + 0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 2.1" before: @"1 + 0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 2.2" before: @"1 + 0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 3.1" before: @"0 + 1" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 3.2" before: @"0 + 1" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 4.1" before: @"0 + (-1)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 4.2" before: @"0 + (-1)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 5.1" before: @"1 + (-1)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 5.2" before: @"1 + (-1)" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 6.1" before: @"-1 + (-1)" expected: @"-2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 6.2" before: @"-1 + (-1)" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 5.1" before: @"1 + (-1)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 5.2" before: @"1 + (-1)" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	
	// TODO: test min/max
	// 1 + MAX will roll to MIN
	// MIN + MAX
}

- (void) AdditionTest8 {
	
	NSLog(@"+++++ Addition Test Suite 8 - Subtracting simple integers ++++");
	
	[self runTest: @"Addition test 1.1" before: @"0 - 0" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 1.2" before: @"0 - 0" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 2.1" before: @"0 - 1" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 2.2" before: @"0 - 1" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 3.1" before: @"5 - 2" expected: @"3" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 3.2" before: @"5 - 2" expected: @"3" sourceTerm: @".0" targetTerm: @".1"];

	[self runTest: @"Addition test 4.1" before: @"1 - (-1)" expected: @"2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 4.2" before: @"1 - (-1)" expected: @"2" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 5.1" before: @"-1 - 1" expected: @"-2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 5.2" before: @"-1 - 1" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 6.1" before: @"2 - 2" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 6.2" before: @"2 - 2" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	
}

- (void) AdditionTest9 {
	
	NSLog(@"+++++ Addition Test Suite 9 - Adding fractions ++++");
	
	[self runTest: @"Addition test 1.1" before: @"1/2 + 2/2" expected: @"(1 + 2)/2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 1.2" before: @"1/2 + 2/2" expected: @"(1 + 2)/2" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 2.1" before: @"1/2 - 2/2" expected: @"(1 - 2)/2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 2.2" before: @"1/2 - 2/2" expected: @"(1 - 2)/2" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Addition test 3.1" before: @"1 + 1/2 + 2/2" expected: @"1 + (1 + 2)/2" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 3.2" before: @"1 + 1/2 + 2/2" expected: @"1 + (1 + 2)/2" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 4.1" before: @"1 + 1/2 - 2/2" expected: @"1 + (1 - 2)/2" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 4.2" before: @"1 + 1/2 - 2/2" expected: @"1 + (1 - 2)/2" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 5.1" before: @"1 - 1/2 + 2/2" expected: @"1 - (1 - 2)/2" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 5.2" before: @"1 - 1/2 + 2/2" expected: @"1 - (1 - 2)/2" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 6.1" before: @"1 + 1/2 - 2/2" expected: @"1 + (1 - 2)/2" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 6.2" before: @"1 + 1/2 - 2/2" expected: @"1 + (1 - 2)/2" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 7.1" before: @"1 - 1/2 - 2/2" expected: @"1 - (1 + 2)/2" sourceTerm: @".1" targetTerm: @".2"];
	[self runTest: @"Addition test 7.2" before: @"1 - 1/2 - 2/2" expected: @"1 - (1 + 2)/2" sourceTerm: @".2" targetTerm: @".1"];
	
	[self runTest: @"Addition test 8.1" before: @"a/c + b/c" expected: @"(a + b)/c" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Addition test 8.2" before: @"a/c + b/c" expected: @"(a + b)/c" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest:@"Addition test 9" before:@"a/b - (c - d)/b" expected:@"(a - c + d)/b" sourceTerm:@".0" targetTerm:@".1"];
}

- (void) AdditionTest10 {
	
	NSLog(@"+++++ Addition Test Suite 10 - Swap the order of terms in an addition ++++");
	
	//	TEST 1
	// a - b + c - 1 + 2 - 3 to -3 + c - b + 2 - 1 + a
	a1 = [[Addition alloc] init: a, b, c, one, two, three, nil];
	[a1 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	[a1 setOperator:SUBTRACTION_OPERATOR atIndex:3];
	[a1 setOperator:SUBTRACTION_OPERATOR atIndex:5];
	a2 = [[Addition alloc] init: minusThree, c, b, a, two, one, nil];
	[a2 setOperator:SUBTRACTION_OPERATOR atIndex:2];
	[a2 setOperator:SUBTRACTION_OPERATOR atIndex:5];
	t1 = [Term copyTerm:a1 reducingWithSubTerm:[a1 termAtPath:@".5"] andSubTerm:[a1 termAtPath:@".0"]];
	// -3 - b + c - 1 + 2 + a
	t2 = [Term copyTerm:t1 reducingWithSubTerm:[t1 termAtPath:@".3"] andSubTerm:[t1 termAtPath:@".5"]];
	// -3 - b + c + a + 2 - 1
	[t1 release];
	t1 = [Term copyTerm:t2 reducingWithSubTerm:[t2 termAtPath:@".1"] andSubTerm:[t2 termAtPath:@".2"]];
	// -3 + c - b + a + 2 - 1
	[t2 release];
	[self printTestResults:@"Addition test 1" before:a1 after:t1 expected:a2];	
	[t1 release];
	[a1 release];
	[a2 release];	
}

- (void) AdditionTest11 {
	
	NSLog(@"+++++ Addition Test Suite 11 - Appending additions ++++");
	
	// TEST 1
	// 1 + (x + 1) = 1 + x + 1
	a1 = [[Addition alloc] init:one, nil];
	a2 = [[Addition alloc] init: x, one, nil];
	[a1 appendTerm:a2];
	a3 = [[Addition alloc] init: one, x, one, nil];
	[self printTestResults:@"Addition test 1" before:a1 after:a1 expected:a3];	
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
	[self printTestResults:@"Addition test 2" before:a1 after:a1 expected:a3];	
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
	[self printTestResults:@"Addition test 3" before:a1 after:a1 expected:a3];	
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
	[self printTestResults:@"Addition test 4" before:a1 after:a1 expected:a3];	
	[a1 release];
	[a2 release];	
	[a3 release];	

	// TEST 11
	// x - (1 - x)*1 to x - 1 + x
	a1 = [[Addition alloc] init:one, x, nil];
	[a1 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	m1 = [[Multiplication alloc] init:a1, one, nil];
	a2 = [[Addition alloc] init: x, m1, nil];
	[a2 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	a3 = [[Addition alloc] init: x, one, x, nil];
	[a3 setOperator:SUBTRACTION_OPERATOR atIndex:1];
	t1 = [Term copyTerm:a2 reducingWithSubTerm:[a2 termAtPath:@".1.1"] andSubTerm:[a2 termAtPath:@".1.0"]];
	[self printTestResults:@"Addition test 11" before:a2 after:t1 expected:a3];	
	[t1 release];
	[m1 release];
	[a1 release];
	[a2 release];	
	[a3 release];	

}

- (void) AdditionTest12 {
	
	NSLog(@"+++++ Addition Test Suite 12 - Add infinity ++++");
	
	// TEST 1
	// 1 + ∞ = ∞
	a1 = [[Addition alloc] init:one, [Constant infinity], nil];
	t1 = [Term copyTerm:a1 reducingWithSubTerm:[a1 termAtPath:@".0"] andSubTerm:[a1 termAtPath:@".1"]];
	[self printTestResults:@"Addition test 1" before:a1 after:t1 expected:[Constant infinity]];	
	[a1 release];
	[t1 release];	

	// TEST 2
	// 1 + c + a + ∞ = ∞
	a1 = [[Addition alloc] init:one, c, a, [Constant infinity], nil];
	t1 = [Term copyTerm:a1 reducingWithSubTerm:[a1 termAtPath:@".2"] andSubTerm:[a1 termAtPath:@".3"]];
	[self printTestResults:@"Addition test 2" before:a1 after:t1 expected:[Constant infinity]];	
	[a1 release];
	[t1 release];	
}

- (void) AdditionTest13 {
	
	NSLog(@"+++++ Addition Test Suite 13 - Add terms of the form n*x + n*x ++++");
	[self runTest: @"Addition test 1.1" before: @"1*x + 2*x" expected: @"3*x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 1.2" before: @"1*x + 2*x" expected: @"3*x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 2.1" before: @"0*x + 2*x" expected: @"2*x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 2.2" before: @"2*x + 0*x" expected: @"2*x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 3.1" before: @"0*x + 0*x" expected: @"0*x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 3.2" before: @"0*x + 0*x" expected: @"0*x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 4.1" before: @"-1*x + 1*x" expected: @"0*x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 4.2" before: @"1*x + (-1)*x" expected: @"0*x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 5.1" before: @"-1*x + (-1)*x" expected: @"-2*x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 5.2" before: @"-1*x + x*(-1)" expected: @"-2*x" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 6.1" before: @"1*y + 2*x" expected: nil sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 6.2" before: @"1*y + x*2" expected: nil sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 7.1" before: @"1*(2 + 4) + 1*(2 + 4)" expected: @"2*(2 + 4)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 7.2" before: @"1*(2 + 4) + (2 + 4)*1" expected: @"2*(2 + 4)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 8.1" before: @"1*(c^2) + 1*(c^2)" expected: @"2*(c^2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 8.2" before: @"1*(c^2) + (c^2)*1" expected: @"2*(c^2)" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Addition test 9.1" before: @"1*(c/x) + 1*(c/x)" expected: @"2*(c/x)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Addition test 9.2" before: @"1*(c/x) + (c/x)*1" expected: @"2*(c/x)" sourceTerm: @".1" targetTerm: @".0"];
	
	
}

- (void) SummationTest1 {
	
	// TODO: finish me
//	NSLog(@"+++++ Summation Test Suite 1 - summation ++++");
	
//	Variable *v = [[Variable alloc] initWithTermValue:@"i"];
//	Summation *temp = [[Summation alloc] initWithIndex:v lower:[[Integer alloc] initWithInt:1] upper:[[Integer alloc] initWithInt:10] expression:v];
}	

- (void) PowerTest1 {
	
	NSLog(@"+++++ Power Test Suite 1 - Expand one, zero and minus one ++++");
	
	[self runTest: @"Power test 1.1" before: @"1^1" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.2" before: @"(-1)^1" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.3" before: @"0^1" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.4" before: @"(a+b)^1" expected: @"(a+b)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.5" before: @"(a*b)^1" expected: @"(a*b)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.6" before: @"(2^3)^1" expected: @"2^3" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.7" before: @"x^1" expected: @"x" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.8" before: @"c^1" expected: @"c" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Power test 2.1" before: @"1^1" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 2.2" before: @"(-1)^1" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 2.3" before: @"0^1" expected: @"0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 2.4" before: @"(a+b)^1" expected: @"(a+b)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 2.5" before: @"(a*b)^1" expected: @"(a*b)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 2.6" before: @"(2^3)^1" expected: @"2^3" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 2.7" before: @"x^1" expected: @"x" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 2.8" before: @"c^1" expected: @"c" sourceTerm: @".0" targetTerm: @".1"];

	[self runTest: @"Power test 3.1" before: @"1^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 3.2" before: @"(-1)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 3.3" before: @"0^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 3.4" before: @"(a+b)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 3.5" before: @"(a*b)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 3.6" before: @"(2^3)^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 3.7" before: @"x^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 3.8" before: @"c^0" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];

	[self runTest: @"Power test 4.1" before: @"1^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 4.2" before: @"(-1)^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 4.3" before: @"0^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 4.4" before: @"(a+b)^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 4.5" before: @"(a*b)^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 4.6" before: @"(2^3)^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 4.7" before: @"x^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 4.8" before: @"c^0" expected: @"1" sourceTerm: @".0" targetTerm: @".1"];

	[self runTest: @"Power test 5.1" before: @"1^(-1)" expected: @"1/(1^1)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 5.2" before: @"(-1)^(-1)" expected: @"1/((-1)^1)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 5.3" before: @"0^(-1)" expected: nil sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 5.4" before: @"(a+b)^(-1)" expected: @"1/((a+b)^1)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 5.5" before: @"(a*b)^(-1)" expected: @"a^(-1)*b^(-1)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 5.6" before: @"(2^3)^(-1)" expected: @"2^(3*(-1))" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 5.7" before: @"x^(-1)" expected: @"1/(x^1)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 5.8" before: @"c^(-1)" expected: @"1/(c^1)" sourceTerm: @".1" targetTerm: @".0"];
	
}	

- (void) PowerTest2 {
	
	NSLog(@"+++++ Power Test Suite 2 - Expand powers two to ten ++++");
	
	[self runTest: @"Power test 1.1" before: @"1^2" expected: @"1*1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 1.2" before: @"1^3" expected: @"1*1*1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 1.3" before: @"1^10" expected: @"1*1*1*1*1*1*1*1*1*1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 1.4" before: @"a^2" expected: @"a*a" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 1.5" before: @"a^3" expected: @"a*a*a" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 1.6" before: @"a^10" expected: @"a*a*a*a*a*a*a*a*a*a" sourceTerm: @".0" targetTerm: @".1"];

	[self runTest: @"Power test 2.1" before: @"1^2" expected: @"1*1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 2.2" before: @"1^3" expected: @"1*1*1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 2.3" before: @"1^10" expected: @"1*1*1*1*1*1*1*1*1*1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 2.4" before: @"a^2" expected: @"a*a" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 2.5" before: @"a^3" expected: @"a*a*a" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 2.6" before: @"a^10" expected: @"a*a*a*a*a*a*a*a*a*a" sourceTerm: @".1" targetTerm: @".0`"];

	[self runTest: @"Power test 3.1" before: @"1^(-2)" expected: @"1/(1^2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 3.2" before: @"1^(-3)" expected: @"1/(1^3)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 3.3" before: @"1^(-10)" expected: @"1/(1^10)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 3.4" before: @"a^(-2)" expected: @"1/(a^2)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 3.5" before: @"a^(-3)" expected: @"1/(a^3)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Power test 3.6" before: @"a^(-10)" expected: @"1/(a^10)" sourceTerm: @".0" targetTerm: @".1"];
	
}

- (void) PowerTest3 {
	
	NSLog(@"+++++ Power Test Suite 3 - Raise a power to a power ++++");
	
	[self runTest: @"Power test 1.1" before: @"(a^2)^3" expected: @"a^(2*3)" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 1.2" before: @"(a^(-1))^3" expected: @"a^((-1)*3)" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 1.3" before: @"(a^0)^3" expected: @"a^(0*3)" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 1.4" before: @"((a+1)^2)^3" expected: @"(a+1)^(2*3)" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 1.5" before: @"((a*1)^2)^3" expected: @"(a*1)^(2*3)" sourceTerm: @".1" targetTerm: @".0.1"];

}	

- (void) PowerTest4 {
	
	NSLog(@"+++++ TODO - Power Test Suite 4 - \"distribute\" a power across a multiplication ++++");
	[self runTest: @"Power test 1.1" before: @"(a*a)^11" expected: @"(a^11)*(a^11)" sourceTerm: @".1" targetTerm: @".0"];
}
	
- (void) PowerTest5 {
	
	NSLog(@"+++++ TODO - Power Test Suite 5 - \"distribute\" a power across a fraction ++++");
	// TODO: finish me
}

- (void) PowerTest6 {
	
	NSLog(@"+++++ Power Test Suite 6 - roots of radicals ++++");

	[self runTest: @"Power test 0.1" before: @"4^(1/1)" expected: @"4" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 0.1.1" before: @"4^(1/1)" expected: @"4" sourceTerm: @".1" targetTerm: @".0.1"];

	[self runTest: @"Power test 0.2" before: @"4^(0/1)" expected:nil sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 0.2.1" before: @"4^(0/1)" expected:nil sourceTerm: @".1" targetTerm: @".0.1"];

	[self runTest: @"Power test 1.1" before: @"0^(1/2)" expected: @"0" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.2" before: @"1^(1/2)" expected: @"1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.3" before: @"4^(1/2)" expected: @"2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.4" before: @"8^(1/2)" expected: @"2*(2^(1/2))" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.5" before: @"27^(1/3)" expected: @"3" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.6" before: @"54^(1/3)" expected: @"3*(2^(1/3))" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.7" before: @"21^(1/2)" expected: nil sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.8" before: @"9^(1/3)" expected: nil sourceTerm: @".1" targetTerm: @".0"];

	// negative number
	[self runTest: @"Power test 2.1" before: @"(-4)^(1/2)" expected: nil sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 2.2" before: @"(-4)^(1/3)" expected: nil sourceTerm: @".1" targetTerm: @".0"];
	
	// roots of inverse powers
	[self runTest: @"Power test 3.1" before: @"(x^2)^(1/2)" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 3.2" before: @"(x^3)^(1/3)" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 3.3" before: @"(x^(a*b))^(1/(a*b))" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 3.4" before: @"(x^(a+b))^(1/(a+b))" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 3.5" before: @"(x^y)^(1/y)" expected:@"x" sourceTerm: @".1" targetTerm: @".0.1"];

	// roots of multiplications
	[self runTest: @"Power test 4.1" before: @"(a*b)^(1/2)" expected:@"a^(1/2)*b^(1/2)" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 4.2" before: @"((a+b)*b^2*(1/3))^(1/2)" expected:@"(a+b)^(1/2)*(b^2)^(1/2)*(1/3)^(1/2)" sourceTerm: @".1" targetTerm: @".0.1"];

	// negative roots
	[self runTest: @"Power test 5.1" before: @"a^(1/(-1))" expected:nil sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 5.5" before: @"a^(1/(-2))" expected:nil sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 5.5" before: @"a^(1/(-20))" expected:nil sourceTerm: @".1" targetTerm: @".0.1"];
	
	// roots of powers
	[self runTest: @"Power test 6.1" before: @"(x^2)^(1/3)" expected:@"x^(2/3)" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 6.2" before: @"(x^(1/2))^(1/3)" expected:@"x^((1/2)/3)" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 6.3" before: @"(x^a)^(1/b)" expected:@"x^(a/b)" sourceTerm: @".1" targetTerm: @".0.1"];
	[self runTest: @"Power test 6.4" before: @"(x^(1+2))^(1/(a*b))" expected:@"x^((1+2)/(a*b))" sourceTerm: @".1" targetTerm: @".0.1"];

}

- (void) PowerTest7 {
	
	NSLog(@"+++++ Power Test Suite 7 - opposite exponentials ++++");
	
	[self runTest: @"Power test 1.1" before: @"-(2^2)*2^2" expected: @"-(2^(2+2))" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 1.2" before: @"2^2*(-(2^2))" expected: @"-(2^(2+2))" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Power test 2.1" before: @"-(2^2)" expected: @"-2*2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 2.2" before: @"-(2^2)" expected: @"-2*2" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Power test 3.1" before: @"-((-2)^2)" expected: @"2*(-2)" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 3.2" before: @"-((-2)^2)" expected: @"2*(-2)" sourceTerm: @".0" targetTerm: @".1"];

	[self runTest: @"Power test 4.1" before: @"-(2^1)" expected: @"-2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 4.2" before: @"-(2^1)" expected: @"-2" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Power test 5.1" before: @"-((-2)^1)" expected: @"2" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 5.2" before: @"-((-2)^1)" expected: @"2" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Power test 6.1" before: @"-((-2)^0)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 6.2" before: @"-((-2)^0)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];

	[self runTest: @"Power test 7.1" before: @"-(2^0)" expected: @"-1" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 7.2" before: @"-(2^0)" expected: @"-1" sourceTerm: @".0" targetTerm: @".1"];
	
	[self runTest: @"Power test 8.1" before: @"-(2^(-1))" expected: @"1/(-(2^1))" sourceTerm: @".1" targetTerm: @".0"];
	[self runTest: @"Power test 8.2" before: @"-(2^(-1))" expected: @"1/(-(2^1))" sourceTerm: @".0" targetTerm: @".1"];

	[self runTest: @"Power test 9.1" before: @"-(8^(1/3))" expected: @"-2" sourceTerm: @".1.1" targetTerm: @".0"];

	[self runTest: @"Power test 10.1" before: @"-((2*2)^(1/2))" expected: @"-(2^(1/2))*(2^(1/2))" sourceTerm: @".1.1" targetTerm: @".0"];
	
	[self runTest: @"Power test 11.1" before: @"-((2/4)^(1/2))" expected: @"-(2^(1/2))/(4^(1/2))" sourceTerm: @".1.1" targetTerm: @".0"];

	[self runTest: @"Power test 12.1" before: @"-((x^2)^(1/2))" expected: @"-x" sourceTerm: @".1.1" targetTerm: @".0"];

	[self runTest: @"Power test 13.1" before: @"-(2^(1/1))" expected: @"-2" sourceTerm: @".1.1" targetTerm: @".0"];
	[self runTest: @"Power test 13.2" before: @"-(4^(1/2))" expected: @"-2" sourceTerm: @".1.1" targetTerm: @".0"];

	[self runTest: @"Power test 14.1" before: @"-(12^(1/2))" expected: @"(-2)*3^(1/2)" sourceTerm: @".1.1" targetTerm: @".0"];
	
	[self runTest: @"Power test 15.1" before: @"-((x^4)^(1/2))" expected: @"-(x^(4/2))" sourceTerm: @".1.1" targetTerm: @".0"];
}

- (void) PowerTest8 {
	
	NSLog(@"+++++ TODO - Power Test Suite 8 - factor radicals ++++");
	
}

- (void) EquationTest1 {
	
	NSLog(@"+++++ Equation Test Suite 1 - move LHS/RHS to the other side of the equation ++++");
	
	[self runTest: @"Equation test 1.1" before: @"0 = 0" expected:@"0 = 0" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Equation test 1.2" before: @"0 = 0" expected:@"0 = 0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 2.1" before: @"1 = 0" expected:@"0 = 1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Equation test 2.2" before: @"1 = 0" expected:@"0 = 1" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 3.1" before: @"-1 = 0" expected:@"0 = -1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Equation test 3.2" before: @"-1 = 0" expected:@"0 = -1" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 3.1.1" before: @"a + b = 0" expected:@"0 = a + b" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Equation test 3.1.2" before: @"a + b = 0" expected:@"0 = a + b" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 4.1" before: @"-1 = 1" expected: @"0 = 1 - (-1)" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Equation test 4.2" before: @"-1 = 1" expected: @"-1 - 1 = 0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 5.1" before: @"1 = 1" expected: @"0 = 1 - 1" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Equation test 5.2" before: @"1 = 1" expected: @"1 - 1 = 0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 6.1" before: @"a + b = c" expected: @"0 = c - a - b" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Equation test 6.2" before: @"a + b = c" expected: @"a + b - c = 0" sourceTerm: @".1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 7.1" before: @"a - b = c" expected: @"0 = c - a + b" sourceTerm: @".0" targetTerm: @".1"];
	[self runTest: @"Equation test 7.2" before: @"a - b = c" expected: @"a - b - c = 0" sourceTerm: @".1" targetTerm: @".0"];
	
}

- (void) EquationTest2 {
	
	NSLog(@"+++++ Equation Test Suite 2 - move an addend from one side of the equation to the other ++++");
	
	[self runTest: @"Equation test 1.1" before: @"0 + 0 = 0" expected:nil sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 1.2" before: @"0 + 0 = 0" expected:nil sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 2.1" before: @"0 = 0 + 0" expected:nil sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Equation test 2.2" before: @"0 = 0 + 0" expected:nil sourceTerm: @".1.1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 3.1" before: @"0 = 1 + 0" expected:@"-1 = 0" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Equation test 3.2" before: @"0 = 0 + 1" expected:@"-1 = 0" sourceTerm: @".1.1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 4.1" before: @"1 + 1 = 0" expected:@"1 = -1" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 4.2" before: @"1 + 1 = 0" expected:@"1 = -1" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 5.1" before: @"a + b = 0" expected:@"b = -a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 5.2" before: @"a + b = 0" expected:@"a = -b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 6.1" before: @"a - b = 0" expected:@"-b = -a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 6.2" before: @"a - b = 0" expected:@"a = b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 7.1" before: @"-a - b = 0" expected:@"-b = a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 7.2" before: @"-a - b = 0" expected:@"-a = b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 8.1" before: @"-a - (-b) = 0" expected:@"b = a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 8.2" before: @"-a - (-b) = 0" expected:@"-a = -b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 9.1" before: @"-a + (-b) = 0" expected:@"-b = a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 9.2" before: @"-a + (-b) = 0" expected:@"-a = b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 10.1" before: @"c + a - b = 0" expected:@"c - b = -a" sourceTerm: @".0.1" targetTerm: @".1"];
	[self runTest: @"Equation test 10.2" before: @"c + a - b = 0" expected:@"c + a = b" sourceTerm: @".0.2" targetTerm: @".1"];
	
	[self runTest: @"Equation test 11.1" before: @"c + (-a) - b = 0" expected:@"c - b = a" sourceTerm: @".0.1" targetTerm: @".1"];
	[self runTest: @"Equation test 11.2" before: @"c + (-a) - b = 0" expected:@"c + (-a) = b" sourceTerm: @".0.2" targetTerm: @".1"];
	
	[self runTest: @"Equation test 12.1" before: @"c + (-a) - (-b) = 0" expected:@"c - (-b) = a" sourceTerm: @".0.1" targetTerm: @".1"];
	[self runTest: @"Equation test 12.2" before: @"c + (-a) - (-b) = 0" expected:@"c + (-a) = -b" sourceTerm: @".0.2" targetTerm: @".1"];
	
	[self runTest: @"Equation test 13.1" before: @"c + (-a) + (-b) = 0" expected:@"c + (-b) = a" sourceTerm: @".0.1" targetTerm: @".1"];
	[self runTest: @"Equation test 13.2" before: @"c + (-a) + (-b) = 0" expected:@"c + (-a) = b" sourceTerm: @".0.2" targetTerm: @".1"];
	
	[self runTest: @"Equation test 14.1" before: @"a + b = c" expected:@"b = c - a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 14.2" before: @"a + b = c" expected:@"a = c - b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 14.1.1" before: @"c = a + b" expected:@"c - a = b" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Equation test 14.1.2" before: @"c = a + b" expected:@"c - b = a" sourceTerm: @".1.1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 15.1" before: @"a - b = c" expected:@"-b = c - a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 15.2" before: @"a - b = c" expected:@"a = c + b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 16.1" before: @"-a + b = c" expected:@"b = c - (-a)" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 16.2" before: @"a + (-b) = c" expected:@"a = c - (-b)" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 17.1" before: @"a + b + c = d" expected:@"b + c = d - a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 17.2" before: @"a + b + c = d" expected:@"a + c = d - b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 18.1" before: @"a - b - c = d" expected:@"-b - c = d - a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 18.2" before: @"a - b - c = d" expected:@"a - c = d + b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 19.1" before: @"a + b = c + d" expected:@"b = c + d - a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 19.2" before: @"a + b = c + d" expected:@"a = c + d - b" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 20.1" before: @"a - b = c - d" expected:@"-b = c - d - a" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 20.2" before: @"a - b = c - d" expected:@"a = c - d + b" sourceTerm: @".0.1" targetTerm: @".1"];
	
}

- (void) EquationTest3 {
	
	NSLog(@"+++++ Equation Test Suite 3 - divide both sides of the equation by a multiplicand in the source side ++++");
	
	[self runTest: @"Equation test 1.1" before: @"0*0 = 0" expected:nil sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 1.2" before: @"0*0 = 0" expected:nil sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 2.1" before: @"0*1 = 1" expected:nil sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 2.2" before: @"1*0 = 1" expected:nil sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 3.1" before: @"1*2 = 1" expected:@"2 = 1/1" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 3.2" before: @"1*2 = 0" expected:@"1 = 0/2" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 4.1" before: @"a = b*c" expected:@"a/b = c" sourceTerm: @".1.0" targetTerm: @".0"];
	[self runTest: @"Equation test 4.2" before: @"a = b*c" expected:@"a/c = b" sourceTerm: @".1.1" targetTerm: @".0"];
	
	[self runTest: @"Equation test 5.1" before: @"a*b = c/d" expected:@"b = c/(d*a)" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 5.2" before: @"a*b = c/(d*e)" expected:@"a = c/(d*e*b)" sourceTerm: @".0.1" targetTerm: @".1"];
	
	[self runTest: @"Equation test 6.1" before: @"1*2 = c*d"   expected:@"2 = (c*d)/1" sourceTerm: @".0.0" targetTerm: @".1"];
	[self runTest: @"Equation test 6.2" before: @"1*2 = c*d*e" expected:@"1 = (c*d*e)/2" sourceTerm: @".0.1" targetTerm: @".1"];
	
}

- (void) EquationTest4 {
	
	NSLog(@"+++++ Equation Test Suite 4 - multiply both sides of the equation by a fraction's denominator ++++");
	
	[self runTest: @"Equation test 1.1" before: @"1/2 = x" expected:@"1 = 2*x" sourceTerm:@".0.1"  targetTerm: @".1"];
	[self runTest: @"Equation test 1.2" before: @"x = a/b" expected:@"x*b = a" sourceTerm:@".1.1"  targetTerm: @".0"];

	[self runTest: @"Equation test 2.1" before: @"1/2 = x*y" expected:@"1 = x*y*2" sourceTerm:@".0.1"  targetTerm: @".1"];
	[self runTest: @"Equation test 2.2" before: @"x*y = a/b" expected:@"x*y*b = a" sourceTerm:@".1.1"  targetTerm: @".0"];

	[self runTest: @"Equation test 3.1" before: @"(1/2)*z = x*y" expected:@"z = x*y*2" sourceTerm:@".0.0.1"  targetTerm: @".1"];
	[self runTest: @"Equation test 3.2" before: @"x*y = (a/b)*z" expected:@"x*y*b = a*z" sourceTerm:@".1.0.1"  targetTerm: @".0"];

	[self runTest: @"Equation test 4.1" before: @"(1/2)*z = a/b" expected:@"z = (a/b)*2" sourceTerm:@".0.0.1"  targetTerm: @".1"];
	[self runTest: @"Equation test 4.2" before: @"x*(a/b) = (a/b)*z" expected:@"x*(a/b)*b = a*z" sourceTerm:@".1.0.1"  targetTerm: @".0"];
	
	[self runTest: @"Equation test 5.1" before: @"1/(2*y) = x*y" expected:@"1/y = x*y*2" sourceTerm:@".0.1.0"  targetTerm: @".1"];
	[self runTest: @"Equation test 5.2" before: @"x*y = a/(x*b)" expected:@"x*y*b = a/x" sourceTerm:@".1.1.1"  targetTerm: @".0"];
	
}

- (void) runSummationTests {
	
	[self SummationTest1];
}

- (void) runMultiplicationTests {
	
	[self MultiplicationTest1];
	[self MultiplicationTest2];
	[self MultiplicationTest3];
	[self MultiplicationTest4];
	[self MultiplicationTest5];
	[self MultiplicationTest6];
	[self MultiplicationTest7];
	[self MultiplicationTest8];
	[self MultiplicationTest9];
}

- (void) runFractionTests {
	
	[self FractionTest1];
	[self FractionTest2];
	[self FractionTest3];
	[self FractionTest4];
	[self FractionTest5];
	[self FractionTest6];
	[self FractionTest7];	
}

- (void) runAdditionTests {
	
	[self AdditionTest1];
	[self AdditionTest2];
	[self AdditionTest3];
	[self AdditionTest4];
	[self AdditionTest4_1];
	[self AdditionTest4_2];
	[self AdditionTest4_3];
	[self AdditionTest4_4];
	[self AdditionTest4_5];
	[self AdditionTest4_6];
	[self AdditionTest5];
	[self AdditionTest6];
	[self AdditionTest7];
	[self AdditionTest8];
	[self AdditionTest9];
	[self AdditionTest10];
	[self AdditionTest11];
	[self AdditionTest12];
	[self AdditionTest13];
}

- (void) runPowerTests {
	
	[self PowerTest1];
	[self PowerTest2];
	[self PowerTest3];
	[self PowerTest4];
	[self PowerTest5];
	[self PowerTest6];
	[self PowerTest7];
	[self PowerTest8];
}

- (void) runEquationTests {
	
	[self EquationTest1];
	[self EquationTest2];
	[self EquationTest3];
	[self EquationTest4];
}

- (void) runAllTests{
	
	[self runAdditionTests];
	[self runSummationTests];
	[self runFractionTests];
	[self runMultiplicationTests];
	[self runPowerTests];
	[self runEquationTests];
	
}

- (void) dealloc {

	[parser release];
	
	[one release];
	[two release];
	[three release];
	[zero release];
	[minusOne release];
	[minusTwo release];
	[minusThree release];
	
	[a	release];
	[b	release];
	[c	release];
	[minusa	release];
	[minusb	release];
	[minusc	release];
	
	[x	release];
	[y	release];
	[z	release];
	[minusx	release];
	[minusy	release];
	[minusz	release];
	
	[twox release];
	[xyz release];
	[zyx release];
	[xy release];
	[xz release];
	[zx release];
	[zy release];
	[yz release];
	[yx release];
	
	[super dealloc];
}

@end
