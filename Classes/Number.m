//
//  Number.m
//  TouchAlgebra
//
//  Created by David Sullivan on 6/27/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "Number.h"
#import "Term.h"

@implementation Number

// designated initializer
- (id) initWithTermValue:(NSString*) someStringValue {
	
	if (self = [super initWithTermValue:someStringValue]) {
		
		// numbers are simple terms
		simpleTerm = YES;
	}
	
	return self;
	
}

- (BOOL) isOpposite {

	return NO;
}

- (void)drawRect:(CGRect)rect {
	
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadow(context, CGSizeMake(3.0f, 3.0f), 5.0f);
	
	[color set];
	[termValue drawInRect:[self bounds] withFont:font];
}

- (NSUInteger) complexity {
	
	return 1;
}

@end
