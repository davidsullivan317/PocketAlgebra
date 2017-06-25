//
//  Summation.h
//  TouchAlgebra
//
//  Created by David Sullivan on 2/27/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Function.h"
#import "Integer.h"
#import "Variable.h"


@interface Summation : Function {

	Variable *indexVariable;
	Term     *lowerBounds;
	Term     *upperBounds;
	Term     *expression;
}


- (id) initWithIndex: (Variable *) i lower: (Term *) l upper: (Term *) u expression: (Term *) e;

- (Term *)  expression;
- (void)	setExpression:(Term *) newExpression;
- (Term *)  lowerBounds;
- (void)	setLowerBounds:(Term *) newLowerBounds;
- (Term *)  upperBounds;
- (void)	setUpperBounds:(Term *) newUpperBounds;

@property (readwrite, copy) Variable *indexVariable;

@end
