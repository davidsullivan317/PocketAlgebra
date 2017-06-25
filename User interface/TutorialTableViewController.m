//
//  TutorialTableViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 8/6/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TutorialTableViewController.h"
#import "TutorialStep.h"
#import "TutorialChapter.h"
#import "TutorialViewController.h"

#define BACK_BUTTON_TEXT @"Tutorial Chapters"
#define FIRST_RUN_KEY @"First Run"

@implementation TutorialTableViewController

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidAppear:(BOOL)animated {
	
	// if this is the first run application start the tutorial and mark the first run
	firstRun = 	![[NSUserDefaults standardUserDefaults] boolForKey:FIRST_RUN_KEY];
	if (firstRun && !firstRunControllerShown) {
		
		[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		[[NSUserDefaults standardUserDefaults] setBool:YES	forKey:FIRST_RUN_KEY];
		firstRunControllerShown = YES;
	}
}


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

		// get the tutorial chapters and save
		chapters = [[TutorialChapter allChapters] retain];
	};
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	}
	return NO;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [chapters count]; 
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TutorialCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set cell text to chapter title
	[[cell textLabel] setText:[(TutorialChapter *) [chapters objectAtIndex:[indexPath indexAtPosition:1]] title]];
    
    return cell;
}

// add section titles
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return @"Tutorial Chapters";
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// customize the back button
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:BACK_BUTTON_TEXT style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	// create and initialize the tutorial controller
	TutorialViewController *tutorial = [[[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil] autorelease];
	
	// intialize the tutorial controller
	[tutorial loadView];
	tutorial.chapters = chapters;
	tutorial.currentChapterIndex = [indexPath indexAtPosition:1];
	tutorial.currentStepIndex = 0;
	tutorial.displayCurrentStep;
	
	// present the tutorial input controller
	[tutorial setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	if (firstRun) {
		[[self navigationController] pushViewController:tutorial animated:NO];
	}
	else {
		[[self navigationController] pushViewController:tutorial animated:YES];

	}

	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
    [super dealloc];
//	[chapters release];
}


@end

