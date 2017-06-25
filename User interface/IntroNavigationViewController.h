//
//  IntroNavigationViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 8/6/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermInputController.h"
#import "TermListSelectorTableViewController.h"


@interface IntroNavigationViewController : UIViewController <TermListSelectorDelegate, TermInputDelegate> {
	
	IBOutlet UIButton *expressionListButton;
	IBOutlet UIButton *choseExpressionButton;
	IBOutlet UIButton *enterExpressionButton;
	IBOutlet UIButton *tutorialButton;
	IBOutlet UIButton *helpButton;
	
	BOOL firstRun;
	
}

@property (nonatomic, retain) IBOutlet UIButton *expressionListButton;
@property (nonatomic, retain) IBOutlet UIButton *enterExpressionButton;
@property (nonatomic, retain) IBOutlet UIButton *choseExpressionButton;
@property (nonatomic, retain) IBOutlet UIButton *tutorialButton;
@property (nonatomic, retain) IBOutlet UIButton *helpButton;

- (IBAction) tutorialButtonPressed;
- (IBAction) enterExpressionButtonPressed;
- (IBAction) choseExpressionButtonPressed;
- (IBAction) expressionListButtonPressed;
- (IBAction) helpButtonPressed;

@end
