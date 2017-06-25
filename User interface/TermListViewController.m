//
//  TermListViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 4/17/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

//
//  TermListViewController.m
//  Views
//
//  Created by David Sullivan on 4/16/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermListViewController.h"
#import "TermListSelectorTableViewController.h"
#import "HTMLTextViewController.h"
#import "ArrayPersistenceHelper.h"
#import "Variable.h"
#import "Addition.h"
#import	"Multiplication.h"
#import "Integer.h"
#import "Equation.h"
#import "Constant.h"
#import "Fraction.h"
#import "Power.h"

// alert tags
#define PICK_BUTTON_INDEX 0
#define NEW_BUTTON_INDEX 1
#define EDIT_BUTTON_INDEX 2
#define SAVE_BUTTON_INDEX 3
#define DELETE_BUTTON_INDEX 4
#define DELETE_ALERT 1
#define SAVE_ALERT 2
#define DELETE_ALL_ALERT 3

#define DEFAULT_EXPRESSION_LIST_KEY @"termListArray"
#define SAVED_EXPRESSION_LIST_KEY @"savedExpressionList"

// constants for saved expression lists
#define MY_EXPRESSION_LIST_INDEX 0
#define MY_EXPRESSION_LIST_ARRAY_NAME @"ExpressionLists"

#define MAX_TERMS 15

#define BACK_BUTTON_TEXT @"Expression List"


@implementation TermListViewController

@synthesize termListScrollView, expressionListName;

- (void) loadTermList {
	
	NSMutableArray *termListArray = [ArrayPersistenceHelper readArrayFromNSUserDefaultsWithKey:DEFAULT_EXPRESSION_LIST_KEY];
	
	if (termListArray != nil) { 
		
		// clear the current array
		for (Term *t in termListScrollView.termList) {
			
			[termListScrollView removeTerm:t];
		}
		
		// add the saved terms
		for (Term *t in termListArray) {
			
			[termListScrollView addTerm:t];
		}
		
		[termListScrollView renderTerms];
	}
}

- (void) setButtonState {

	UISegmentedControl *centerSegmentControl = (UISegmentedControl *)self.navigationItem.titleView;
	if (termListScrollView.termList.count == 0) {
		
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:SAVE_BUTTON_INDEX];
	}
	else {
		[centerSegmentControl setEnabled:YES forSegmentAtIndex:SAVE_BUTTON_INDEX];
	}
	
	// limit the number of terms
	if (termListScrollView.termList.count > MAX_TERMS) {
		[centerSegmentControl setEnabled:NO forSegmentAtIndex: NEW_BUTTON_INDEX];
		[centerSegmentControl setEnabled:NO forSegmentAtIndex: PICK_BUTTON_INDEX];
	}
	else {
		[centerSegmentControl setEnabled:YES forSegmentAtIndex: NEW_BUTTON_INDEX];
		[centerSegmentControl setEnabled:YES forSegmentAtIndex: PICK_BUTTON_INDEX];

	}
	
	// enable/disable the edit button
	if (termListScrollView.selectedTerm) {
		[centerSegmentControl setEnabled:YES forSegmentAtIndex:EDIT_BUTTON_INDEX];
	}
	else {
		[centerSegmentControl setEnabled:NO forSegmentAtIndex:EDIT_BUTTON_INDEX];
	}
	
	// enable/disable the delete button
	if (termListScrollView.termList.count > 0) {
		[centerSegmentControl setEnabled:YES forSegmentAtIndex: DELETE_BUTTON_INDEX];
	}
	else {
		[centerSegmentControl setEnabled:NO forSegmentAtIndex: DELETE_BUTTON_INDEX];
	}
}

- (void) setBackButton {
	
	
	// customize the back button text
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TEXT style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
}

- (void) showHelpText: (id) sender {
	
	[self setBackButton];
	
	// push the help text selector controller
	HTMLTextViewController *aboutText = [[HTMLTextViewController alloc] initWithNibName:@"HTMLTextViewController" bundle:nil];
	[aboutText setFileName:@"ExpressionListEditorHelpText"];
	[aboutText setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:aboutText animated:YES];
	[aboutText release];
	
}

