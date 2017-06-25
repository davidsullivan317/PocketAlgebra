//
//  Integer.h
//  TouchAlgebra
//
//  Created by David Sullivan on 6/27/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Number.h"

@interface Integer : Number {
	
	NSInteger rawValue;

}

// initializers
- (id) initWithInt:(int) someInt;
- (id) initWithInteger:(Integer *)someInteger;

@property (readonly) NSInteger rawValue;

@end
