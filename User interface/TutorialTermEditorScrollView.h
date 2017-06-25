//
//  TutorialTermEditorScrollView.h
//  TouchAlgebra
//
//  Created by David Sullivan on 8/26/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermEditorScrollView.h"

@class Term;

@interface TutorialTermEditorScrollView : TermEditorScrollView {

	BOOL editEnabled;
	BOOL selectEnabled;
	NSString *selectPath;
}

@property (nonatomic, assign) BOOL editEnabled;
@property (nonatomic, assign) BOOL selectEnabled;
@property (nonatomic, retain) NSString *selectPath;

- (BOOL) selectableTermDidChange: (Term *) t rootSelectPath: (NSString *) path;

@end