- (void)viewDidLoad {
	
	[super viewDidLoad];

	// set the term list scroll view delegate
	[termListScrollView setTermListScrollViewDelegate:self];
	
	[self loadTermList];

	// add the help button on right of nav bar
	UIButton* helpTextButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[helpTextButton addTarget:self action:@selector(showHelpText:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *helpTextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:helpTextButton];
	self.navigationItem.rightBarButtonItem = helpTextBarButtonItem;
	[helpTextBarButtonItem release];

	// add buttons to middle of nav bar
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 [UIImage imageNamed:@"list-item.png"], 
											 [UIImage imageNamed:@"add-item.png"], 
											 [UIImage imageNamed:@"edit.png"], 
											 [UIImage imageNamed:@"save.png"], 
											 [UIImage imageNamed:@"delete-item.png"],
											 nil]];
    segmentedControl.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.3 alpha:0.0];
	segmentedControl.selectedSegmentIndex = -1;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(0, 0, 200, 40);
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	[segmentedControl setEnabled:NO forSegmentAtIndex:EDIT_BUTTON_INDEX];

	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
	
	[self setButtonState];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	}
	return NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
		
    // Release any cached data, images, etc. that aren't in use.
}

- (void) saveTermList {
	
	// load the list of saved expressions
	NSMutableArray* expressionLists = [ArrayPersistenceHelper readArrayFromNSUserDefaultsWithKey:SAVED_EXPRESSION_LIST_KEY];
	
	if (!expressionLists) {
		expressionLists = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
	}
	
	// see if the expression list already exists
	int replaceIndex = -1;
	for (NSMutableDictionary *list in expressionLists){
		
		// see if the expression list name matches, if so replace
		if ([(NSString *)[list objectForKey:@"Name"] isEqualToString:expressionListName]) {
			
			replaceIndex = [expressionLists indexOfObject:list];
			break;
		}
	}
	
	// create a dictionary or the new expression list
	NSMutableDictionary *d = [[[NSMutableDictionary alloc] initWithCapacity:2] autorelease];
	[d setObject:self.expressionListName forKey:@"Name"];
	[d setObject:self.termListScrollView.termList forKey:@"Expression List"];
	
	// add/replace the new expression list
	if (replaceIndex >= 0) {
		
		[expressionLists replaceObjectAtIndex:replaceIndex withObject:d];
	}
	else {
		[expressionLists addObject:d];
	}

	// save the updated expression list array
	[ArrayPersistenceHelper writeArray:expressionLists ToNSUserDefaultsWithKey:SAVED_EXPRESSION_LIST_KEY];
}

- (void) saveDefaultTermList {
	
	[ArrayPersistenceHelper writeArray:termListScrollView.termList ToNSUserDefaultsWithKey:DEFAULT_EXPRESSION_LIST_KEY];
	
}

- (void) backButtonPressed: (id *) x {
	
    // get the term editor controller
    TermEditorViewController *editor = (TermEditorViewController *) [self.navigationController topViewController];
    
    Term *t = editor.scrollView.activeTerm;
    
	if (t) {
		
		// replace the old term in the term list
		[termListScrollView setSelectedTerm:nil];
		[termListScrollView replaceTerm:editedTerm withTerm:t];
		[self saveDefaultTermList];
	}

    // remove the term editor controller
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) editTermButtonPressed {
	
	if (termListScrollView.selectedTerm) {
		
        // custom back button so we can update the expressin list when pressed
        UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TEXT style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)] autorelease];

		
		 // copy the selected term 
		editedTerm = [termListScrollView.selectedTerm upperMostParentTerm];
		Term *t = [[editedTerm copy] autorelease];
		
		// push the term edit controller
		TermEditorViewController *termEditViewController = [[TermEditorViewController alloc] initWithNibName:@"TermEditorViewController" bundle:nil];
		[termEditViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[termEditViewController setWantsFullScreenLayout:NO];
		[termEditViewController setTermEditorDelegate:self];
		[termEditViewController setShowSaveButton:YES];
        termEditViewController.navigationItem.leftBarButtonItem = backButton;

		[self.navigationController pushViewController:termEditViewController animated:YES];
		[termEditViewController setTermToEdit:t];
		[termEditViewController release];
	}
}

- (IBAction) pickTermButtonPressed {
	
	[self setBackButton];
	
	// create and present the term list selector controller
	TermListSelectorTableViewController *termListSelector = [[TermListSelectorTableViewController alloc] init];
	[termListSelector setDelegate:self];
	[termListSelector setMultipleTerms:YES];
	[termListSelector setTitle:@"Expression Lists"];
	[termListSelector setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:termListSelector animated:YES];
	[termListSelector release];
}

