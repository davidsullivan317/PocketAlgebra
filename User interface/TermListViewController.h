//
//  TermListViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 4/17/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermEditorViewController.h"
#import "TermListSelectorTableViewController.h"
#import "TermListSaveDialogController.h"
#import "TermInputController.h"
#import "TermListScrollView.h"

@class TermListButtonBar;

@interface TermListViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate, TermEditorDelegate, TermListSelectorDelegate, TermListScrollViewDelegate, TermListSaveDelegate, TermInputDelegate> {
	
	// UI stuff
	TermListScrollView	*termListScrollView;
	
	// the term being edited
	Term *editedTerm;
	
	NSString *expressionListName;
}

// properties
@property (nonatomic, retain) IBOutlet TermListScrollView *termListScrollView;
@property (nonatomic, retain) NSString *expressionListName;

@end
