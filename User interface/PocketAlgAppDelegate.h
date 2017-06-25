//
//  PocketAlgAppDelegate.h
//  PocketAlg
//
//  Created by davidsullivan on 10/15/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TermListViewController;
@class IntroNavigationViewController;

@interface PocketAlgAppDelegate : NSObject <UIApplicationDelegate, UIScrollViewDelegate> 

{
    UIWindow						*window;
	TermListViewController			*termListViewController;
	IntroNavigationViewController	*introNavigator;
	
	IBOutlet UINavigationController *mainNavigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
