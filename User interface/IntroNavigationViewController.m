//
//  IntroNavigationViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 8/6/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "IntroNavigationViewController.h"
#import "TermListViewController.h"
#import "TermEditorViewController.h"
#import "TutorialViewController.h"
#import "TutorialTableViewController.h"
#import "TutorialStep.h"
#import "TutorialChapter.h"
#import "HTMLTextViewController.h"

#define leftXPosition 60
#define FIRST_RUN_KEY @"First Run"

@implementation IntroNavigationViewController

@synthesize expressionListButton, choseExpressionButton, enterExpressionButton, tutorialButton, helpButton;

- (IBAction) enterExpressionButtonPressed {
	
	// create and present the term input controller
	TermInputController *termInputController = [[TermInputController alloc] init];
	[termInputController setTermInputDelegate:self];
	[termInputController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:termInputController animated:YES];
	[termInputController release];
}

- (IBAction) choseExpressionButtonPressed {
	
	// push the term list selector controller
	TermListSelectorTableViewController *termListSelector = [[TermListSelectorTableViewController alloc] init];
//	[termListSelector setDelegate:self];
	[termListSelector setMultipleTerms:NO];
	[termListSelector setTitle:@"Expression Lists"];
	[termListSelector setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:termListSelector animated:YES];
	[termListSelector release];
}

- (IBAction) expressionListButtonPressed {
	
	// push the term list controller
	TermListViewController *termListViewController = [[TermListViewController alloc] initWithNibName:@"TermListViewController" bundle:nil];
	[termListViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[termListViewController setWantsFullScreenLayout:NO];
	[self.navigationController pushViewController:termListViewController animated:YES];
	[termListViewController release];
	
}

- (IBAction) tutorialButtonPressed {
	
	// create the tutorial controller
	TutorialTableViewController *tutorialTable = [[TutorialTableViewController alloc] initWithNibName:@"TutorialTableViewController" bundle:nil];
	[tutorialTable setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[tutorialTable setWantsFullScreenLayout:NO];
	if (firstRun) {
		[self.navigationController pushViewController:tutorialTable animated:NO];
	}
	else {
		[self.navigationController pushViewController:tutorialTable animated:YES];

	}

	[tutorialTable release];
}

- (IBAction) helpButtonPressed {
	
	// push the help text selector controller
	HTMLTextViewController *aboutText = [[HTMLTextViewController alloc] initWithNibName:@"HTMLTextViewController" bundle:nil];
	[aboutText setFileName:@"IntroScreenHelpText"];
	[aboutText setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:aboutText animated:YES];
	[aboutText release];

}

- (void) setViewXPosition: (UIView *) v position: (int) x {
	
	[v setFrame:CGRectMake(x, 
						   v.frame.origin.y, 
						   v.frame.size.width, 
						   v.frame.size.height)];
	
}

- (void) viewDidLoad {
    
	// set the nav controller color
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.3 alpha:0.0]];
    
#define SPACING 50
	
	// if this is the first run application show the tutorial
	firstRun = 	![[NSUserDefaults standardUserDefaults] boolForKey:FIRST_RUN_KEY];
	if (firstRun) {
		// move buttons to final postion
		int startX = leftXPosition;
		[self setViewXPosition:enterExpressionButton position:startX];
		[self setViewXPosition:choseExpressionButton position:startX += SPACING];
		[self setViewXPosition:expressionListButton  position:startX += SPACING];
		[self setViewXPosition:tutorialButton        position:startX += SPACING];
		[self setViewXPosition:helpButton           position:startX += SPACING];
		
		// show the tutorial
		[self tutorialButtonPressed];
	}
	else {
		// move buttons off the left side of the screen
		[self setViewXPosition:enterExpressionButton position:-1*enterExpressionButton.frame.origin.x];
		[self setViewXPosition:choseExpressionButton position:-1*choseExpressionButton.frame.origin.x];
		[self setViewXPosition:expressionListButton  position:-1*expressionListButton.frame.origin.x];
		[self setViewXPosition:tutorialButton        position:-1*tutorialButton.frame.origin.x];
		[self setViewXPosition:helpButton           position:-1*helpButton.frame.origin.x];
		
		// animate
		[UIView	animateWithDuration:0.5
							  delay:0 
							options:UIViewAnimationOptionBeginFromCurrentState 
						 animations:^{
							 
							 // move to right side of screen
							 [self setViewXPosition:enterExpressionButton position:self.view.frame.size.width - enterExpressionButton.frame.size.width];
							 [self setViewXPosition:choseExpressionButton position:self.view.frame.size.width - choseExpressionButton.frame.size.width];
							 [self setViewXPosition:expressionListButton  position:self.view.frame.size.width - expressionListButton.frame.size.width];
							 [self setViewXPosition:tutorialButton        position:self.view.frame.size.width - tutorialButton.frame.size.width];
							 [self setViewXPosition:helpButton           position:self.view.frame.size.width - helpButton.frame.size.width];
						 }
						 completion:^(BOOL finished){
							 
							 [UIView	animateWithDuration:1
												   delay:0 
												 options:UIViewAnimationOptionBeginFromCurrentState 
											  animations:^{
												  
												  // move to final postion
												  int startX = leftXPosition;
												  [self setViewXPosition:enterExpressionButton position:startX];
												  [self setViewXPosition:choseExpressionButton position:startX += SPACING];
												  [self setViewXPosition:expressionListButton  position:startX += SPACING];
												  [self setViewXPosition:tutorialButton        position:startX += SPACING];
												  [self setViewXPosition:helpButton           position:startX += SPACING];
											  }
											  completion:^(BOOL finished){
												  
											  }
							  ];					
						 }
		 ];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	// we only run in landscape orientation
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	}
	return NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void) didSelectTerm: (Term *) t {
	
	// remove the term list selector controller from the stack
	[self.navigationController popViewControllerAnimated:NO];
	
	// push the term edit controller
	TermEditorViewController *termEditViewController = [[TermEditorViewController alloc] initWithNibName:@"TermEditorViewController" bundle:nil];
	[termEditViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[termEditViewController setWantsFullScreenLayout:NO];
	[self.navigationController pushViewController:termEditViewController animated:YES];
	[termEditViewController setTermToEdit:t];
	[termEditViewController release];
}

- (void) didInputTerm:(Term *)t {
    
    // is never called as the input controller is always pushed
}

- (BOOL) pushInputController {
    
    return YES;
}

- (void)dealloc {
    [super dealloc];
}

@end
