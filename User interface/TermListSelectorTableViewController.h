//
//  TermSelectorTableViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 9/13/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermSelectorTableViewController.h"
#import "MyExpressionListsTableViewController.h"

@class Term;

// protocol for calling controller to implement
@protocol TermListSelectorDelegate

- (void) didSelectTerm: (Term *) t;

@optional

- (void) didSelectMultipleTerms: (NSArray *) terms;

@end


@interface TermListSelectorTableViewController : UITableViewController <TermSelectorDelegate>{

	// use an array for each list of terms
	NSMutableArray *termListNames;
	NSMutableArray *termListArray;

	BOOL multipleTerms;
	
	id <TermListSelectorDelegate> delegate;
}

@property (nonatomic, assign) id <TermListSelectorDelegate> delegate;
@property (nonatomic) BOOL multipleTerms;

@end
