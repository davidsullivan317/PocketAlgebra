//
//  TermListScrollView.m
//  Views
//
//  Created by David Sullivan on 4/16/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TermListScrollView.h"
#import "Term.h"
#import "Equation.h"
#import "Addition.h"

#define LINE_SPACING  15
#define LEFT_MARGIN	  15
#define MOVING_TERM_OFFSET 50
#define  MIN_FRAME_WIDTH 320

@implementation TermListScrollView

@synthesize selectedTerm, termList, termListScrollViewDelegate, backgroundView, emptyListPrompt;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	
	self = [super initWithCoder:decoder];
	if (self) {

		// initialize the arrays after loading from NIB
		termList    = [[NSMutableArray alloc] initWithCapacity:3];
		lineNumbers = [[NSMutableArray alloc] initWithCapacity:3];
	}
	return self;
	
}	

- (void) renderTerms {
	
	// remove all terms from the view
	for (Term *t in termList) {
		[t removeFromSuperview];
	}
	
	// remove all line numbers
	for (UIView *v in lineNumbers) {
		[v removeFromSuperview];
	}
	[lineNumbers removeAllObjects];
	
	[UIView beginAnimations:@"Render Views" context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	// render all terms
	UIFont *f = [UIFont fontWithName:@"CourierNewPS-ItalicMT" size:24];
	int y = LINE_SPACING;
	int width = 0;
	int count = 0;
	for (Term *t in termList) {
		
		// render the line number
		NSString *s = [NSString stringWithFormat:@"%i.", count + 1];
		UILabel *ln = [[[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, y, [s sizeWithFont:t.font].width, [s sizeWithFont:t.font].height)] autorelease];
		[ln setBackgroundColor:[UIColor clearColor]];
		[ln setTextColor:DEFAULT_TERM_COLOR];
		[ln setText:s];
		[ln setFont:f];
		[backgroundView addSubview:ln];
		[lineNumbers addObject:ln];
		
		// render the term
		[t renderInView:backgroundView atLocation:CGPointMake(LEFT_MARGIN * 2 + ln.frame.size.width, y)];
		
		width = MAX(width, t.frame.size.width + [s sizeWithFont:t.font].width);
		y += t.frame.size.height + LINE_SPACING;
		count++;
		
	}	
	[UIView commitAnimations];
	
	// reset the context size
	backgroundView.frame = CGRectMake(0, 0, MAX((width + 3*LEFT_MARGIN)*self.zoomScale, MIN_FRAME_WIDTH), y*self.zoomScale);
	[self setContentSize:self.backgroundView.frame.size];
	
	// display the empty list prompt as necessary
	if (termList.count == 0) {
		emptyListPrompt.hidden = NO;
	}
	else {
		emptyListPrompt.hidden = YES;
	}
}

- (void) scrollToBottom {
	
	// force scrolling to the bottom 
	Term *t = [termList lastObject];
	[self scrollRectToVisible:CGRectMake(t.frame.origin.x*self.zoomScale, 
										 (t.frame.origin.y + t.frame.size.height)*self.zoomScale, 
										 LEFT_MARGIN*self.zoomScale, 
										 LINE_SPACING*self.zoomScale) animated:NO];	
}

- (void) addTerm: (Term *) t {
	
	// add to the term list and set the color
	[termList addObject:t];
	[t setColorRecursively:DEFAULT_TERM_COLOR];

	// Rerender the terms
	[self renderTerms];	
	
	[self scrollToBottom];
}   

- (void) removeTerm: (Term *) t {
	
	// unselect term if necessary
	if ([selectedTerm upperMostParentTerm] == t) {
        [self setSelectedTerm:nil];
		[termListScrollViewDelegate didChangeSelectedTerm:nil];
	}
	
	// remove from the term list and view
	[termList removeObject:t];
	[t removeFromSuperview];
	
	// remove the last line number
	[[lineNumbers lastObject] removeFromSuperview];
	[lineNumbers removeObject:[lineNumbers lastObject]];
	
	// Rerender the terms
	[self renderTerms];	
}

- (void) removeAllTerms {
	
	// unselect the term
	selectedTerm = nil;
	[termListScrollViewDelegate didChangeSelectedTerm:nil];

	// remove all terms
	for (Term *t in termList) {
		[t removeFromSuperview];
	}
	[termList removeAllObjects];

	// remove all line numbers
	for (UIView *v in lineNumbers) {
		[v removeFromSuperview];
	}
	[lineNumbers removeAllObjects];
	
	// Rerender the terms
	[self renderTerms];		
}

- (void) replaceTerm: (Term *) t1 withTerm: (Term *) t2 {
	
	// replace the term in the term list and set the color
	[t1 removeFromSuperview];
	[termList replaceObjectAtIndex:[termList indexOfObject:t1] withObject:t2];
	[t2 setColorRecursively:DEFAULT_TERM_COLOR];
	
	// Rerender the terms
	[self renderTerms];	
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

- (Term *) selectTermAtTouchPoint:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// get the touch point
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	
	// find the selected term
	UIView *selectedView = [self hitTest:touchPoint withEvent:event];
	if (selectedView == self || selectedView == backgroundView) {
		return nil; // everything else is a term
	}
	else if (![selectedView isKindOfClass:[Term class]]) {
		selectedView = [selectedView superview]; // if view is +, -, etc. the superview is the term
	}
	
	Term *selectedTermView = [(Term *) selectedView upperMostParentTerm];

	return [selectedTermView selectTermAtPoint:[self convertPoint:touchPoint toView:selectedTermView]];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
	Term *touchedTerm = [self selectTermAtTouchPoint: touches withEvent: event];

	BOOL newTermSelected = NO;
	
	// check for equation addition and term substitution
	if (selectedTerm) {
				
		if (touchedTerm && touchedTerm != selectedTerm) {
			
			// add equations
			if ([selectedTerm isKindOfClass:[Equation class]] && [touchedTerm  isKindOfClass:[Equation class]]) {
				
				// create a new equation adding LHS && RHS
				Addition *newLHS = [[[Addition alloc] init:[(Equation *) touchedTerm LHS], [(Equation *) selectedTerm LHS], nil] autorelease];
				Addition *newRHS = [[[Addition alloc] init:[(Equation *) touchedTerm RHS], [(Equation *) selectedTerm RHS], nil] autorelease];
				Equation *newEq = [[[Equation alloc] initWithLHS:newLHS andRHS:newRHS] autorelease];
				
				// remove the added equations
				[self removeTerm:selectedTerm];
				[self removeTerm:touchedTerm];
				
				// reset the selected term and clean up the dropped term
				[self setSelectedTerm:nil];
				
				// add the new equation and render
				[self addTerm:newEq];
				
			}

			// otherwise select the touched term
			else {
				
				Term *prevSelected = selectedTerm;
				
				[self setSelectedTerm:touchedTerm];
				newTermSelected = YES;

				// substitude LHS/RHS in equation
				if([[prevSelected parentTerm] isKindOfClass:[Equation class]] ) {
					
					// are the selected terms equivelent?
					if ([selectedTerm isEquivalent:prevSelected]) {
						
						// if the selected term is LHS the substitution term is the RHS and vice versa
						Equation *e = (Equation *) [prevSelected parentTerm];
						Term *subTerm = nil;
						if ([e LHS] == prevSelected) {
							subTerm = [e.RHS copy];
						}
						else {
							subTerm = [e.LHS copy];
						}
						
						// save the parent term
						Term *parent = [selectedTerm parentTerm];
						[parent replaceSubterm:selectedTerm withTerm:subTerm];
						[parent setColorRecursively:DEFAULT_TERM_COLOR];
						[self setSelectedTerm:nil];
						[subTerm autorelease];

					}
				}
				
			}

		}
		
		// unselect if no term touched
		else if (!touchedTerm) {
			[self setSelectedTerm:touchedTerm];
		}

	}
	else {
		
		// set and render the selected term
		[self setSelectedTerm:touchedTerm];
		newTermSelected = YES;
	}
	
	[self renderTerms];
	if (newTermSelected) {
		[self bounceTerm:selectedTerm];
	}
}

- (void) setSelectedTerm: (Term *) t {
	
	// nothing changed?
	if ((t || selectedTerm) && (selectedTerm != t)) {
		
		// reset the old selected term 
		if (selectedTerm) {
			[selectedTerm setIsSelected:NO];
			[selectedTerm setColorRecursively:DEFAULT_TERM_COLOR];
			selectedTerm = nil;
		}
		
		// set and highlight the new term 
		selectedTerm = t;
		[termListScrollViewDelegate didChangeSelectedTerm:selectedTerm];
		if (selectedTerm) {
			[selectedTerm setIsSelected:YES];
			[selectedTerm setColorRecursively:LIST_SELECTED_TERM_COLOR];
		}
	}
}

- (void)dealloc {
	[termList release];
	[lineNumbers release];
    [super dealloc];
}


@end
