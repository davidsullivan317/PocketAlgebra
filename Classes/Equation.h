//
//  Equation.h
//  TouchAlgebra
//
//  Created by David Sullivan on 1/17/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "Term.h"

@interface Equation : Term {

	Term	*LHS;
	Term	*RHS;
	
	CGFloat renderingBase; 
}

- (id) initWithLHS: (Term *) lhs andRHS: (Term *) rhs;

- (Term *)  LHS;
- (void)	setLHS:(Term *) newLHS;
- (Term *)  RHS;
- (void)	setRHS:(Term *) newRHS;

@end
