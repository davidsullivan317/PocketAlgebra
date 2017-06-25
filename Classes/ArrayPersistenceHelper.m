//
//  ArrayPersistenceHelper.m
//  PocketAlg
//
//  Created by davidsullivan on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArrayPersistenceHelper.h"

@implementation ArrayPersistenceHelper

+ (NSMutableArray *) readArrayFromNSUserDefaultsWithKey: (NSString *) key {
	
	NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
	
	NSData *data = [currentDefaults objectForKey:key];
	
    if (data) {
        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        return array;
    }
    
    return nil;
}

+ (void) writeArray: (NSArray *) array ToNSUserDefaultsWithKey: (NSString *) key {
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:key];
}

@end
