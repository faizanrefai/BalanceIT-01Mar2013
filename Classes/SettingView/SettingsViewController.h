//
//  SettingsViewController.h
//  StackEM
//
//  Created by YunCholHo on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController {
	UIButton* m_btnMusic;
	UIButton* m_btnSound;
	UIButton* m_btnAccelerator;
	BOOL	 m_bMusic;
}

- (void) initButtons;
- (void) updateButtons;

@end
