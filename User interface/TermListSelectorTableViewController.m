//
//  TermSelectorTableViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 9/13/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermListSelectorTableViewController.h"
#import "TermSelectorTableViewController.h"
#import "MyExpressionListsTableViewController.h"

#define EXPR_TEXT_FILE @"ExpressionList"
#define EXPR_TEXT_FILE_SUFFIX @"plist"
#define LIST_NAME_KEY @"Name"
#define LIST_ARRAY_KEY @"Expression List"

@implementation TermListSelectorTableViewController

@synthesize delegate, multipleTerms;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// load the expression lists
	// get property list from main bundle
	NSString *	plistPath = [[NSBundle mainBundle] pathForResource:EXPR_TEXT_FILE ofType:EXPR_TEXT_FILE_SUFFIX];
	
	// read property list into memory as an NSData object
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	
	// convert static property list into dictionary object
	NSDictionary *data = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML 
																		  mutabilityOption:NSPropertyListMutableContainersAndLeaves 
																					format:&format 
																		  errorDescription:&errorDesc];
	if (data) {
		
		// create the chapters array and return
		NSMutableArray *array = [NSMutableArray arrayWithArray:[data objectForKey:@"ExpressionLists"]];
		termListNames = [[NSMutableArray alloc] initWithCapacity:[array count]];
		termListArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
		for (int x = 0; x < [array count]; x++){
			
			// add the list names and expression lists
			[termListNames addObject:[(NSDictionary *) [array objectAtIndex:x] objectForKey:LIST_NAME_KEY]];
			[termListArray addObject:[(NSDictionary *) [array objectAtIndex:x] objectForKey:LIST_ARRAY_KEY]];
		}
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
    return [termListNames count] + 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	if (indexPath.row == 0) {
		[[cell textLabel] setText:@"My Expression Lists"];
	}
	else {
		[[cell textLabel] setText:[termListNames objectAtIndex:[indexPath row] - 1]];
	}

	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// push the term selector controller
	if (indexPath.row == 0) {
		//
		MyExpressionListsTableViewController *myExpressionListController = [[MyExpressionListsTableViewController alloc] init];
		[myExpressionListController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[myExpressionListController setTitle:@"My Expression Lists"];
		[myExpressionListController setMultipleTerms:multipleTerms];
		[myExpressionListController setExpressionListsDelegate:self];
		[self.navigationController pushViewController:myExpressionListController animated:YES];
		[myExpressionListController release];	
	}
	else {
		TermSelectorTableViewController *termSelector = [[TermSelectorTableViewController alloc] init];
		[termSelector setDelegate:self];
		[termSelector setMultipleTerms:multipleTerms];
		[termSelector setTermList:[termListArray objectAtIndex:[indexPath row] - 1]];
		[termSelector setTitle:[termListNames objectAtIndex:[indexPath row] - 1]];
		[termSelector setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
		[self.navigationController pushViewController:termSelector animated:YES];
		[termSelector release];	
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

- (void) didSelectTerm:(Term *)t {
	
	// remove the term selector controller from the stack
	[self.navigationController popViewControllerAnimated:NO];

	// pass the term back to my delegate
	[delegate didSelectTerm:t];
}

- (void) didSelectMultipleTerms:(NSArray *) terms {
	
	// remove the term selector controller from the stack
	[self.navigationController popViewControllerAnimated:NO];
	
	// pass the term array back to the delegate
	[delegate didSelectMultipleTerms:terms];
}

- (void)dealloc {
    [super dealloc];
	[termListArray release];
	[termListNames release];
}


@end

