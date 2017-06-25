//
//  TermEditorScrollView.m
//  TouchAlgebra
//
//  Created by David Sullivan on 4/28/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#define LINE_SPACING  15
#define LEFT_MARGIN	  15
#define INACTIVE_TERM_COLOR [UIColor lightGrayColor]
#define MAX_DISPLAY_TERMS 5
#define REVERT_EXPRESSION_ALERT 1

#import "TermEditorScrollView.h"
#import "Term.h"
#import "SymbolicTerm.h"
#import "Multiplication.h"
#import "Integer.h"
#import "Equation.h"
#import "Fraction.h"
#import "Addition.h"
#import "Power.h"

@implementation TermEditorScrollView

@synthesize termEditorScrollViewDelegate, backgroundView, selectedTerm;

- (id)initWithCoder:(NSCoder *)decoder {
	
	self = [super initWithCoder:decoder];
	if (self) {
		
		// initialize the arrays after loading from NIB
		terms    = [[NSMutableArray alloc] initWithCapacity:3];
	}
	return self;
	
}	

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {

		// initialize the terms array
		terms = [[[NSMutableArray alloc] initWithCapacity:10] retain];

    }
    return self;
}

- (NSInteger) termCount {

	return terms.count;
}

- (Term *) activeTerm {
	
	if ([terms count] > 0) {
		return [terms lastObject];
	} 
	return nil;
}

- (Term *) previousTerm {
	
	if ([terms count] > 1) {
		return [terms objectAtIndex:[terms count] - 2];
	} 
	return nil;
}

- (void) scrollToBottom {
	
	// force scrolling to the bottom 
	Term *t = [self activeTerm];
	[self scrollRectToVisible:CGRectMake(t.frame.origin.x*self.zoomScale, 
										 (t.frame.origin.y + t.frame.size.height)*self.zoomScale, 
										 LEFT_MARGIN*self.zoomScale, 
										 LINE_SPACING*self.zoomScale) animated:NO];	
}

- (Term *) previousTermSelectedAtTouchPoint:(NSSet *)touches withEvent:(UIEvent *)event andTapCount: (NSUInteger) tapCount {
	
	// double tap to select
	if (tapCount == 2) {
		
		// get the touch point and touched view
		CGPoint touchPoint = [[touches anyObject] locationInView:self];
		UIView *touchedView = [self hitTest:touchPoint withEvent:event];
		
		// if the touch is in the active term, return nil
		if (([touchedView isDescendantOfView:[self activeTerm]])) {
			
			return nil;
		}
		
		// see if one of the previous terms was tapped
		for (Term *t in terms) {
			if (([touchedView isDescendantOfView:t])) {
				
				return t;
			}
		}
	}
	return nil;
}

- (Term *) selectTermAtTouchPoint:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// get the touch point and touched view
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	UIView *touchedView = [self hitTest:touchPoint withEvent:event];
	
	// if the touch is not in the active term, return nil
	if (!([touchedView isDescendantOfView:[self activeTerm]])) {
		
		return nil;
	}
		
	return [[self activeTerm] selectTermAtPoint:[self convertPoint:touchPoint toView:[self activeTerm]]];
}

