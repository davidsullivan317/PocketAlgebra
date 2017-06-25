//
//  TermListSaveDialogController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 10/4/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermListSaveDialogController.h"


@implementation TermListSaveDialogController

@synthesize listSaveDelegate, expressionListNameTextField, initialExpressionListName;

- (void)viewDidLoad
{
    [self.expressionListNameTextField setDelegate:self];
    [self.expressionListNameTextField setReturnKeyType:UIReturnKeyDone];
    [self.expressionListNameTextField addTarget:self
										 action:@selector(textFieldFinished:)
							   forControlEvents:UIControlEventEditingDidEndOnExit];
	self.expressionListNameTextField.text = self.initialExpressionListName;
    [super viewDidLoad];
}

- (IBAction)textFieldFinished:(id)sender
{
    // make sure the user entered something
    if ([expressionListNameTextField.text length] == 0) {
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"No list name!" message:@"Please enter a name for your expression list" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alert show];
        
    }
    else {
        
        [listSaveDelegate didEnterSaveExpressionListName:expressionListNameTextField.text];
    }
}

// after showing the alert make the text field the first responder again
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [expressionListNameTextField becomeFirstResponder];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	// we only run in landscape orientation
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	}
	return NO;
}

- (void)viewWillAppear:(BOOL)animated {
	
	// place focus in name field and show the keyboard
	[expressionListNameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[initialExpressionListName release];
}


@end
