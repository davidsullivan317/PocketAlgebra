//
//  Addition.h
//  TouchAlgebra
//
//  Created by David Sullivan on 7/8/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListOperator.h"

#define ADDITION_OPERATOR 1
#define SUBTRACTION_OPERATOR 2 

@interface Addition : ListOperator {

	NSMutableArray *operatorList; 
}

- (void) insertTerm:(Term *) newTerm atIndex: (NSUInteger) index Operator: (NSUInteger) oper;
- (void) appendTerm:(Term *) newTerm Operator: (NSUInteger) oper;

- (NSUInteger) getOperatorAtIndex:(NSUInteger) index;
- (void)       setOperator:(NSInteger) operator atIndex:(NSUInteger) index;

- (Term *) copyRemovingTerm: (Term *) term;

- (Term *) copyRemovingTerm: (Term *) removeTerm 
			   andReplacingTerm: (Term *) replaceTerm 
					   withTerm: (Term *) newTerm;

- (Term *) copyRemovingTerm: (Term *) removeTerm 
			   andReplacingTerm: (Term *) replaceTerm 
					   withTerm: (Term *) newTerm
				   withOperator: (NSUInteger) oper;

// init with any number of terms
- (id) init:(Term *) term, ...;
	
@end