- (void) renderTerms {
	
	// remove all terms from the view
	for (Term *t in terms) {
		[t removeFromSuperview];
	}
	
	[UIView beginAnimations:@"Render Views" context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	// render only the last N terms
	int y = LINE_SPACING;
	int width = 0;
	for (int x = [terms count] > MAX_DISPLAY_TERMS ? [terms count] - MAX_DISPLAY_TERMS : 0; x < [terms count]; x++ ) {
		
		Term *t = [terms objectAtIndex:x];
				   
		[t renderInView:backgroundView atLocation:CGPointMake(LEFT_MARGIN, y)];
		
		width = MAX(width, t.frame.size.width);
		y += t.frame.size.height + LINE_SPACING;

	}	
	[UIView commitAnimations];
	
	// reset the context size
	self.backgroundView.frame = CGRectMake(0, 0, (width + 2*LEFT_MARGIN)*self.zoomScale, y*self.zoomScale);
	[self setContentSize:self.backgroundView.frame.size];
	[self addSubview:backgroundView];
	[self.backgroundView setNeedsDisplay];
}

- (void) changeSelectedTerm: (Term *) t {
	
	// nothing changed?
	if ((t || selectedTerm) && (selectedTerm != t)) {
		
		// reset the old selected term 
		if (selectedTerm) {
			[selectedTerm setIsSelected:NO];
			[selectedTerm setColorRecursively:DEFAULT_TERM_COLOR];
			self.selectedTerm = nil;
		}
		
		// set and highlight the new term 
		self.selectedTerm = t;
		[selectedTerm setIsSelected:YES];
		[selectedTerm setColorRecursively:EDIT_SELECTED_TERM_COLOR];
		
		// let the delegate know
		[termEditorScrollViewDelegate selectedTermDidChange:selectedTerm];
		[self renderTerms];
	}
}

- (void) clearTerms {
	
	// clear the selected term
	[self changeSelectedTerm:nil];
	
	// remove all terms from the view
	for (Term *t in terms) {
		[t removeFromSuperview];
	}
	
	[terms removeAllObjects];
}

- (void) addNewTermVersion: (Term *) t {
	
	// unselect the current term 
	[self changeSelectedTerm:nil];
	[[self activeTerm] setColorRecursively:INACTIVE_TERM_COLOR];
	
	// add the new term to the array resetting font and color
	[t setFont:t.font];
	[t setColorRecursively:DEFAULT_TERM_COLOR];
	[terms	addObject:t];
	
	// save the horizontal position
	float x = self.bounds.origin.x;
	
	// render with the new term
	[self renderTerms];
	
	// force scrolling to the bottom, retaining horizontal position
	[self scrollRectToVisible:CGRectMake(x, 
										 ([self activeTerm].frame.origin.y + [self activeTerm].frame.size.height)*self.zoomScale, 
										 LEFT_MARGIN*self.zoomScale, 
										 LINE_SPACING*self.zoomScale) animated:YES];
	
	// let the delegate know about the new term
	[termEditorScrollViewDelegate newTermAdded:t];
}

- (void) setInitialTerm: (Term *) term {
	
	[self clearTerms];
	[self addNewTermVersion:term];
}

- (void) multiplyEquationBy: (Term *) t {
	
	Equation *e = (Equation *) [self activeTerm];
	Multiplication *newLHS = [[[Multiplication alloc] init:[e LHS], t, nil] autorelease];
	Multiplication *newRHS = [[[Multiplication alloc] init:[e RHS], t, nil] autorelease];
	Equation *newTerm = [[[Equation alloc] initWithLHS:newLHS andRHS:newRHS] autorelease];
	[self addNewTermVersion:newTerm];
}

- (void) divideEquationBy: (Term *) t {
	
	// make sure we're not dividing by zero
	if ([t isZero]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Division by zero!" message:@"You cannot divide by zero" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	Equation *e = (Equation *) [self activeTerm];
	Multiplication *newLHS = [[[Fraction alloc] initWithNum:[e LHS] andDenom:t] autorelease];
	Multiplication *newRHS = [[[Fraction alloc] initWithNum:[e RHS] andDenom:t] autorelease];
	Equation *newTerm = [[[Equation alloc] initWithLHS:newLHS andRHS:newRHS] autorelease];
	[self addNewTermVersion:newTerm];
}

- (void) raiseEquationByExp: (Term *) t {
	
	Equation *e = (Equation *) [self activeTerm];
	Power *newLHS = [[[Power alloc] initWithBase:[e LHS] andExponent:t] autorelease];
	Power *newRHS = [[[Power alloc] initWithBase:[e RHS] andExponent:t] autorelease];
	Equation *newTerm = [[[Equation alloc] initWithLHS:newLHS andRHS:newRHS] autorelease];
	[self addNewTermVersion:newTerm];
}

- (void) addToEquationTerm: (Term *) t {
	
	Equation *e = (Equation *) [self activeTerm];
	Addition *newLHS = [[[Addition alloc] init:[e LHS], t, nil] autorelease];
	Addition *newRHS = [[[Addition alloc] init:[e RHS], t, nil] autorelease];
	Equation *newTerm = [[[Equation alloc] initWithLHS:newLHS andRHS:newRHS] autorelease];
	[self addNewTermVersion:newTerm];
}

- (void) subtractFromEquationTerm: (Term *) t {

	Equation *e = (Equation *) [self activeTerm];
	Addition *newLHS = [[[Addition alloc] init:[e LHS], t, nil] autorelease];
	Addition *newRHS = [[[Addition alloc] init:[e RHS], t, nil] autorelease];
	[newLHS	setOperator:SUBTRACTION_OPERATOR atIndex:[newLHS count] - 1];
	[newRHS	setOperator:SUBTRACTION_OPERATOR atIndex:[newRHS count] - 1];
	Equation *newTerm = [[[Equation alloc] initWithLHS:newLHS andRHS:newRHS] autorelease];
	[self addNewTermVersion:newTerm];
}

- (void) multiplySelectedTermByOne: (Term *) t {
	
	if (selectedTerm) {

		// make sure the 
		if ([t isZero]) {
			// show error message
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Division by zero!" message:@"The you cannot use a zero expression when multiplying an expression by one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alert show];
			return;
		}
		Fraction *f = [[[Fraction alloc] initWithNum:t andDenom:t] autorelease];
		
		if ([selectedTerm parentTerm]) {
			
			Multiplication *newSubTerm = [[[Multiplication alloc] init:selectedTerm, f, nil] autorelease];
			
			Term *newTerm = [[[selectedTerm upperMostParentTerm] copy] autorelease];
			
			[newTerm replaceSubterm:[newTerm termAtPath:[selectedTerm path]] withTerm:newSubTerm];
			
			[self addNewTermVersion:newTerm];
		}
		else {
			Multiplication *newTerm = [[[Multiplication alloc] init:selectedTerm, f, nil] autorelease];
			[self addNewTermVersion:newTerm];
		}
	}
}

- (void) bounceTerm: (Term *) t {
	
	#define DURATION 0.15
	
	// save the term location 
	CGPoint c = t.center;
	
	// expand
	[UIView	animateWithDuration:DURATION 
						  delay:0 
						options:UIViewAnimationOptionTransitionNone 
					 animations:^{
						 CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
						 t.transform = transform;
						 t.center = c;
					 }
					 completion:^(BOOL finished){
						 
						 // contract
						 [UIView	animateWithDuration:DURATION 
											   delay:0 
											 options:UIViewAnimationOptionTransitionNone 
										  animations:^{
											  CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
											  t.transform = transform;
											  t.center = c;
										  }
										  completion:^(BOOL finished){
											  
										  }
						  ];					
					 }
	 ];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	// get the tap count
    NSUInteger tapCount = [[touches anyObject] tapCount];
	
	// if double tap on a opposite symbolic term, power or integer
	// change to multiply by -1 (e.g. -c to -1*c)
	if (tapCount == 2) {
		
		if (([selectedTerm isKindOfClass:[SymbolicTerm class]] || [selectedTerm isKindOfClass:[Power class]]) && [selectedTerm isOpposite]) {
			
			// create the multiplication
			Integer *negativeOne = [[[Integer alloc] initWithInt:-1] autorelease];
			Term *t = [[selectedTerm copy] autorelease];
			[t opposite];
			Multiplication *m = [[[Multiplication alloc] init: negativeOne, t, nil] autorelease];
			[m setColorRecursively:DEFAULT_TERM_COLOR];
			
			// replace the term with the multiplication
			if ([selectedTerm parentTerm] ) {
				[termEditorScrollViewDelegate newTermAdded:[selectedTerm upperMostParentTerm]]; // not really a new term, but changed
				[[selectedTerm parentTerm] replaceSubterm:selectedTerm withTerm:m];
				[self changeSelectedTerm:nil];
				[self renderTerms];
			}
			else {
				[self addNewTermVersion:m];
			}

		}
		else if ([selectedTerm isKindOfClass:[Integer class]] && [(Integer *) selectedTerm isOpposite]) {
			
			// create the multiplication
			Integer *negativeOne = [[[Integer alloc] initWithInt:-1] autorelease];
			Integer *i = [[selectedTerm copy] autorelease];
			[i opposite];
			Multiplication *m = [[[Multiplication alloc] init: negativeOne, i, nil] autorelease];
			[m setColorRecursively:DEFAULT_TERM_COLOR];
			
			// replace the symbolic term with the multiplication
			if ([selectedTerm parentTerm] ) {
				[termEditorScrollViewDelegate newTermAdded:[selectedTerm upperMostParentTerm]]; // not really a new term, but changed
				[[selectedTerm parentTerm] replaceSubterm:selectedTerm withTerm:m];
				[self changeSelectedTerm:nil];
				[self renderTerms];
			}
			else {
				[self addNewTermVersion:m];
			}
			
		}
		
        else {
            // see if previous term was double tapped
            revertTerm = nil;
            if (revertTerm = [self previousTermSelectedAtTouchPoint:touches withEvent:event andTapCount:tapCount]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Revert to previous expression?" message:@"Would you like to revert to the selected expression?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
                alert.tag = REVERT_EXPRESSION_ALERT;
                [alert show];
                [alert release];
            }
        }
	}
	else {
		
		// was a different term selected?
		Term *touchedTerm = [self selectTermAtTouchPoint: touches withEvent: event];
		
		BOOL newTermSelected = NO;
		
		if (selectedTerm) {
			
			if (touchedTerm && touchedTerm != selectedTerm) {
				
				// selected terms are subterms of the active term?
				if ([[self activeTerm] isSubTerm:selectedTerm] && [[self activeTerm] isSubTerm:touchedTerm]) {
					
					// reduce 
					Term	*newTerm = [[Term copyTerm:[self activeTerm] 
										 reducingWithSubTerm:selectedTerm 
										  andSubTerm:touchedTerm] autorelease];
					
					if (newTerm) {
						
						[self addNewTermVersion:newTerm];
												
					}
					
					// select the new term instead
					else {
						[self changeSelectedTerm:touchedTerm];
						newTermSelected = YES;
						
					}
					
				}
				else {
					
					[self changeSelectedTerm:touchedTerm];
					newTermSelected = YES;
				}
			}
			
			// unselect if no term touched
			else if (!touchedTerm) {
				[self changeSelectedTerm:touchedTerm];
			}
			
		}
		else {
			
			// set and render the selected term
			[self changeSelectedTerm:touchedTerm];
			newTermSelected = YES;
		}
		
		[self renderTerms];
		if (newTermSelected) {
			[self bounceTerm:selectedTerm];
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		case REVERT_EXPRESSION_ALERT:
			if (buttonIndex == 1) {
				
				// reset the font on the revert term
				[revertTerm setFont:revertTerm.font];
				[revertTerm setColorRecursively:DEFAULT_TERM_COLOR];
				[self changeSelectedTerm:nil];
				
				[UIView beginAnimations:@"Revert term" context:nil];
				[UIView setAnimationDuration:0.25];
				[UIView setAnimationBeginsFromCurrentState:YES];
				
				
				int removeCount = [terms count] - [terms indexOfObject:revertTerm] - 1;
				for (int x = 0; x < removeCount; x++) {
					[[terms lastObject] removeFromSuperview];
					[terms removeLastObject];
				}
				[self renderTerms];
                [self scrollToBottom];
				[UIView commitAnimations];

			}
			revertTerm = nil;
			break;
	}
}

- (void)dealloc {
	
    [super dealloc];
	[terms release];
}

@end
