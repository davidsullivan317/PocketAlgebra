//
//  ListOperator.m
//  TouchAlgebra
//
//  Created by David Sullivan on 7/7/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "ListOperator.h"
#import "Addition.h"
#import	"Multiplication.h"
#import "Power.h"
#import "Integer.h"

@implementation ListOperator

@synthesize termList;

- (id) initWithTermValue:(NSString *) someStringValue {
	
	// term value is always "ListOperator"
	if (self = [super initWithTermValue:@"ListOperator"]) {
		
		// initialize the term list
		NSMutableArray *tl = [[[NSMutableArray alloc] initWithCapacity:(NSUInteger) 3] autorelease]; 
		[self setTermList:tl];
		
		// set a default rendering base
		renderingBase = [super renderingBase];
	}
	
	return self;
}

- (id) init {
	
	return [self initWithTermValue:@""];
}

- (void) insertTerm:(Term *) newTerm atIndex: (NSUInteger) index{

	// if newTerm is the same class, add its subterms instead
	if ([newTerm isKindOfClass:[ListOperator class]] && [self class] == [newTerm class]) {
		NSUInteger i = index;
		for (Term *t in [(ListOperator *) newTerm termList]) {
			
			Term *termCopy = [[t copy] autorelease];
			[termCopy setParentTerm:self];
			[termList insertObject:termCopy atIndex:i++];
		}
	} 
	else {
		Term *termCopy = [[newTerm copy] autorelease];
		[termCopy setParentTerm:self];
		[termList insertObject:termCopy  atIndex:index];
	}

	
}

- (void) appendTerm:(Term *) newTerm{
	
	[self insertTerm:newTerm atIndex:[termList count]];
}

- (void) removeTerm:(Term *) oldTerm{

    if ([termList indexOfObject:oldTerm] != NSNotFound) {
        
        [termList removeObjectIdenticalTo:oldTerm];
        [oldTerm setParentTerm:nil];
    }
	
}

- (void) removeTermAtIndex: (NSUInteger) index{
	
	[[termList objectAtIndex:index] setParentTerm:nil];
	[termList removeObjectAtIndex:index];
	
}

- (BOOL) replaceSubterm: (Term *) oldTerm withTerm: (Term *) newTerm {
	
	for (Term *t in termList) {
		if ([t replaceSubterm:oldTerm withTerm:newTerm]) {
			return YES;
		}
	}
	NSInteger index = [termList indexOfObject:oldTerm];
	
	if (index != NSNotFound) {
		[self removeTerm:oldTerm];
		[oldTerm setParentTerm:nil];
		[self insertTerm:newTerm atIndex:index];
		[newTerm setParentTerm:self];
		return YES;
	}
	
	return NO;
}

- (NSUInteger) count {
	
	return [termList count];
}

- (NSUInteger) complexity {

	NSUInteger complexity = 0;
	for (int x = 0; x < termList.count; x++) {
		complexity += [(Term *) [termList objectAtIndex:x] complexity];
	}
	return complexity + 1;
}

- (Term *) termAtIndex:(NSUInteger) index {
	
	return (Term *) [termList objectAtIndex:index];
}

- (NSInteger) indexOfTerm: (Term *) term {

	return [termList indexOfObjectIdenticalTo:term];
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	
	[super encodeWithCoder:coder];
	[coder encodeObject:termList forKey:@"termList"];
	
}

- (id) initWithCoder:(NSCoder *)coder { 
	
	// Init first.
	if (self = [super initWithCoder:coder]) {
		
		termList = [[coder decodeObjectForKey:@"termList"] retain];
	}
	
	return self;
}

- (void) setFont: (UIFont *) f {
	
	[super setFont:f];

	// set font for each term in term list
	for (Term *t in termList) {
		[t setFont:f];
	}
}

- (CGFloat) renderingBase {
	
	return renderingBase;
}

- (BOOL) termNeedsParen: (Term *) t {
    
    if ([t isKindOfClass:[Addition class]]) {
        return TRUE;
    }
    if ([t isOpposite] && [t isSimpleTerm] && !([[t parentTerm] isKindOfClass:[ListOperator class]] && [ (ListOperator *) [t parentTerm] indexOfTerm:t] == 0)) {
        return TRUE;
    }
    return [t isKindOfClass:[Power class]] && ![(Power *) t hasParenthesis] && ![[(Power *) t exponent] isSimpleTerm];
}

