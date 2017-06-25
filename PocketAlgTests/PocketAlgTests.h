//
//  PocketAlgTests.h
//  PocketAlgTests
//
//  Created by davidsullivan on 10/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class TermParser;

#import <SenTestingKit/SenTestingKit.h>
@class Integer;
@class Constant;
@class Variable;
@class Multiplication;

@interface PocketAlgTests : SenTestCase {
    
    int testCount;
	
    NSString *resultsString;

	TermParser *parser;

}

@end
