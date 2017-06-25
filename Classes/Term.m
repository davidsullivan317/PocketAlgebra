//
//  Term.m
//  TouchAlgebra
//
//  Created by David Sullivan on 6/26/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "Term.h"
#import "Integer.h"
#import "RealNumber.h"
#import "Constant.h"
#import "Variable.h"		
#import "Multiplication.h"
#import "Addition.h"
#import "Power.h"
#import "Fraction.h"
#import "Equation.h"
#import "Summation.h"

// TermView fonts
static UIFont *defaultFont;
static UIFont *defaultExponentFont;

@implementation Term

@synthesize termValue, simpleTerm, parentTerm, isSelected, color, isOpposite;

+ (Term *) lowestCommonParentTerm: (Term *) parent 
						 subTerm1: (Term *) subTerm1 
						 subTerm2: (Term *) subTerm2 {
	
	// path from subTerm1 to parent
	NSMutableArray *subTerm1Array = [NSMutableArray arrayWithCapacity:10];
	Term *tempTerm = subTerm1;
	while ([tempTerm parentTerm]) {
		
		[subTerm1Array addObject:[tempTerm parentTerm]];
		tempTerm = [tempTerm parentTerm];
	}
	
	// path from subterm2 to parent
	NSMutableArray *subTerm2Array = [NSMutableArray arrayWithCapacity:10];
	tempTerm = subTerm2;
	while ([tempTerm parentTerm]) {
		[subTerm2Array addObject:[tempTerm parentTerm]];
		tempTerm = [tempTerm parentTerm];
	}
	
	// find the lowest common parent term
	Term *commonTerm = nil;
	for (Term *t in subTerm1Array) {
		if ([subTerm2Array indexOfObject:t] != NSNotFound) {
			commonTerm = (Term *) t;
			break;
		}
	}
	
	return commonTerm;
}

// initialize and select fonts
+ (void) initializeFonts {
	
	if (!defaultFont) {
		defaultFont		= [[UIFont fontWithName:DEFAULT_TERM_FONT size:DEFAULT_TERM_FONT_SIZE] retain];
	}
	
	if (!defaultExponentFont) {
		defaultExponentFont		= [[UIFont fontWithName:DEFAULT_TERM_FONT size:DEFAULT_TERM_FONT_SIZE/2] retain];
	}
}

// initialize with a string value - this is the designated initializer
- (id) initWithTermValue:(NSString*) someStringValue {

	if (self = [super init]) {
		[self setTermValue:someStringValue];
		simpleTerm = NO;
		parentTerm = nil;
		color = DEFAULT_TERM_COLOR;

		[Term initializeFonts];
		
		[self setDefaultFont];
		
		[self setClipsToBounds:NO];
	}
	
	return self;
}

// default initialization calls designated initializer
- (id) init{
		
	return [self initWithTermValue:@""];
}

// see if two terms are equivalent 
- (BOOL) isEquivalent:(Term *) term {
	
	// By default terms are equal if they are the same type and their string values are the same
	if ([term isMemberOfClass:[self class]]) {
		if ([[term termValue] compare:termValue] == NSOrderedSame) {
			return YES;
		}
	}
	return NO;
}

// Let subterms override as necessary
- (BOOL) isEquivalentIgnoringSign:(Term *) term {
	
	return [self isEquivalent:term];
}

- (NSString *) path {
	
	Term *parent = parentTerm;
	Term *current = self;
	
	NSString *termpath = @"";
	
	// find the root term
	while (parent) {
		if ([parent isKindOfClass:[ListOperator class]]) {
			termpath = [NSString stringWithFormat:@".%i%@", [(Addition *) parent indexOfTerm:current], termpath];
		}
		else if ([parent isKindOfClass:[Fraction class]]) {
			if (current == [(Fraction *) parent numerator]) {
				termpath = [NSString stringWithFormat:@".%i%@", 0, termpath];
			}
			if (current == [(Fraction *) parent denominator]) {
				termpath = [NSString stringWithFormat:@".%i%@", 1, termpath];
			}
		}
		else if ([parent isKindOfClass:[Power class]]) {
			if (current == [(Power *) parent base]) {
				termpath = [NSString stringWithFormat:@".%i%@", 0, termpath];
			}
			if (current == [(Power *) parent exponent]) {
				termpath = [NSString stringWithFormat:@".%i%@", 1, termpath];
			}
		}
		else if ([parent isKindOfClass:[Equation class]]){
			if (current == [(Equation *) parent LHS]) {
				termpath = [NSString stringWithFormat:@".%i%@", 0, termpath];
			}
			if (current == [(Equation *) parent RHS]) {
				termpath = [NSString stringWithFormat:@".%i%@", 1, termpath];
			}
			
		}
		else if ([parent isKindOfClass:[Summation class]]){
			if (current == [(Summation *) parent indexVariable]) {
				termpath = [NSString stringWithFormat:@".%i%@", 0, termpath];
			}
			if (current == [(Summation *) parent lowerBounds]) {
				termpath = [NSString stringWithFormat:@".%i%@", 1, termpath];
			}
			if (current == [(Summation *) parent upperBounds]) {
				termpath = [NSString stringWithFormat:@".%i%@", 2, termpath];
			}
			if (current == [(Summation *) parent expression]) {
				termpath = [NSString stringWithFormat:@".%i%@", 3, termpath];
			}
			
		}
		current = parent;
		parent = [parent parentTerm];
	}
	
	return termpath;

	}

