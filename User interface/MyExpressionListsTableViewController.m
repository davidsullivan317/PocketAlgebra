//
//  MyExpressionListsTableViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 10/7/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "MyExpressionListsTableViewController.h"
#import "ArrayPersistenceHelper.h"

#define SAVED_EXPRESSION_LIST_KEY @"savedExpressionList"
#define LIST_NAME_KEY @"Name" 
#define LIST_ARRAY_KEY @"Expression List"

@implementation MyExpressionListsTableViewController

@synthesize expressionListsArray, expressionListsDelegate, multipleTerms;

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

- (void) didSelectExpression: (Term *) e {
	
	// remove the expression selector controller from the stack
	[self.navigationController popViewControllerAnimated:NO];
	
	// let the delegate know
	[expressionListsDelegate didSelectTerm:e];
	
}

- (void) didSelectMultipleExpressions: (NSArray *) expressions {
	
	// remove the expression selector controller from the stack
	[self.navigationController popViewControllerAnimated:NO];
	
	// let the delegate know
	[expressionListsDelegate didSelectMultipleTerms:expressions];	
}

- (void) didDeleteExpressionAtIndex: (NSInteger) index  {
	
	// if all expression where deleted pop the expression selection controller and delete the expression list
	NSArray *editedExpressionList = [(NSDictionary *) [expressionListsArray objectAtIndex:selectedExpressionList] objectForKey:LIST_ARRAY_KEY];
	if (editedExpressionList.count == 0) {
		
		// remove the expression selector controller from the stack
		[self.navigationController popViewControllerAnimated:YES];

		// delete the edited expression list from the array and table
		[expressionListsArray	removeObjectAtIndex:selectedExpressionList];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedExpressionList inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		
    	// save the list of expressions
		[ArrayPersistenceHelper writeArray:expressionListsArray ToNSUserDefaultsWithKey:SAVED_EXPRESSION_LIST_KEY];
		
	}
	// save the list of expressions
	[ArrayPersistenceHelper writeArray:expressionListsArray ToNSUserDefaultsWithKey:SAVED_EXPRESSION_LIST_KEY];
}

- (void) didMoveExpressionPostions {
	
	// save the list of expressions
	[ArrayPersistenceHelper writeArray:expressionListsArray ToNSUserDefaultsWithKey:SAVED_EXPRESSION_LIST_KEY];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// add the edit button 
	[self setRightNavBarItem:@"Edit" action:@selector(editButtonPressed:)];
	
	// load the list of saved expression
	self.expressionListsArray = [ArrayPersistenceHelper readArrayFromNSUserDefaultsWithKey:SAVED_EXPRESSION_LIST_KEY];
	
	if (self.expressionListsArray == nil) { 
		
		self.expressionListsArray = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
	}
}
	 
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
    return [self.expressionListsArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	[[cell textLabel] setText:[(NSDictionary *) [expressionListsArray objectAtIndex:indexPath.row] objectForKey:LIST_NAME_KEY]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

		// delete the expression list from the array and table
		[expressionListsArray	removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    	// save the list of expressions
		[ArrayPersistenceHelper writeArray:expressionListsArray ToNSUserDefaultsWithKey:SAVED_EXPRESSION_LIST_KEY];
	}   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

	// swap the expression lists and save
	[expressionListsArray exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
	[ArrayPersistenceHelper writeArray:expressionListsArray ToNSUserDefaultsWithKey:SAVED_EXPRESSION_LIST_KEY];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// push the expression selector controller
	MyExpressionSelectorTableViewController *expressionSelector = [[MyExpressionSelectorTableViewController alloc] init];
	[expressionSelector setMyExpressionDelegate:self];
	[expressionSelector setMultipleExpressions:multipleTerms];
	[expressionSelector setExpressionList:[(NSDictionary *) [expressionListsArray objectAtIndex:indexPath.row] objectForKey:LIST_ARRAY_KEY]];
	[expressionSelector setTitle:[(NSDictionary *) [expressionListsArray objectAtIndex:indexPath.row] objectForKey:LIST_NAME_KEY]];
	[expressionSelector setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
	[self.navigationController pushViewController:expressionSelector animated:YES];
	[expressionSelector release];	

	// set the selected expression list
	selectedExpressionList = indexPath.row;
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
	[expressionListsArray release];
}


@end

