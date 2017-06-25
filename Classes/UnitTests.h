//
//  UnitTests.h
//  TouchAlgebra
//
//  Created by David Sullivan on 1/15/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

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


@interface UnitTests : NSObject {

	int testCount;
	
	// the term parser
	TermParser *parser;
	
	// integer terms
	Integer *zero;
	Integer *one;
	Integer *two;
	Integer *three;
	Integer *minusOne;
	Integer *minusTwo;
	Integer *minusThree;
	
	// constant terms
	Constant *a;
	Constant *b;
	Constant *c;
	Constant *minusa;
	Constant *minusb;
	Constant *minusc;
	
	// variable terms
	Variable *x;
	Variable *y;
	Variable *z;
	Variable *minusx;
	Variable *minusy;
	Variable *minusz;

	Multiplication *twox;
	Multiplication *xyz;
	Multiplication *zyx;
	Multiplication *xy;
	Multiplication *xz;
	Multiplication *zx;
	Multiplication *zy;
	Multiplication *yz;
	Multiplication *yx;
}

- (void) runAllTests;

- (void) printTestCount;

@end
