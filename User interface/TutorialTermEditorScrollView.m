//
//  TutorialTermEditorScrollView.m
//  TouchAlgebra
//
//  Created by David Sullivan on 8/26/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TutorialTermEditorScrollView.h"
#import "Term.h"

@implementation TutorialTermEditorScrollView

@synthesize editEnabled, selectEnabled, selectPath;

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	if (editEnabled) {
        
        // get the tap count
        NSUInteger tapCount = [[touches anyObject] tapCount];
        
        // ignore double tap to revert to previous 
        if (tapCount == 2) {
            
            // see if previous term was double tapped
            revertTerm = [self previousTermSelectedAtTouchPoint:touches withEvent:event andTapCount:tapCount];
            if (!revertTerm) {

                [super touchesEnded:touches withEvent:event];
                
            }
        }
        else {
            
            [super touchesEnded:touches withEvent:event];
        }
	}
	
	else {
		Term *touchedTerm = [self selectTermAtTouchPoint: touches withEvent: event];
		
		// unselect term
		if (!touchedTerm) {
			[self changeSelectedTerm:nil];
		}
		
		BOOL newTermSelected = NO;
		
		if (selectedTerm) {
			
			if (selectEnabled && touchedTerm && touchedTerm != selectedTerm && [selectPath isEqual:@""]) {
				
				newTermSelected = YES;
			}
			
			if (selectEnabled) {
				
				if (![selectPath isEqual:@""]) {
					
					if ([[touchedTerm path] isEqual:selectPath]) {
						[self changeSelectedTerm:touchedTerm];
					}
				}
				else {
					[self changeSelectedTerm:touchedTerm];
				}
			}
		}
		else {
			
			// set and render the selected term
			if (selectEnabled) { 
				
				if (![selectPath isEqual:@""]) {
					
					if (([selectPath isEqual:@"ROOT"] && touchedTerm == [self activeTerm]) || [[touchedTerm path] isEqual:selectPath]) {
						
						[self changeSelectedTerm:touchedTerm];
						newTermSelected = YES;
					}
				}
				else {
					[self changeSelectedTerm:touchedTerm];
					newTermSelected = YES;
				}
			}
		}
		
		[self renderTerms];
		if (newTermSelected) {
			[self bounceTerm:selectedTerm];
		}
	}
}

- (BOOL) selectableTermDidChange: (Term *) t rootSelectPath: (NSString *) path {
	
	return (![selectPath isEqual:@""] && [[selectedTerm path] isEqual:selectPath]) || ([path isEqual:@"ROOT"] && t == [self activeTerm]);
//	if ([[scollView.selectedTerm path] isEqual:scollView.selectPath] || ([[self currentStep].selectPath isEqual:@"ROOT"] && t == [self activeTerm])) {
	
}

- (void) dealloc {
						  
	[super dealloc];
	[selectPath release];
}

@end