- (Term *) termAtPath: (NSString *) path{
	
	
	// get the path components (note: first term will be empty)
	NSArray *terms = [path componentsSeparatedByString:@"."];
	
	// step down through the term heirachry
	Term *current = self;
	for (int x = 1; x < [terms count]; x++) {
		
		// convert the path component to an integer
		int y = [[terms objectAtIndex:x] integerValue];
		
		if ([current isKindOfClass:[ListOperator class]]) {
			current = [(ListOperator *) current termAtIndex:y];
		}
		else if ([current isKindOfClass:[Fraction class]]) {
			if (y == 0) {
				current = [(Fraction *) current numerator];
			}
			else if (y == 1) {
				current = [(Fraction *) current denominator];
			}
			else {
				return nil;
			}

		}
		else if ([current isKindOfClass:[Power class]]) {
			if (y == 0) {
				current = [(Power *) current base];
			}
			else if (y == 1) {
				current = [(Power *) current exponent];
			}
			else {
				return nil;
			}
		}
		else if ([current isKindOfClass:[Equation class]]) {
			if (y == 0) {
				current = [(Equation *) current LHS];
			}
			else if (y == 1) {
				current = [(Equation *) current RHS];
			}
			else {
				return nil;
			}
		}
		else if ([current isKindOfClass:[Summation class]]) {
			if (y == 0) {
				current = [(Summation *) current indexVariable];
			}
			else if (y == 1) {
				current = [(Summation *) current lowerBounds];
			}
			else if (y == 2) {
				current = [(Summation *) current upperBounds];
			}
			else if (y == 3) {
				current = [(Summation *) current expression];
			}
			else {
				return nil;
			}
		}		
	}
	
	return current;
}

// release instance variables
- (void) dealloc {
	
	[termValue release];
	[super dealloc];
}	

- (NSMutableString *) printStringValue{

	return [[[NSMutableString alloc] initWithString:termValue] autorelease];
}

// is this term a subterm?
-(BOOL) isSubTerm:(Term *) term {
	
	Term *parent = [term parentTerm];
	while (parent) {
		if (parent == self) {
			return YES;
		}
		else {
			parent = [parent parentTerm];
		}

	}	
	return NO;
}

// is this term an immediate subterm?
-(BOOL) isImmediateSubTerm:(Term *) term {
	
	return [term parentTerm] == self;
}

- (BOOL) replaceSubterm: (Term *) oldTerm withTerm: (Term *) newTerm {

	return NO;
}

- (Term *) copyReducingWithSubTerm:(Term *) source andSubTerm:(Term *) target {
	
	return nil;
}


+ (Term *) copyTerm:(Term *) parent 
		  reducingWithSubTerm:(Term *) source 
		   andSubTerm:(Term *) target
{
	// cannot reduce with one's self
	if (source == target) {
		return nil;
	}
	
	// find the lowest common parent term (lcpt)
	Term *lcpt = [self lowestCommonParentTerm:parent subTerm1:source subTerm2:target];
	
	// reduced the lcpt
	Term *newTerm = [[lcpt copyReducingWithSubTerm:source andSubTerm:target] autorelease];

	if (newTerm) {
		
		
		// if parent and lcpt are the same we're done
		if (parent == lcpt) {

			// set the font
			[newTerm setFont:defaultFont];
			
			return [newTerm retain];
		}
		
		// otherwise copy parent term and replace the lcpt with the new term
		else {
			
			Term *newParent = [parent copy];
			NSString *lcptPath = [lcpt path];
			[newParent replaceSubterm:[newParent termAtPath:lcptPath] withTerm:newTerm];

			// set the font
			[newParent setFont:defaultFont];

			return newParent;
		}
	}
	else {
		return nil;
	}
}

