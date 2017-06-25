//
//  TermInputController.h
//  TouchAlgebra
//
//  Created by David Sullivan on 5/13/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermParser.h"

@class Term;

// protocol for calling controller to implement
@protocol TermInputDelegate

- (void) didInputTerm: (Term *) t;

- (BOOL) pushInputController;

@end

@interface TermInputController : UIViewController {

	id <TermInputDelegate> termInputDelegate;
	
	UILabel *inputTextLabel;
	
	BOOL characterButtonPressed;
	

}

- (IBAction) doneButtonPressed;
- (IBAction) clearButtonPressed;
- (IBAction) buttonPressed: (id) sender;

@property (nonatomic, assign) id <TermInputDelegate> termInputDelegate;
@property (nonatomic, assign) IBOutlet UILabel *inputTextLabel;

@end
