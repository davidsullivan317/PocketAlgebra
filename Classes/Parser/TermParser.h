//
//  TermParser.h
//  TouchAlgebra
//
//  Created by David Sullivan on 5/28/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Term;

@interface TermParser : NSObject {

	NSString *errorMessage;

}

@property (nonatomic, retain) NSString *errorMessage;

- (Term *) parseTerm: (NSString *) s;

- (BOOL) parseError;

@end
