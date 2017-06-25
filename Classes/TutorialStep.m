//
//  TutorialStep.m
//  TouchAlgebra
//
//  Created by David Sullivan on 8/6/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TutorialStep.h"
#import "Integer.h"

#define TEXT_KEY				@"Text"
#define EXPRESSION_KEY			@"Expression"
#define SUCCESS_TEXT_KEY		@"SuccessText"
#define SUCCESS_EXPRESSION_KEY	@"SuccessExpression"
#define EDIT_ENABLED_KEY		@"EditEnabled"
#define SELECT_PATH_KEY			@"SelectPath"
#define SELECT_ENABLED_KEY		@"SelectEnabled"

@implementation TutorialStep

@synthesize expression, text, successExpression, successText, editEnabled, selectEnabled, selectPath;

- (id) initWithDictionary: (NSDictionary *) dict {
	
	if (self = [super init]) {
		
		// load the step from the dictionary
		text = [[dict objectForKey:TEXT_KEY] retain];
		expression = [[dict objectForKey:EXPRESSION_KEY] retain];
		successExpression = [[dict objectForKey:SUCCESS_EXPRESSION_KEY] retain];
		successText = [[dict objectForKey:SUCCESS_TEXT_KEY] retain];
		selectEnabled = [[dict objectForKey:SELECT_ENABLED_KEY] boolValue];
		selectPath = [[dict objectForKey:SELECT_PATH_KEY] retain];
		editEnabled = [[dict objectForKey:EDIT_ENABLED_KEY] boolValue];
		
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
	
	[text release];
	[expression release];
	[successText release];
	[successExpression release];
	[successExpression release];
}

@end
