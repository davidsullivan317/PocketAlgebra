//
//  TermInputController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 5/13/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermInputController.h"
#import "HTMLTextViewController.h"
#import "TermEditorViewController.h"
#import "TermParser.h"
#import "Term.h"

#define SPACE @"Space"
#define EXPONENT @"Exp"
#define CLEAR @"Back"
#define CLEAR_ENTRY @"Clear"

#define BACK_BUTTON_TEXT @"Enter Expression"

@implementation TermInputController

//@synthesize termInputDelegate, inputTextLabel, qwerty1, qwerty2, qwerty3, number1, number2, number3, number4, number5, number6;
@synthesize termInputDelegate, inputTextLabel;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

	}
	
	return self;
	
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    // add the help button on right of nav bar
	UIButton* helpTextButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[helpTextButton addTarget:self action:@selector(showHelpText:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *helpTextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:helpTextButton];
	self.navigationItem.rightBarButtonItem = helpTextBarButtonItem;
	[helpTextBarButtonItem release];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	}
	return NO;
}

- (IBAction) buttonPressed: (id) sender {
	
	UIButton *button = (UIButton *) sender;

	// get the character string
	NSString *s = [button currentTitle];
	
	// convert button titles as needed
	if ([s isEqualToString:SPACE]) {
		
		[inputTextLabel setText:[inputTextLabel.text stringByAppendingString:@" "]];
	}
	else if ([s isEqualToString:EXPONENT]) {
		
		[inputTextLabel setText:[inputTextLabel.text stringByAppendingString:@"^"]];
	}
	else if ([s isEqualToString:CLEAR_ENTRY]) {
		
		[inputTextLabel setText:@""];
	}
	else {
		[inputTextLabel setText:[inputTextLabel.text stringByAppendingString:s]];
	}
	
	// force a redraw
	[inputTextLabel setNeedsDisplay];
	
}

- (void) showExpressionEditorWithTerm: (Term *) t {
    
    // customize the back button text
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TEXT style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
    
    // push the expression editor
    TermEditorViewController *termEditViewController = [[TermEditorViewController alloc] initWithNibName:@"TermEditorViewController" bundle:nil];
    [termEditViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [termEditViewController setWantsFullScreenLayout:NO];
    [self.navigationController pushViewController:termEditViewController animated:YES];
    [termEditViewController setTermToEdit:t];
    [termEditViewController release];
}

- (IBAction) doneButtonPressed {
	
	TermParser *parser = [[[TermParser alloc] init] autorelease];
	Term * t = [parser parseTerm:inputTextLabel.text];
	
	if ([parser parseError]) {

		// show error message
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Invalid expression!" message:@"Sorry - the expression you entered is not valid. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alert show];
		
	}
	else if ([t complexity] > MAX_EXPRESSION_COMPLEXITY) {
		
		// show error message
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Expression is too complex!" message:@"Sorry - the expression you entered is too complex. Please reduce the number of subexpressions." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alert show];
		
	}
	else {
		
        if ([termInputDelegate pushInputController]) {

            // called from Choose Expression: show the expression editor
            [self showExpressionEditorWithTerm:t];
        }
        else{
            
            // called from Expression List Editor: return the new term
            [termInputDelegate didInputTerm:t];
        }
	}
	
}

- (IBAction) clearButtonPressed {
	
	if (inputTextLabel.text.length > 0) {

		[inputTextLabel setText:[inputTextLabel.text substringToIndex:inputTextLabel.text.length-1]];
		
		// force a redraw
		[inputTextLabel setNeedsDisplay];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void) showHelpText: (id) sender {
	
	// push the help text selector controller
	HTMLTextViewController *aboutText = [[HTMLTextViewController alloc] initWithNibName:@"HTMLTextViewController" bundle:nil];
	[aboutText setFileName:@"ExpressionInputScreenHelpText"];
	[aboutText setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:aboutText animated:YES];
	[aboutText release];
	
}

- (void)dealloc {
    [super dealloc];
}


@end
