//
//  TutorialTableViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 8/6/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TutorialChapter;
@class TutorialStep;

@interface TutorialTableViewController : UITableViewController {

	NSMutableArray *chapters;
	
	NSInteger currentChapter;
	NSInteger currentStep;
	
	BOOL firstRunControllerShown;
	BOOL firstRun;
}

@end
