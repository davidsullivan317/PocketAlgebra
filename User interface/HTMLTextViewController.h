//
//  HelpTextViewController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 9/26/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HTMLTextViewController : UIViewController <UIWebViewDelegate>{

	IBOutlet UIWebView *webView;
	NSString *fileName;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *fileName;
@end
