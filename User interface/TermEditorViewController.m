//
//  TermEditorViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 4/27/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermEditorViewController.h"
#import "HTMLTextViewController.h"
#import "Equation.h"
#import "Integer.h"
#include "Constant.h"

// constants for controlling which action involked the term input controller
#define TIMES_ONE_INDEX 0
#define PLUS_INDEX 1
#define MINUS_INDEX 2
#define TIMES_INDEX 3
#define DIVIDE_INDEX 4
#define EXP_INDEX 5

#define BACK_BUTTON_TEXT @"Expression Editor"

@implementation TermEditorViewController

@synthesize termEditorDelegate, scrollView, buttonBar, lastTermUpdate, showSaveButton;

- (void) viewDidLoad {
	
	[super viewDidLoad];
	
	// add the help button on right of nav bar
	UIButton* helpTextButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[helpTextButton addTarget:self action:@selector(showHelpText:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *helpTextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:helpTextButton];
	self.navigationItem.rightBarButtonItem = helpTextBarButtonItem;
	[helpTextBarButtonItem release];
	
	// add, pick, edit buttons in middle of nav bar
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 [NSString stringWithString:@"x1"],
											 [NSString stringWithString:@"+"],
											 [NSString stringWithString:@"-"],
											 [NSString stringWithString:@"*"],
											 [NSString stringWithString:@"/"],
											 [NSString stringWithString:@"Exp"],
											 nil]];
	segmentedControl.selectedSegmentIndex = -1;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(0, 0, 200, 40);
    segmentedControl.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.3 alpha:0.0];

	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	}
	return NO;
}

- (void) setTermToEdit: (Term *) t {
	
	[scrollView setInitialTerm:t];
	[scrollView setDelegate:self];
	
	// inactivate the button bar
	[self selectedTermDidChange:nil];
	
}

- (void) didInputTerm: (Term *) t {
			
	// pop the term input controller
	[self.navigationController popViewControllerAnimated:YES];

	switch (inputAction) {
		case TIMES_ONE_INDEX:
			[scrollView multiplySelectedTermByOne:t];
			break;
		case PLUS_INDEX:
			[scrollView addToEquationTerm:t];
			break;
		case MINUS_INDEX:
			[scrollView subtractFromEquationTerm:t];
			break;
		case TIMES_INDEX:
			[scrollView multiplyEquationBy:t];
			break;
		case DIVIDE_INDEX:
			[scrollView divideEquationBy:t];
			break;
		case EXP_INDEX:
			[scrollView raiseEquationByExp:t];
			break;
		default:
			break;
	}
}

- (void) setBackButton {
	
	
	// customize the back button text
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TEXT style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
}

- (IBAction)segmentAction:(id)sender {
	
	// get the segmented control index and reset it
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;

	if (segmentedControl.selectedSegmentIndex != -1) { // this method is called again when setting the selected segment index to -1

		// save the action
		inputAction = segmentedControl.selectedSegmentIndex;

        [self setBackButton];

		// create and present the term input controller
		TermInputController *termInputController = [[TermInputController alloc] init];
		[termInputController setTermInputDelegate:self];
		[termInputController loadView]; // need to force view to load when presenting modally
		[termInputController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[self.navigationController pushViewController:termInputController animated:YES];
		
		// unselected the segment
		segmentedControl.selectedSegmentIndex = -1;

	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1) {
		
		[termEditorDelegate didFinishEditingTerm:nil];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void) selectedTermDidChange: (Term *) t {
	
	UISegmentedControl *centerSegmentControl = (UISegmentedControl *)self.navigationItem.titleView;
	
	// enable/disable the edit and delete button
	if (!t) {
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:TIMES_ONE_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:PLUS_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:MINUS_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:TIMES_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:DIVIDE_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:EXP_INDEX];
	}
	else if ([t isKindOfClass:[Equation class]]) {
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:TIMES_ONE_INDEX];
		[centerSegmentControl setEnabled:YES forSegmentAtIndex:PLUS_INDEX];
		[centerSegmentControl setEnabled:YES forSegmentAtIndex:MINUS_INDEX];
		[centerSegmentControl setEnabled:YES forSegmentAtIndex:TIMES_INDEX];
		[centerSegmentControl setEnabled:YES forSegmentAtIndex:DIVIDE_INDEX];
		[centerSegmentControl setEnabled:YES forSegmentAtIndex:EXP_INDEX];
	}
	else {
		[centerSegmentControl setEnabled:YES forSegmentAtIndex:TIMES_ONE_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:PLUS_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:MINUS_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:TIMES_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:DIVIDE_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:EXP_INDEX];
	}

	
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	
    return self.scrollView.backgroundView;
}

- (BOOL) pushInputController {
    
    return NO;
}

- (void) newTermAdded: (Term *) t {
	
	// save the lastest term
	self.lastTermUpdate = t;
}

- (void) showHelpText: (id) sender {
	
	[self setBackButton];
	
	// push the help text selector controller
	HTMLTextViewController *aboutText = [[HTMLTextViewController alloc] initWithNibName:@"HTMLTextViewController" bundle:nil];
	[aboutText setFileName:@"ExpressionEditorHelpText"];
	[aboutText setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:aboutText animated:YES];
	[aboutText release];
	
}

- (void)dealloc {
    [super dealloc];
	[scrollView release];
	[buttonBar release];
	[lastTermUpdate release];
}

@end