- (void) renderInView: (UIView *) view atLocation: (CGPoint) loc {
	
	// make the background transparent
	[self setBackgroundColor:[UIColor clearColor]];
		
	// remove all subviews
	for (UIView *v in self.subviews) {
		[v removeFromSuperview];
	}
	
	// render the subviews and get the max height
	CGFloat maxDescender = 0;
	CGFloat	maxRenderingBase = 0;
	for (Term *t in termList) {

		[t renderInView:self atLocation:self.frame.origin];
		maxRenderingBase = MAX(maxRenderingBase, [t renderingBase]);
		maxDescender = MAX(maxDescender, t.frame.size.height - [t renderingBase]);
	}
	
	// arrange subviews
	CGPoint newOriginPoint;
	CGFloat	runningWidth = 0;
	int currentSubTerm = 0;
	for (Term *t in termList) {
		
		// add leading parenthesis if necessary
		if (currentSubTerm == 0) {
			if ([self termNeedsParen:t]) {
				if ([[t parentTerm] isKindOfClass:[Multiplication class]]) {
					
					// create the operator label
					UILabel *operator = [Term createLabelAtX:runningWidth 
														   y:maxRenderingBase - [font ascender]
													   width:[@"(" sizeWithFont:font].width
													  height:[@"(" sizeWithFont:font].height
											 backgroundColor:[UIColor clearColor]
												   fontColor:color
														font:font
													   label:@"("];
					
					// add label and clean up
					[self addSubview:operator];
					runningWidth += [operator frame].size.width;
				}
			}
		}
		
		// add the operator 
		if (currentSubTerm != 0) {
			
			NSString *operatorString;
			
			// create the operator string
			if ([self isKindOfClass:[Addition class]]) {
				
				if ([(Addition *) self getOperatorAtIndex:currentSubTerm] == SUBTRACTION_OPERATOR) {
					
					operatorString = @" - ";
				} else {
					
					operatorString = @" + ";						
				}
				
			} else if ([self isKindOfClass:[Multiplication class]]){
				
				// find the previous term
				Term *previousTerm = [termList objectAtIndex:currentSubTerm - 1];
				
				// if next term is addition or power add opening parenthesis
				if ([self termNeedsParen:t]) {
					
					if (previousTerm && 
						([previousTerm isKindOfClass:[Addition class]] || [self termNeedsParen:previousTerm])) {
						operatorString = @")·(";
					}
					else {
						operatorString = @"·(";
					}
				}
				// if previous term is addition or power add closing parenthesis
				else if (previousTerm && [self termNeedsParen:previousTerm]) {
					operatorString = @")·";
				}
				else {
					operatorString = @"·";
				}
			}
			
			// create the operator label
			UILabel *operator = [Term createLabelAtX:runningWidth 
												   y:maxRenderingBase - [font ascender]
											   width:[operatorString sizeWithFont:font].width
											  height:[operatorString sizeWithFont:font].height
									 backgroundColor:[UIColor clearColor]
										   fontColor:color
												font:font
											   label:operatorString];
			
			// add operator label to term view and clean up
			[self	addSubview:operator];
			runningWidth += [operator frame].size.width;
			
		}
		
		// find the origin of the subview in the parent view
		newOriginPoint.x = runningWidth;
		newOriginPoint.y = maxRenderingBase - [t renderingBase];
		
		// move the subview origin
		[t setFrame:CGRectMake(newOriginPoint.x, newOriginPoint.y, t.frame.size.width, t.frame.size.height)];
		
		// update the running width
		runningWidth += t.frame.size.width;
		
		// add closing parenthesis if necessary
		if ([self isKindOfClass:[Multiplication class]]){
			
			// last term is addition 
			if (currentSubTerm == [termList count] - 1) {
				if ([self termNeedsParen:t]) {
					
					// create the operator label
					UILabel *operator = [Term createLabelAtX:runningWidth 
														   y:maxRenderingBase - [font ascender]
													   width:[@")" sizeWithFont:font].width
													  height:[@")" sizeWithFont:font].height
											 backgroundColor:[UIColor clearColor]
												   fontColor:color
														font:font
													   label:@")"];
					
					// add operator label and clean up
					[self	addSubview:operator];
					runningWidth += [operator frame].size.width;
				}
			}
		}
		
		currentSubTerm++;
		
	}
	
	// set my frame and the rendering base
	[self setFrame:CGRectMake(loc.x, loc.y, runningWidth, maxRenderingBase + maxDescender)];
	[view addSubview:self];
	
	renderingBase = maxRenderingBase;

}

- (BOOL) isEquivalent:(Term *) term {
	
	// make sure were the same type
	if ([self class] == [term class]) {
		
		// cast term to list operator for simplicity
		ListOperator *m = (ListOperator *) term;
		int termCount = [termList count];
		
		if ([term isKindOfClass:[Multiplication class]] && [m count] == termCount) {
			
			// initialize an array to record which terms have been matched
			// 1 = matched, 0 = unmatched
			int match[termCount];
			for (int x = 0; x < termCount; x++) {
				match[x] = 0;
			}
			
			// step through each term in the term list
			for (int x = 0; x < termCount; x++) {
				
				BOOL termMatched = NO;
				
				// try to match an unmatched term in the second term
				for (int y = 0; y < termCount && !termMatched; y++) {
					
					if (!match[y]) {
						if ([[self termAtIndex:x] isEquivalent:[m termAtIndex:y]]) {
							match[y] = 1;
							termMatched = YES;
						}
					}
				}
				
				// We didn't find a match for current term, so we're done
				if (!termMatched) {
					return NO;
				}
			}
			
			// see if all terms where matched
			for (int x = 0; x < termCount; x++) {
				if (!match[x]) {
					return NO;
				}
			}
			
			return YES;
		}
	}
	
	return NO;
}

- (void) setColorRecursively: (UIColor *) c {
	
	[super setColorRecursively:c];
	for (Term *t in termList) {
		[t setColorRecursively:c];
	}
}

- (void) exchangeTerm: (NSUInteger) t1 andTerm: (NSUInteger) t2 {
	
	[termList exchangeObjectAtIndex:t1 withObjectAtIndex:t2];
}

- (void) dealloc {
	
	[termList release];
	[super dealloc];	
}

@end
