//
//  Constant.h
//  TouchAlgebra
//
//  Created by David Sullivan on 7/7/10.
//  Copyright 2010 David Sullivan. All rights reserved.
//

#import "SymbolicTerm.h"


@interface Constant : SymbolicTerm {

		
}

// math constants
+ (Constant *)		infinity;
+ (Constant *)		pi;

@end
