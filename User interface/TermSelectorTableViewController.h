//
//  TermSelectorTableViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 9/14/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Term;

// protocol for calling controller to implement
@protocol TermSelectorDelegate

- (void) didSelectTerm: (Term *) t;

@optional

- (void) didSelectMultipleTerms: (NSArray *) terms;

@end

@interface TermSelectorTableViewController : UITableViewController {

	// array of terms
	NSArray *termList;
	
	id <TermSelectorDelegate> delegate;
	
	BOOL multipleTerms;
}

@property (nonatomic, assign) id <TermSelectorDelegate> delegate;
@property (nonatomic, retain) NSArray *termList;
@property (nonatomic) BOOL multipleTerms;

@end