- (BOOL) isZero {
	
	// terms are not zero by default
	return NO;
}

- (UIFont *) defaultFont { return defaultFont;}

- (UIFont *) defaultExponentFont{ 
	
	return defaultExponentFont;
}

- (void) setFont: (UIFont *) f {
	
	font = f;
	
}

- (CGFloat) renderingBase {
	
	// by default use the font base
	return [font ascender];
	
}

- (UIFont *) font {
	
	return font;
}

- (void) setDefaultFont {
	
	[self setFont:defaultFont];
}

// find the width of the term string with the current font
- (CGSize) termStringSize {
	
	return [self.termValue sizeWithFont:font];
}

- (void) renderInView: (UIView *) view atLocation: (CGPoint) loc {
	
	// make the background transparent
	[self setBackgroundColor:[UIColor clearColor]];
	
	CGSize termStringSize = self.termStringSize;
	[self setFrame:CGRectMake(loc.x, loc.y, termStringSize.width, termStringSize.height)];
	[view addSubview:self];
	[self setNeedsDisplay];
	
}

- (void) addAllSubviews: (UIView *) v toArray: (NSMutableArray *) array {
	
	// add the view, but not list operators - use only their labels
	if (![v isKindOfClass:[ListOperator class]]) {
		[array addObject:v];
	}
	
	// add all subviews
	for (UIView *subview in [v subviews]) {
		[self addAllSubviews:subview toArray:array];
	}
}

// distance between to points
- (CGFloat) distanceFrom: (CGPoint) p1 to: (CGPoint) p2 {
	
	return sqrtf(powf(p1.x - p2.x, 2) + powf(p1.y - p2.y, 2));
	
}

- (Term *) selectTermAtPoint:(CGPoint) point {
	
#define MAX_TOUCH_DISTANCE 30
	
	// get all of the subviews
	NSMutableArray *allViews = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
	[self addAllSubviews:self toArray:allViews];
	
	// spin through all subviews in the term finding the closest touch point
	UIView  *closestTerm = nil;
	CGFloat  distance, closestTermDistance = self.frame.size.width; // will be larger than any distance
	CGPoint p;
	for (UIView *v in allViews) {
		
		if ([v isKindOfClass:[Term class]]) {
			p = [v convertPoint:[(Term *) v selectPoint] toView:self];
		}
		else {
			p = [[v superview] convertPoint:[v center] toView:self]; // use center for labels
		}
		
		distance = [self distanceFrom:point to:p];
		if (distance < closestTermDistance && distance <= MAX_TOUCH_DISTANCE) {
			closestTerm = v;
			closestTermDistance = distance;
		}
	}
	
	if ([closestTerm isKindOfClass:[Term class]]) {
		return (Term *) closestTerm;
	}
	else {
		return (Term *) [closestTerm superview];
	}
}

-  (CGPoint) selectPoint {
	
	return CGPointMake(self.bounds.origin.x + self.bounds.size.width/2.0, self.bounds.origin.y + self.bounds.size.height/2.0);
	
}

- (void) setColorRecursively: (UIColor *) c {
	
	[self setColor:c];
}

- (Term *) upperMostParentTerm {
	
	// if no parent return self
	Term *p = self;
	while ([p parentTerm]) {
		p = [p parentTerm];
	}
	
	return p;
}

- (void) opposite {
	
	// flip the negative sign
	if (isOpposite) {
		isOpposite = NO;
	}
	else {
		isOpposite = YES;
	}
}

- (NSUInteger) complexity {
	
	return 0;
}

// TODO: each subclass has its own copy - is that the right approach?
- (id) copyWithZone:(NSZone *) zone {
	
	Term *newTerm = [[Term	alloc] initWithTermValue:termValue];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:nil];
	[newTerm setColor:color];
	[newTerm setFont:font];

	return newTerm;
}