- (IBAction) deleteButtonPressed {
	
	if (termListScrollView.selectedTerm) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete expression?" message:@"Are you sure you want to delete the selected expression?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
		alert.tag = DELETE_ALERT;
		[alert show];
		[alert release];
		
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete all expressions?" message:@"Are you sure you want to delete all expressions in the Expression List Editor?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
		alert.tag = DELETE_ALL_ALERT;
		[alert show];
		[alert release];
	}
}

- (IBAction) newTermButtonPressed {
	
	[self setBackButton];
	
	// create and present the term input controller
	TermInputController *termInputController = [[TermInputController alloc] init];
	[termInputController setTermInputDelegate:self];
	[termInputController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:termInputController animated:YES];
	[termInputController release];
}

- (IBAction) saveListButtonPressed {
	
	[self setBackButton];
	
	// create and initialize the term list save dialog controller
	TermListSaveDialogController *termListSaveDialog = [[[TermListSaveDialogController alloc] initWithNibName:@"TermListSaveDialogController" bundle:[NSBundle mainBundle]] autorelease];
	[termListSaveDialog setListSaveDelegate:self];
	termListSaveDialog.initialExpressionListName = self.expressionListName;
	
	// present the term input controller
	[termListSaveDialog setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:termListSaveDialog animated:YES];
}

- (IBAction)segmentAction:(id)sender {
	
	// get the segmented control index and reset it
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	int buttonIndex = segmentedControl.selectedSegmentIndex;
	segmentedControl.selectedSegmentIndex = -1;
	
	switch (buttonIndex)
	{
		case PICK_BUTTON_INDEX:
		{
			[self pickTermButtonPressed];
			break;
		}
		case NEW_BUTTON_INDEX:
		{
			[self newTermButtonPressed];
			break;
		}
		case EDIT_BUTTON_INDEX:
		{
			[self editTermButtonPressed];
			break;
		}
		case SAVE_BUTTON_INDEX:
		{
			[self saveListButtonPressed];
			break;
		}
		case DELETE_BUTTON_INDEX:
		{
			[self deleteButtonPressed];
			break;
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		case DELETE_ALERT:
			if (buttonIndex == 1) {
				
				Term *parent = [termListScrollView.selectedTerm upperMostParentTerm];
				[termListScrollView removeTerm:parent];
				[self saveDefaultTermList];
				[self setButtonState];
			}
			break;
		case DELETE_ALL_ALERT:
			if (buttonIndex == 1) {
				
                [termListScrollView removeAllTerms];
                [self saveDefaultTermList];
                [self setButtonState];
			}
			break;
	}
}

- (void) didSelectTerm:(Term *) t {
	
	// remove the term picker controller from the stack
	[self.navigationController popViewControllerAnimated:YES];
	
	// add the new term to the term list
	[termListScrollView addTerm:t];
	[self saveDefaultTermList];
	[self setButtonState];
}

- (void) didSelectMultipleTerms:(NSArray *) terms {
	
	// remove the term list selector controller from the stack
	[self.navigationController popViewControllerAnimated:YES];
	
	// add the new terms to the term list
	for (Term *t in terms) {
		[termListScrollView addTerm:t];
	}
	[self saveDefaultTermList];
	[self setButtonState];
}

- (BOOL) pushInputController {
    
    return NO;
}

- (void) didInputTerm: (Term *) t {
	
	// remove the term picker controller from the stack
	[self.navigationController popViewControllerAnimated:YES];
	
	// add the term to the list
	[termListScrollView addTerm:t];
	[self saveDefaultTermList];
	[self setButtonState];
}

- (void) didFinishEditingTerm: (Term *) t {
	
	// remove the term editor controller
	[self.navigationController popViewControllerAnimated:YES];

	if (t) {
		
		// replace the old term in the term list
		[termListScrollView setSelectedTerm:nil];
		[termListScrollView replaceTerm:editedTerm withTerm:t];
		[self saveDefaultTermList];
	}
}

- (void) didChangeSelectedTerm: (Term *) selectedTerm {
	
	[self setButtonState];
}

- (void) didEnterSaveExpressionListName: (NSString *) s {

	// remove the controller from the stack
	[self.navigationController popViewControllerAnimated:YES];
	self.expressionListName = s;
	
	[self saveTermList];
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
	
	return self.termListScrollView.backgroundView;
}

- (void)dealloc {
    [super dealloc];
	[termListScrollView release];
	[expressionListName release];
	
}

@end
