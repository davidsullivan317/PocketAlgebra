//
//  TutorialViewController.m
//  TouchAlgebra
//
//  Created by David Sullivan on 8/6/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermEditorScrollView.h"
#import "TutorialViewController.h"
#import "TutorialStep.h"
#import "TutorialChapter.h"
#import "TermParser.h"
#import "Term.h"

@implementation TutorialViewController

@synthesize scrollView, tutorialTitle, tutorialText, largeText, backButton, nextButton, 
            navigationView, progressBar, chapters, currentChapterIndex, currentStepIndex, backgroundView;

- (TutorialChapter *) currentChapter {
	
	return (TutorialChapter *) [chapters objectAtIndex:currentChapterIndex];
}

- (TutorialStep *)    currentStep {
	
	return [[[self currentChapter] steps] objectAtIndex:currentStepIndex];
}

- (NSInteger) stepCount {
	
	return [[[self currentChapter] steps] count];
}

- (BOOL) lastChapter {
	
	return currentChapterIndex == (chapters.count - 1);
}

- (BOOL) lastStep {
	
	return currentStepIndex == ([self stepCount] - 1);
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {

	// we only run in landscape orientation
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	}
	return NO;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	
    return self.scrollView.backgroundView;
}

- (void) displayCurrentStep {
	
	progressBar.progress = (float) (currentStepIndex  + 1)/(float) [self stepCount];
	
	tutorialTitle.text = [self currentChapter].title;
	
	// parse the expression
	if ([[self currentStep].expression isEqual:@""]) {
		largeText.text = [self currentStep].text;
		tutorialText.text = @"";
		[scollView clearTerms];
		[scollView renderTerms];
	}
	else {
		TermParser *parser = [[[TermParser alloc] init] autorelease];
		Term *t = [parser parseTerm:[self currentStep].expression];
		if (![parser parseError]) {
			[scollView setInitialTerm:t];
		}
		largeText.text = @"";
		tutorialText.text = [self currentStep].text;
		scollView.editEnabled = [self currentStep].editEnabled;
		scollView.selectEnabled = [self currentStep].selectEnabled;
		scollView.selectPath = [self currentStep].selectPath;
	}

	// set the next button status
	if ([self lastChapter] && [self lastStep]) {
		nextButton.enabled = NO;
	}
	else {
		nextButton.enabled = YES;
	}

	// set the previous button status
	if (currentChapterIndex == 0 && currentStepIndex == 0) {
		backButton.enabled = NO;
	}
	else {
		backButton.enabled = YES;
	}
}

- (void) return {
	
	[self dismissModalViewControllerAnimated:YES];

}

- (IBAction) backButtonPressed {
	
	if (currentStepIndex == 0 && currentChapterIndex == 0) {
		[self return];
	}
	else if (currentStepIndex == 0) {
		currentChapterIndex--;
		currentStepIndex = [self currentChapter].steps.count - 1;
	}
	else {
		currentStepIndex--;
		
	}
	[self displayCurrentStep];
}

- (IBAction) nextButtonPressed {
	
	if ([self lastChapter] && [self lastStep]) {
		[self return];
	}
	else if ([self lastStep]) {
		currentChapterIndex++;
		currentStepIndex = 0;
	}
	else {
		currentStepIndex++;

	}
	[self displayCurrentStep];
}

- (void) selectedTermDidChange: (Term *) t {
	
	// See if user selected the right term
	if ([scollView selectableTermDidChange:t rootSelectPath:[self currentStep].selectPath]) {
		
		tutorialText.text = [self currentStep].successText;
		[tutorialText setNeedsDisplay];
	}
}

- (void) newTermAdded:(Term *)t {

	// see if the new term is the success expression
	if ([scollView termCount] > 1 && ![[self currentStep].successExpression isEqual:@""]) {

		TermParser *parser = [[[TermParser alloc] init] autorelease];
		Term *successTerm = [parser parseTerm:[self currentStep].successExpression];
		if (![parser parseError]) {
			
			if ([t isEquivalent:successTerm]) {

				tutorialText.text = [self currentStep].successText;
				scollView.editEnabled = NO;
				[tutorialText setNeedsDisplay];
			}
		}
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];

	[tutorialText release];
	[tutorialTitle release];
	[scollView release];
	[backButton release];
	[nextButton release];
	[navigationView release];
	[progressBar release];
	
	if (chapters) {
		[chapters release];
	}
}


@end
