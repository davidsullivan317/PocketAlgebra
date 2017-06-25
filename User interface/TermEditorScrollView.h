//
//  TermEditorScrollView.h
//  TouchAlgebra
//
//  Created by David Sullivan on 4/28/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Term;

@protocol TermEditorScrollViewDelegate

- (void) selectedTermDidChange: (Term *) t; 
- (void) newTermAdded: (Term *) t;

@end


@interface TermEditorScrollView : UIScrollView {
	
	id <TermEditorScrollViewDelegate> termEditorScrollViewDelegate;

	NSMutableArray	*terms;			// active term and the term history
	Term			*selectedTerm;	// term selected and highlighted
	
	UIView *backgroundView;			// background view needed for zooming
	
	Term	*revertTerm;			// term selected when reverting
	
}

@property (nonatomic, assign) id <TermEditorScrollViewDelegate> termEditorScrollViewDelegate;
@property (nonatomic, assign) IBOutlet UIView *backgroundView;

@property (nonatomic, assign) Term *selectedTerm;

// set the initial term to be manipulated
// this will replace all terms in the view
- (void) setInitialTerm: (Term *) term;

// the previous and active term
- (Term *) activeTerm;
- (Term *) previousTerm;

- (void)   clearTerms;

- (NSInteger) termCount;

// term manipulations methods
- (void) multiplyEquationBy:		(Term *) t;
- (void) divideEquationBy:			(Term *) t;
- (void) raiseEquationByExp:		(Term *) t;
- (void) addToEquationTerm:			(Term *) t;
- (void) subtractFromEquationTerm:  (Term *) t;
- (void) multiplySelectedTermByOne: (Term *) t;

// "protected" methods
- (void) changeSelectedTerm: (Term *) t;
- (Term *) selectTermAtTouchPoint:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) renderTerms;
- (void) bounceTerm: (Term *) t;
- (Term *) previousTermSelectedAtTouchPoint:(NSSet *)touches withEvent:(UIEvent *)event andTapCount: (NSUInteger) tapCount;

@end

