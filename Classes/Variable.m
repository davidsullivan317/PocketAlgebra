//
//  Variable.m
//  TouchAlgebra
//
//  Created by David Sullivan on 7/7/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "Variable.h"


@implementation Variable

- (id) copyWithZone:(NSZone *) zone {
	
	Variable *newTerm = [[Variable	alloc] initWithTermValue:termValue];
	[newTerm setSimpleTerm:[self isSimpleTerm]];
	[newTerm setIsOpposite:[self isOpposite]];
	[newTerm setParentTerm:nil];
	[newTerm setColor:color];
	[newTerm setFont:font];
	return newTerm;
}


@end
