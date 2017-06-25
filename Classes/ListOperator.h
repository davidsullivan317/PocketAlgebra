//
//  ListOperator.h
//  TouchAlgebra
//
//  Created by David Sullivan on 7/7/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "Operator.h"


@interface ListOperator : Operator {

	NSMutableArray *termList;
	
	CGFloat renderingBase;
	
}

@property (nonatomic, retain) NSMutableArray *termList;
		   
- (void) appendTerm:(Term *) newTerm;
- (void) insertTerm:(Term *) newTerm atIndex: (NSUInteger) index;

- (void) removeTerm:(Term *) oldTerm;
- (void) removeTermAtIndex: (NSUInteger) index;

- (void) exchangeTerm: (NSUInteger) t1 andTerm: (NSUInteger) t2;

- (NSUInteger) count;

- (Term *) termAtIndex:(NSUInteger) index;
- (NSInteger) indexOfTerm: (Term *) term;

@end
