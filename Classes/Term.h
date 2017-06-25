//
//  Term.h
//  TouchAlgebra
//
//  Created by David Sullivan on 6/26/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

// term font and color constants
#define DEFAULT_TERM_FONT @"Helvetica"
#define DEFAULT_TERM_FONT_SIZE 60.0
#define DEFAULT_TERM_COLOR [UIColor blackColor]
#define LIST_SELECTED_TERM_COLOR [UIColor blueColor]
#define EDIT_SELECTED_TERM_COLOR [UIColor redColor]

// max number of terms and subterms allowed
#define MAX_EXPRESSION_COMPLEXITY 30

// the largest integer allowed
#define MAX_INTEGER 999999999

// used for finding the roots of radicals
typedef struct {
	BOOL	wasFactored;
	int		radicandRemainder;
	int		result;
} rootFactorResult;

@interface Term : UIView <NSCopying, NSCoding> {
	
	NSString* termValue;	// a symbolic string for the term: 1, 2.3, pi, sin, c, x, etc.
	BOOL simpleTerm;		// term does not consist of subterms
	Term *parentTerm;		// parent term if a subterm, otherwise nil
	
	// Font and color - we violate MVC design pattern for simplicity
	UIFont *font;
	UIColor *color;

	BOOL  isOpposite;	// flag for indicating if term is opposite (-pi, c in a - (-c), etc.)

}

// reduce 
+ (Term *) copyTerm:(Term *) parent 
		  reducingWithSubTerm:(Term *) source 
		   andSubTerm:(Term *) target;

// handy functions for finding primes, the greatest common divisor of two ints, etc.
+ (int) gcdX: (int) x Y: (int) y;
+ (rootFactorResult) factorRoot: (int) root ofRadicand: (int) radicand;

// designated initializer - initialize with a string
- (id) initWithTermValue:(NSString *)someStringValue;

// is this term equivalent to a second term?
- (BOOL) isEquivalent:(Term *) term;
- (BOOL) isEquivalentIgnoringSign:(Term *) term;

// is this term a subterm?
-(BOOL) isSubTerm:(Term *) term;
-(BOOL) isImmediateSubTerm: (Term *) term;

// replace a subterm. Returns YES if the old term was found and replaced
- (BOOL) replaceSubterm: (Term *) oldTerm withTerm: (Term *) newTerm;

// a pointer agnostic path through the term "tree" to a particular term
// the root term is ""
// E.g. in 4/(1 + 3) the path to the fraction is "", the path to 3 is .1.1
- (NSString *) path;

// given the path, find the term
- (Term *) termAtPath: (NSString *) path;

// the highest parent term in the term "tree"
- (Term *) upperMostParentTerm;

// is this term zero?
- (BOOL) isZero;

// opposite of the term (e.g. multiply by -1)
- (void) opposite;

// total number of terms and subterms
- (NSUInteger) complexity;

//  A string represenation of the term. Caller must retain returned string.
// E.g. -c, 1 + n, x^2, etc.
- (NSMutableString *) printStringValue;

// select term font
- (void) setDefaultFont;
- (UIFont *) font;

// render the term in a view
- (void) renderInView: (UIView *) view atLocation: (CGPoint) loc;

// first the subterm selected at the given point
- (Term *) selectTermAtPoint:(CGPoint) point;

// hotspots properties
@property (nonatomic, readonly) CGPoint selectPoint;

// other properties
@property (readwrite, copy) NSString* termValue;
@property (nonatomic, getter=isSimpleTerm) BOOL simpleTerm;
@property (nonatomic, assign) Term *parentTerm;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, assign) UIColor *color;
@property (nonatomic) BOOL isOpposite;


// set the color property for this term and all subterms
- (void) setColorRecursively: (UIColor *) c;

// these methods should be protected, which objective C doesn't support
- (void) setFont: (UIFont *) f;
- (CGFloat) renderingBase; // the base of the term when rendered
- (UIFont *) defaultFont;
- (UIFont *) defaultExponentFont;
- (CGSize) termStringSize;

+ (UILabel *) createLabelAtX: (CGFloat) x
						   y: (CGFloat) y
					   width: (CGFloat) width
					  height: (CGFloat) height
			 backgroundColor: (UIColor *) bc
				   fontColor: (UIColor *) c
						font: (UIFont *) f
					   label: (NSString *) label;

@end
