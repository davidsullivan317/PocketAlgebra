//
//  Integer.m
//  TouchAlgebra
//
//  Created by David Sullivan on 6/27/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "Integer.h"

@implementation Integer

@synthesize rawValue;

// a little helper function to convert integers to a string
- (NSString *) integerToString: (NSInteger) someInt {
	
	return [[[NSString alloc] initWithFormat:@"%d", someInt] autorelease];
}

- (void) setTermValue:(NSString *) intString {

	// convert string to NSInteger. integerValue method will set invalid values to 0
	// so we convert the raw value back to string since we don't know if intString was invalid
	rawValue = [intString integerValue];
	[super setTermValue:[self integerToString:rawValue]];
}		   

- (BOOL) isOpposite {
	
	return rawValue < 0;
	
}

// initialize with a string value - this is the designated initializer
- (id) initWithTermValue:(NSString*) someStringValue {
	
	if (self = [super initWithTermValue:@""]) {
		
		// ensure raw value set 
		[self setTermValue:someStringValue];
	}
	
	return self;
	
}

- (id) initWithInt:(int) someInt {
	
	return [self initWithTermValue:[self integerToString:someInt]];	
}

- (id) initWithInteger:(Integer *)someInteger {
	
	return [self initWithTermValue:[self integerToString:someInteger.rawValue]];	
}

- (id) copyWithZone:(NSZone *) zone {
	
	Integer *newInt = [[Integer alloc] initWithTermValue:termValue];
	[newInt setSimpleTerm:[self isSimpleTerm]];
	[newInt setIsOpposite:[self isOpposite]];
	[newInt setParentTerm:nil];
	[newInt setColor:color];
	[newInt setFont:font];
	
	return newInt;
}

- (void)encodeWithCoder:(NSCoder *)coder { 
	[super encodeWithCoder:coder];
	[coder encodeInt:rawValue forKey:@"intRawValue"];
	
}

- (id) initWithCoder:(NSCoder *)coder { 
	
	// Init first.
	if (self = [super initWithCoder:coder]) {
		
		rawValue = [coder decodeIntForKey:@"intRawValue"];
	}
	
	return self;
}

- (void) opposite {
	
	[self setTermValue:[NSString stringWithFormat:@"%d", rawValue * -1]];
}

- (void) setIsOpposite:(BOOL) neg {
	
	// flip sign if needed
	if ((rawValue < 0 && neg == NO) || (rawValue > 0 && neg == YES)) {
		[self setTermValue:[NSString stringWithFormat:@"%d", rawValue * -1]];
	}
}

- (BOOL) isZero {
	
	return rawValue == 0;
	
}

- (BOOL) isEquivalentIgnoringSign:(Term *) term {
	
	if ([term isMemberOfClass:[self class]]) {
		if (abs(rawValue) == abs([(Integer *)term rawValue])) {
			return YES;
		}
	}
	return NO;
}

@end
