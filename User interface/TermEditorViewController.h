//
//  TermEditorViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 4/27/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermEditorScrollView.h"
#import "TermInputController.h"

@class Term;
@class TermEditorScrollView;

@protocol TermEditorDelegate

- (void) didFinishEditingTerm: (Term *) t;

@end


@interface TermEditorViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate, TermEditorScrollViewDelegate, TermInputDelegate> {

	id <TermEditorDelegate> termEditorDelegate;
	
	TermEditorScrollView *scrollView;
	
	NSInteger inputAction;
	
@private 
	// keep a copy of the current term so we can send to the delegate when we dismiss
	Term *lastTermUpdate;
}

- (void) setTermToEdit: (Term *) t;

@property (nonatomic, retain) Term *lastTermUpdate; 
@property (nonatomic, assign) id		<TermEditorDelegate> termEditorDelegate;
@property (nonatomic, retain) IBOutlet	TermEditorScrollView *scrollView;
@property (nonatomic, retain) IBOutlet  UISegmentedControl   *buttonBar; 
@property (nonatomic) BOOL showSaveButton;

@end
