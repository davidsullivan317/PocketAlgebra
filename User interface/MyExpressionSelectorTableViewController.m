//
//  MyExpressionSelectorTableViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 10/7/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "Term.h"
#import "MyExpressionSelectorTableViewController.h"
#import "TermEditorViewController.h"

#define BACK_BUTTON_TEXT @"My Expression List"

@implementation MyExpressionSelectorTableViewController

@synthesize expressionList, myExpressionDelegate, multipleExpressions;

- (void) setRightNavBarItem: (NSString *) title action:(SEL) action {
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:action];
	self.navigationItem.rightBarButtonItem = button;
	[button release];
	
}

- (void) doneButtonPressed: (id) sender {
	
	[self setRightNavBarItem:@"Edit" action:@selector(editButtonPressed:)];
	[self setEditing:NO animated:YES];
}

- (void) editButtonPressed: (id) sender {
	
	[self setRightNavBarItem:@"Done" action:@selector(doneButtonPressed:)];
	[self setEditing:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// add the edit button 
	[self setRightNavBarItem:@"Edit" action:@selector(editButtonPressed:)];
	
}

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
	if (multipleExpressions) {
		return expressionList.count + 1;
	}
	else {
		return expressionList.count;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // the first row will be "All" for selecting all expression
	if (multipleExpressions) {
		if ([indexPath row] == 0) {
			[[cell textLabel] setText:@"All"];
		}
		else {
			[[cell textLabel] setText:[(Term *) [expressionList objectAtIndex:[indexPath row] - 1] printStringValue]];
		}
	}
	else {
		[[cell textLabel] setText:[(Term *) [expressionList objectAtIndex:[indexPath row]] printStringValue]];
	}
	
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	if (multipleExpressions && indexPath.row == 0) {
		return NO;
	}
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// delete expression from array and let the delegate know so the changes can be saved
		if (multipleExpressions) {
			[expressionList removeObjectAtIndex:indexPath.row - 1];
			[myExpressionDelegate didDeleteExpressionAtIndex:indexPath.row - 1];
		}
		else {
			[expressionList	removeObjectAtIndex:indexPath.row];
			[myExpressionDelegate didDeleteExpressionAtIndex:indexPath.row];
		}
		
        // Delete the row from the table
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	// if user moved the "all" row - ignore
	if (multipleExpressions && (fromIndexPath.row == 0 || toIndexPath.row == 0)) {
		
		[tableView reloadData];
	}
	else {
		// swap the expression lists and save
		if (multipleExpressions) {
			[expressionList exchangeObjectAtIndex:(fromIndexPath.row - 1) withObjectAtIndex:(toIndexPath.row - 1)];
			[myExpressionDelegate didMoveExpressionPostions];
		}
		else {
			[expressionList exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
			[myExpressionDelegate didMoveExpressionPostions];
		}
	}
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
	if (multipleExpressions) {
		if ([indexPath row] == 0) {
			
			[myExpressionDelegate didSelectMultipleExpressions:expressionList];
		}
		else {
			[myExpressionDelegate didSelectExpression:[expressionList objectAtIndex:[indexPath row] - 1]];
		}
	}
	else {
        [self showExpressionEditorWithTerm:[expressionList objectAtIndex:[indexPath row]]];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[expressionList release];
}


@end

