//
//  TermListScrollView.h
//  Views
//
//  Created by David Sullivan on 4/16/11.
//  Copyright 2011 David Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Term;

@protocol TermListScrollViewDelegate

- (void) didChangeSelectedTerm: (Term *) selectedTerm;

@end


@interface TermListScrollView : UIScrollView {

	id <TermListScrollViewDelegate> termListScrollViewDelegate;
	
	NSMutableArray	*termList;
	NSMutableArray	*lineNumbers;
	Term			*selectedTerm;

	IBOutlet UIView *backgroundView;
	IBOutlet UILabel *emptyListPrompt;
}

- (void) addTerm: (Term *) t;
- (void) removeTerm:(Term *)t;
- (void) removeAllTerms;
- (void) replaceTerm: (Term *) t1 withTerm: (Term *) t2;

- (void) setSelectedTerm: (Term *) t;
- (void) renderTerms;
- (void) scrollToBottom;

@property (readonly) Term	 *selectedTerm;
@property (nonatomic, retain) NSMutableArray *termList;
@property (nonatomic, assign) id <TermListScrollViewDelegate> termListScrollViewDelegate;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UILabel *emptyListPrompt;

@end
