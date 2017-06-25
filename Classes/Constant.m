//
//  Constant.m
//  TouchAlgebra
//
//  Created by David Sullivan on 7/7/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "Constant.h"
#import "RealNumber.h"

@implementation Constant

// a single constant for infinity
Constant	*_infinity;
Constant	*_pi;

- (id) copyWithZone:(NSZone *) zone {
	
	Constant *newTerm = [[Constant	alloc] initWithTermValue:termValue];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:nil];
	[newTerm setColor:color];
	[newTerm setFont:font];
	
	return newTerm;
}

+ (Constant *) infinity {
	
	if (!_infinity) {
		_infinity = [[Constant alloc] initWithTermValue:@"∞"];
	}
	
	return _infinity;
}

+ (Constant *) pi {
	
	if (!_pi) {
		_pi = [[Constant alloc] initWithTermValue:[NSString stringWithFormat:@"%f", M_PI]];
	}
	
	return _pi;
}


@end
