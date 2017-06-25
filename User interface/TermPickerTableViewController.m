//
//  TermPickerTableViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 5/4/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermPickerTableViewController.h"
#import "Term.h"
#import "Addition.h"
#import "Multiplication.h"
#import "Constant.h"
#import "Integer.h"
#import "Equation.h"
#import "Variable.h"
#import "TermParser.h"

// some handy definitions
#define TOTAL_SECTIONS 3

@implementation TermPickerTableViewController

@synthesize delegate;

#pragma mark -
#pragma mark Initialization

- (id) init {
	
	[super initWithStyle:UITableViewStyleGrouped];
	
	
	TermParser *parser = [[TermParser alloc] init];
	
	// create the term arrays
	additionListArray		= [[NSMutableArray alloc] init];
	multiplicationListArray = [[NSMutableArray alloc] init];
	fractionListArray		= [[NSMutableArray alloc] init];
	powerListArray			= [[NSMutableArray alloc] init];
	equationListArray		= [[NSMutableArray alloc] init];
	
	// add addition terms to the arrays
	[additionListArray addObject:[parser parseTerm:@"0 + 1 + (-2) + 3 + c + c"]];
	[additionListArray addObject:[parser parseTerm:@"3*x + 4*x"]];
	[additionListArray addObject:[parser parseTerm:@"-a + a + (-a) - a - (-a)"]];
	[additionListArray addObject:[parser parseTerm:@"a + b + c"]];
	[additionListArray addObject:[parser parseTerm:@"1/3 + 2/3"]];
	[additionListArray addObject:[parser parseTerm:@"a/b + c/d"]];
	[additionListArray addObject:[parser parseTerm:@"a*x + b*x"]];
	[additionListArray addObject:[parser parseTerm:@"8*x + 4*x"]];
	[additionListArray addObject:[parser parseTerm:@"2 + 4*x"]];
	
	// add multiplication terms to the arrays
	[multiplicationListArray addObject:[parser parseTerm:@"0*1*2*(-3)*c*c"]];
	[multiplicationListArray addObject:[parser parseTerm:@"x*x*x*x"]];
	[multiplicationListArray addObject:[parser parseTerm:@"x*y*z*(2 + x + 1/2 + 3^4)"]];
	[multiplicationListArray addObject:[parser parseTerm:@"x^1*x^2*x^3"]];
	[multiplicationListArray addObject:[parser parseTerm:@"(1/3)*(x/y)*((c^2)/(a*b*c))"]];
	[multiplicationListArray addObject:[parser parseTerm:@"a*(b/c)"]];

	// add fraction terms to the arrays
	[fractionListArray addObject:[parser parseTerm:@"2/1 + 2/(-1) + c/c + (a + b)/(a + b) + c^2/c^2"]];
	[parser release];
	
	return self;
}

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	}
	return NO;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return TOTAL_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	// Return the number of rows in the section
	if (section == 0) {
		return [additionListArray count];
	}
	else if (section == 1) {
		return [multiplicationListArray count];
	}
	else if (section == 2) {
		return [fractionListArray count];
	}
	
	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TermListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	Term *t;
	if ([indexPath indexAtPosition:0] == 0) {
		
		t = [additionListArray objectAtIndex:[indexPath row]];
	}
	else if ([indexPath indexAtPosition:0] == 1) {
		
		t = [multiplicationListArray objectAtIndex:[indexPath row]];
	}
	else if ([indexPath indexAtPosition:0] == 2) {
		
		t = [fractionListArray objectAtIndex:[indexPath row]];
	}
	
	[[cell textLabel] setText:[t printStringValue]];
    
    return cell;
}

// add section titles
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == 0) {
		return @"Addition terms";
	}
	else if (section == 1) {
		return @"Multiplication terms";
	}
	else if (section == 2) {
		return @"Fraction terms";
	}
	
	return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	Term *t;
	if ([indexPath indexAtPosition:0] == 0) {
		
		t = [additionListArray objectAtIndex:[indexPath row]];
	}
	else if ([indexPath indexAtPosition:0] == 1) {
		
		t = [multiplicationListArray objectAtIndex:[indexPath row]];
	}
	else if ([indexPath indexAtPosition:0] == 2) {
		
		t = [fractionListArray objectAtIndex:[indexPath row]];
	}
	
	if (t) {
		
		[self dismissModalViewControllerAnimated:YES];
		[delegate didPickTerm:[[t copy] autorelease]];
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
	
	[additionListArray release];
	[multiplicationListArray release];
	[fractionListArray release];
	[powerListArray release];
	[equationListArray release];
			
    [super dealloc];
}

@end

