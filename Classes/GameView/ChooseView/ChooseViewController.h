//
//  ChooseViewController.h
//  StackEM
//
//  Created by YunCholHo on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyButton.h"
#import "ExplainView.h"

#define TYPE_COUNT	12

@interface ChooseViewController : UIViewController {
//	UIButton* m_btnType[TYPE_COUNT];
	MyButton* m_btnType[TYPE_COUNT];
	ExplainView* m_pTopView;
	NSTimer*	m_timer;
	int			m_nTimer;
}

- (void) initButtons;

@end
