//
//  TermListSaveDialogController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 10/4/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocol for calling controller to implement
@protocol TermListSaveDelegate

- (void) didEnterSaveExpressionListName: (NSString *) s;

@end


@interface TermListSaveDialogController : UIViewController <UITextFieldDelegate> {

	IBOutlet UITextField *expressionListNameTextField;
	
	id <TermListSaveDelegate> listSaveDelegate;
	
	NSString *initialExpressionListName;
}

@property (nonatomic, assign) id <TermListSaveDelegate> listSaveDelegate;
@property (nonatomic, retain) IBOutlet UITextField *expressionListNameTextField;
@property (nonatomic, retain) NSString *initialExpressionListName;

@end
