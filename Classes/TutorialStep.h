//
//  TutorialStep.h
//  TouchAlgebra
//
//  Created by David Sullivan on 8/6/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Term;

@interface TutorialStep : NSObject {

	NSString *text;
	NSString *expression;
	NSString *successText;
	NSString *successExpression;
	NSString *selectPath;
	BOOL      editEnabled;
	BOOL      selectEnabled;
	
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *expression;
@property (nonatomic, retain) NSString *successText;
@property (nonatomic, retain) NSString *successExpression;
@property (nonatomic, retain) NSString *selectPath;
@property (nonatomic)         BOOL      editEnabled;
@property (nonatomic)         BOOL      selectEnabled;

- (id) initWithDictionary:(NSDictionary *) dict;

@end
