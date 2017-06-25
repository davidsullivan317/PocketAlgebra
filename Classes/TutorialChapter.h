//
//  TutorialChapter.h
//  TouchAlgebra
//
//  Created by David Sullivan on 8/12/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TutorialChapter : NSObject {

	NSString	   *title;
	NSMutableArray *steps;
}

- (id) initWithDictionary: (NSDictionary *) dict;

+ (NSMutableArray *) allChapters;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *steps;

@end
