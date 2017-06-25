//
//  MyExpressionSelectorTableViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 10/7/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Term;

// protocol for calling controller to implement
@protocol MyExpressionSelectorDelegate

- (void) didSelectExpression: (Term *) e;

- (void) didDeleteExpressionAtIndex: (NSInteger) index;

- (void) didMoveExpressionPostions;

@optional

- (void) didSelectMultipleExpressions: (NSArray *) expressions;

@end



@interface MyExpressionSelectorTableViewController : UITableViewController {

	// array of expression
	NSMutableArray *expressionList;
	
	id <MyExpressionSelectorDelegate> myExpressionDelegate;
	
	BOOL multipleExpressions;
}

@property (nonatomic, assign) id <MyExpressionSelectorDelegate> myExpressionDelegate;
@property (nonatomic, retain) NSMutableArray *expressionList;
@property (nonatomic) BOOL multipleExpressions;

@end
