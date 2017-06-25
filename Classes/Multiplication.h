//
//  Multiplication.h
//  TouchAlgebra
//
//  Created by David Sullivan on 7/11/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListOperator.h"


@interface Multiplication : ListOperator {

	
}

// copy methods

- (Term *) copyRemovingTerm:  (Term *) t;
- (Term *) copyRemovingTerms: (Term *) t1 and: (Term *) t2;
- (Term *) copyReplacingTerm: (Term *) t1 withTerm: (Term *) t2;

- (id) init:(Term *) term, ...;

@end
