//
//  Fraction.h
//  TouchAlgebra
//
//  Created by David Sullivan on 8/14/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Operator.h"

@class Term;

@interface Fraction : Operator {

	Term *numerator;
	Term *denominator;
}

- (Term *) numerator;
- (void)   setNumerator: (Term *) num;
- (Term *) denominator;
- (void)   setDenominator: (Term *) denom;

- (id) initWithNum: (Term *) num andDenom: (Term *) denom;

@end
