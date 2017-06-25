//
//  TermSelectorTableViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 9/14/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermSelectorTableViewController.h"
#import "MyExpressionListsTableViewController.h"
#import "Term.h"
#import "TermParser.h"
#import "TermEditorViewController.h"

#define BACK_BUTTON_TEXT @"Expression List"

@implementation TermSelectorTableViewController

@synthesize termList, delegate, multipleTerms;

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [termList count] + (multipleTerms ? 1 : 0);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // the first row will be "All" for selecting all terms
	if (multipleTerms) {
		if ([indexPath row] == 0) {
			[[cell textLabel] setText:@"All"];
		}
		else {
			[[cell textLabel] setText:[termList objectAtIndex:[indexPath row] - 1]];
		}
	}
	else {
		[[cell textLabel] setText:[termList objectAtIndex:[indexPath row]]];
	}

    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// parse and return the selected term
	TermParser *p = [[[TermParser alloc] init] autorelease];
	Term *t;
	if (multipleTerms) {
		if ([indexPath row] == 0) {
			
			// parse all terms in the term list
			NSMutableArray *terms = [[[NSMutableArray alloc] initWithCapacity:[termList count]] autorelease];
			for (NSString *s in termList) {
				[terms addObject:[p parseTerm:s]];
			}
			[delegate didSelectMultipleTerms:terms];
		}
		else {
			t = [p parseTerm:[termList objectAtIndex:[indexPath row] - 1]];
			[delegate didSelectTerm:t];
		}

	}
	else {
        
        // parse the term and show the expression editor
		t = [p parseTerm:[termList objectAtIndex:[indexPath row]]];
        [self showExpressionEditorWithTerm:t];
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
	[termList release];
}


@end

