//
//  TermPickerTableViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 5/4/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Term;

// protocol for calling controller to implement
@protocol TermPickerDelegate

- (void) didPickTerm: (Term *) t;

@end


@interface TermPickerTableViewController : UITableViewController {

	// use an array for each set of terms
	NSMutableArray	*additionListArray;
	NSMutableArray	*multiplicationListArray;
	NSMutableArray	*fractionListArray;
	NSMutableArray	*powerListArray;
	NSMutableArray	*equationListArray;
	
	id <TermPickerDelegate> delegate;
}

@property (nonatomic, assign) id <TermPickerDelegate> delegate;

@end
