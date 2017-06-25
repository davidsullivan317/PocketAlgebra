//
//  TutorialChapter.m
//  TouchAlgebra
//
//  Created by David Sullivan on 8/12/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import "TutorialChapter.h"
#import "TutorialStep.h"

#define TITLE_KEY @"ChapterTitle"
#define STEPS_ARRAY_KEY @"Steps"

#define TUTORIAL_TEXT_FILE @"Tutorial"
#define TUTORIAL_TEXT_FILE_SUFFIX @"plist"

@implementation TutorialChapter

@synthesize title, steps;

+ (NSMutableArray *) allChapters {
	
	// get property list from main bundle
	NSString *	plistPath = [[NSBundle mainBundle] pathForResource:TUTORIAL_TEXT_FILE ofType:TUTORIAL_TEXT_FILE_SUFFIX];
	
	// read property list into memory as an NSData object
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	
	// convert static property list into dictionary object
	NSDictionary *data = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML 
																		  mutabilityOption:NSPropertyListMutableContainersAndLeaves 
																					format:&format 
																		  errorDescription:&errorDesc];
	if (data) {
		
		// create the chapters array and return
		NSMutableArray *array = [NSMutableArray arrayWithArray:[data objectForKey:@"Chapters"]];
		NSMutableArray *chapters = [[[NSMutableArray alloc] initWithCapacity:[array count]] autorelease];
		for (int x = 0; x < [array count]; x++){
					
			TutorialChapter *tc = [[[TutorialChapter alloc] initWithDictionary:(NSDictionary *) [array objectAtIndex:x]] autorelease];
			[chapters addObject:tc];
		}		
		
		return chapters;
	}
	
	return nil;
}

- (id) initWithDictionary: (NSDictionary *) dict {
	
	if (self = [super init]) {
		
		// load the title from the dictionary
		title = [[dict objectForKey:TITLE_KEY] retain];
		
		// create the steps array
		NSMutableArray *temp = [NSMutableArray arrayWithArray:[dict objectForKey:STEPS_ARRAY_KEY]];
		steps = [[[NSMutableArray alloc] initWithCapacity:[temp count]] retain];
		for (NSDictionary *d in temp) {
			
			[steps addObject:[[[TutorialStep alloc] initWithDictionary:d] autorelease]];
		}

	}

	return self;
}

- (void) dealloc {
	
	[super dealloc];
	[title release];
	[steps release];
}
@end
