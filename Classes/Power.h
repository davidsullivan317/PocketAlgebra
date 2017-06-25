//
//  Power.h
//  TouchAlgebra
//
//  Created by David Sullivan on 8/29/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Operator.h"

@class Term;

@interface Power: Operator {
	
	Term *base;
	Term *exponent;
	
	CGFloat renderingBase;
	
	@private
	
	CGRect lMargin;
	CGRect rMargin;
}

- (Term *)  base;
- (void)	setBase:(Term *) newBase;
- (Term *)  exponent;
- (void)	setExponent:(Term *) newExp;

- (id) initWithBase: (Term *) b andExponent: (Term *) e;

- (Term *) copyDecrementingExponent;

// powers of the form 1/x
- (BOOL) isRadical;

// renders with parenthesis
- (BOOL) hasParenthesis;


@end
