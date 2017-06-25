//
//  Spinner.m
//  PocketAlg
//
//  Created by davidsullivan on 11/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Spinner.h"

@implementation Spinner

+(Spinner *)loadSpinnerIntoView:(UIView *)superView{
    
	// Create a new view with the same frame size as the superView
	Spinner *spinnerView = [[[Spinner alloc] initWithFrame:superView.bounds] autorelease];

	if(!spinnerView){ 
        return nil; 
    }
	
    UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge] autorelease];

	// Set the resizing mask so it's not stretched
    indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
    
	// Place it in the middle of the view
    indicator.center = superView.center;
    
	// Add the spinner view to the superView.
	[superView addSubview:spinnerView];
	return spinnerView;

	// Start it spinning
	[indicator startAnimating];
}

-(void)removeSpinner{

	[super removeFromSuperview];
}

@end
