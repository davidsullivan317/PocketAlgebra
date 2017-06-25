//
//  TutorialViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 8/6/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialTermEditorScrollView.h"

@class TutorialChapter;
@class TutorialStep;

@interface TutorialViewController : UIViewController <UIScrollViewDelegate, TermEditorScrollViewDelegate> {

	UIView *backgroundView;			// background view needed for zooming
	
	IBOutlet TutorialTermEditorScrollView	*scollView;
	IBOutlet UILabel	*tutorialText;
	IBOutlet UILabel	*largeText;
	IBOutlet UILabel	*tutorialTitle;
	
	IBOutlet UIButton *backButton;
	IBOutlet UIButton *nextButton;
	IBOutlet UIView   *navigationView;
	
	IBOutlet UIProgressView *progressBar;
	
	NSMutableArray *chapters;
	NSInteger currentChapterIndex;
	NSInteger currentStepIndex;
}
@property (nonatomic, assign) IBOutlet UIView *backgroundView;

@property (nonatomic, retain) IBOutlet TermEditorScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *tutorialText;
@property (nonatomic, retain) IBOutlet UILabel *largeText;
@property (nonatomic, retain) IBOutlet UILabel *tutorialTitle;

@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;

@property (nonatomic, retain) IBOutlet UIView *navigationView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressBar;

@property (nonatomic, retain) NSMutableArray *chapters;
@property (nonatomic) NSInteger currentChapterIndex;
@property (nonatomic) NSInteger currentStepIndex;

- (IBAction) backButtonPressed;
- (IBAction) nextButtonPressed;

- (TutorialChapter *) currentChapter;
- (TutorialStep *)    currentStep;
- (NSInteger)         stepCount;

- (BOOL) lastChapter;
- (BOOL) lastStep;

- (void) displayCurrentStep;

@end
