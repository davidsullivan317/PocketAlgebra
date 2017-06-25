//
//  Spinner.h
//  PocketAlg
//
//  Created by davidsullivan on 11/6/11.
//  Copyright David Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Spinner : UIView 

+(Spinner *)loadSpinnerIntoView:(UIView *)superView;

-(void)removeSpinner;

@end

