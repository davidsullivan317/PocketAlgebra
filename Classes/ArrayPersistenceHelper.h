//
//  ArrayPersistenceHelper.h
//  PocketAlg
//
//  Created by davidsullivan on 11/1/11.
//  Copyright 2011 David Sullivan All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrayPersistenceHelper : NSObject

+ (NSMutableArray *) readArrayFromNSUserDefaultsWithKey: (NSString *) key;

+ (void) writeArray: (NSArray *) array ToNSUserDefaultsWithKey: (NSString *) key;

@end