- (void)encodeWithCoder:(NSCoder *)coder { 

	[coder encodeObject:termValue forKey:@"termValue"]; 
	[coder encodeObject:parentTerm forKey:@"parentTerm"];
	[coder encodeBool:simpleTerm forKey:@"simpleTerm"];
	[coder encodeObject:color forKey:@"color"];
	[coder encodeObject:font forKey:@"font"];
	[coder encodeBool:isOpposite forKey:@"isNegative"];
		
}

- (id) initWithCoder:(NSCoder *)coder { 

	// Init first.
	if (self = [super init]) {

		termValue  = [[coder decodeObjectForKey:@"termValue"] retain]; 
		parentTerm = [[coder decodeObjectForKey:@"parentTerm"] retain];
		simpleTerm = [coder decodeBoolForKey:@"simpleTerm"];
		color =		 [[coder decodeObjectForKey:@"color"] retain];
		font =		 [[coder decodeObjectForKey:@"font"] retain];
		isOpposite = [coder decodeBoolForKey:@"isNegative"];
	}
	
	return self;
}

// greatest common divisor of two integers
+ (int) gcdX: (int) x Y: (int) y {
	
	// if either is zero no gcd
	if (x == 0 || y == 0) {
		return 0;
	}
	// use absolute values so there are no negative numbers
	int m = abs(x);
	int n = abs(y);
	
	// make sure m >= n
	if (m < n) {
		int t = m;
		m = n;
		n = t;
	}
	
	// use Euclid's algorithm
	int r = m % n;
	if (r == 0) {
		return n;
	} else {
		return [Term gcdX:n Y:r];
	}
}

+ (rootFactorResult) factorRoot: (int) root ofRadicand: (int) radicand {

	// a brute-force method for factoring terms from a root
	// works only for reasonably small numbers 
	// the algorithm finds all the factors of all prime numbers < 100
	// and pulls them outside the radical if possible
	
	#define MAX_PRIME 97

	rootFactorResult result;

	// do some basic bounds checking and handle simple cases
	if (root < 1) {
		result.wasFactored = NO;
		return result;
	}
	else if (radicand == 1) {
		result.wasFactored = YES;
		result.radicandRemainder = 0;
		result.result = radicand;
		return result;
	}
	else if (radicand == 0) {
		result.wasFactored = YES;
		result.radicandRemainder = 0;
		result.result = 0;
		return result;
	}
	
	// Copy the radicand
	int rad = radicand;
	
	// create an array for retaining the found factors
	typedef struct {
		int	factor;
		int count;
	} factor;
	factor factors[MAX_PRIME];
	factors [0].count = 0;	// zero and one are never used
	factors [1].count = 0;

	// divide the factored term by all primes and record each division
	int maxFactor = 0; // largest factor found, not makeup
	for (int x = 2; x <= MAX_PRIME && x < rad; x++) {
		
		int remainder;
		factors [x].factor = x;
		factors [x].count = 0;
		while ((remainder = rad % x) == 0) {
			
			factors[x].count++;
			rad /= x;
			maxFactor = x;
		}
	}	

	// step through the found factors and pull them outside the radical
	int newResult = 1;
	int newRadicandRemainder = radicand;
	result.wasFactored = NO;
	for (int x = 2; x <= maxFactor; x++) {
		
		if (factors[x].count != 0 && factors[x].count >= root){
				
			while (factors[x].count >= root) {
				result.wasFactored = YES;
				factors[x].count -= root;
				newResult *= factors[x].factor;
				newRadicandRemainder /= pow(factors[x].factor, root);
			}
		}
	}
	
	// complete the result and return
	result.result = newResult;
	result.radicandRemainder = newRadicandRemainder;
	return result;
	
}

+ (UILabel *) createLabelAtX: (CGFloat) x
						   y: (CGFloat) y
					   width: (CGFloat) width
					  height: (CGFloat) height
			 backgroundColor: (UIColor *) bc
				   fontColor: (UIColor *) c
						font: (UIFont *) f
					   label: (NSString *) label
{
	
	
	UILabel *newLabel = [[[UILabel alloc] initWithFrame:CGRectMake(x, 
																  y, 
																  width, 
																  height)] autorelease];
	[newLabel setBackgroundColor:bc];
	[newLabel setTextColor:c];
	[newLabel setText:label];
	[newLabel setFont:f];
//    [newLabel setShadowOffset:CGSizeMake(3.0f, 3.0f)];
//    [newLabel setShadowColor:c];
//    newLabel.layer.shadowOpacity = 0.1;
//    newLabel.layer.shadowRadius = 0;
    
	return newLabel;
}


@end
