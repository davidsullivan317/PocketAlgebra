//
//  RealNumber.m
//  TouchAlgebra
//
//  Created by David Sullivan on 6/27/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "RealNumber.h"

@implementation RealNumber

@synthesize rawValue;

// a little helper function to convert floating point numbers to a string
- (NSString *) floatToString: (float) someFloat {
	
    // TODO: potential memory leak
	return [[NSString alloc] initWithFormat:@"%f", someFloat];
}

- (void) setTermValue:(NSString *) floatString {

	// convert string to float. integerValue method will set invalid values to 0
	// so we convert the raw value back to string since we don't know if intString was invalid
	rawValue = [floatString floatValue];
	[super setTermValue:[self floatToString:rawValue]];
}		   

- (BOOL) isOpposite {
	
	return rawValue < 0;
	
}

- (id) initWithTermValue:(NSString*) someStringValue  {
	
	if (self = [super initWithTermValue:someStringValue]) {
		
		[self setTermValue:someStringValue];
	}
	
	return self;
}

- (id) initWithFloat:(float) someFloat {
	
	return [self initWithTermValue:[self floatToString:someFloat]];
	
}

- (id) initWithRealNumber:(RealNumber *) someReal{
	
	return [self initWithTermValue:[self floatToString:someReal.rawValue]];
	
}

- (id) copyWithZone:(NSZone *) zone {
	
	RealNumber *newReal = [[RealNumber	alloc] initWithTermValue:termValue];
	[newReal setSimpleTerm:[self isSimpleTerm]];
	[newReal setIsOpposite:[self isOpposite]];
	[newReal setParentTerm:nil];
	[newReal setColor:color];
	[newReal setFont:font];
	
	return newReal;
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	
	[super encodeWithCoder:coder];
	[coder encodeFloat:rawValue forKey:@"realRawValue"];
}

- (id) initWithCoder:(NSCoder *)coder { 
	
	// Init first.
	if (self = [super initWithCoder:coder]) {
		
		rawValue = [coder decodeFloatForKey:@"realRawValue"];
	}
	
	return self;
}

- (void) opposite {
	
	// multiply by -1
	[self setTermValue:[NSString stringWithFormat:@"%f", rawValue * -1]];
}

- (BOOL) isZero {
	
	return rawValue == 0;
	
}

- (BOOL) isEquivalentIgnoringSign:(Term *) term {
	
	if ([term isMemberOfClass:[self class]]) {
		if (fabs(rawValue) == fabs([(RealNumber *)term rawValue])) {
			return YES;
		}
	}
	return NO;
}


@end
