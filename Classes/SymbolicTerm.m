//
//  SymbolicTerm.m
//  TouchAlgebra
//
//  Created by David Sullivan on 7/7/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "SymbolicTerm.h"


@implementation SymbolicTerm

// designated initializer
- (id) initWithTermValue:(NSString*) someStringValue {
	
	if (self = [super initWithTermValue:someStringValue]) {
		
		// symbolic terms are simple terms
		simpleTerm = YES;
	}
	
	return self;
	
}

// override printStringValue to handle negative symbolic terms (-c, etc.)
- (NSMutableString *) printStringValue {
	
	NSMutableString *newString = [[[NSMutableString alloc] initWithString:termValue] autorelease];
	
	if ([self isOpposite]) {
		[newString insertString:@"-" atIndex:0]; 
	}
	return newString;
}

// find the width of the term string with the current font
- (CGSize) termStringSize {
	
	return [[self printStringValue] sizeWithFont:font];

}

- (id) copyWithZone:(NSZone *) zone {
	
	SymbolicTerm *newTerm = [[SymbolicTerm	alloc] initWithTermValue:termValue];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:parentTerm];
	[newTerm setColor:color];
	[newTerm setFont:font];

	return newTerm;
}

// see if two symbolic terms are equivalent 
- (BOOL) isEquivalent:(Term *) term {
	
	if ([super isEquivalent:term] && [(SymbolicTerm *) term isOpposite] == [self isOpposite] ) {
		return YES;
	}
	return NO;
}

- (BOOL) isEquivalentIgnoringSign:(Term *) term {
	
	if ([super isEquivalent:term]) {
		return YES;
	}
	return NO;
}

- (NSUInteger) complexity {
	
	return 1;
}

- (void)drawRect:(CGRect)rect {

	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadow(context, CGSizeMake(3.0f, 3.0f), 5.0f);

	// Set the color
	[color set];
	
	[self.printStringValue drawInRect:[self bounds] withFont:font];
	
}

@end
