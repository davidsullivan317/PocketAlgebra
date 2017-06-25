//
//  MyExpressionListsTableViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 10/7/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyExpressionSelectorTableViewController.h"
#import "TermSelectorTableViewController.h"

@interface MyExpressionListsTableViewController : UITableViewController <MyExpressionSelectorDelegate> {

	BOOL editing;
	
	BOOL multipleTerms;

	NSMutableArray *expressionListsArray;
	
	NSInteger selectedExpressionList;
	
	id <TermSelectorDelegate> expressionListsDelegate;
}

@property (nonatomic, assign) id <TermSelectorDelegate> expressionListsDelegate;
@property (nonatomic, retain) NSMutableArray *expressionListsArray;
@property (nonatomic) BOOL multipleTerms;

@end
