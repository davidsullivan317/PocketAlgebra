//
//  RealNumber.h
//  TouchAlgebra
//
//  Created by David Sullivan on 6/27/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Number.h"

@interface RealNumber : Number {
	
	double rawValue;

}

// initializers
- (id) initWithFloat:(float) someFloat;
- (id) initWithRealNumber:(RealNumber *) someReal;
- (id) initWithTermValue:(NSString *) someStringValue;

@property (readonly) double rawValue;

@end
