//
//  PauseView.h
//  StackEM
//
//  Created by YunCholHo on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BsButton.h"

typedef enum {
	VT_Pause,
	VT_Finish,
} View_Type;

@interface PauseView : CCLayer {
	CCSprite* m_background;
	BsButton* m_btnResume;
	BsButton* m_btnMenu;
}

+ (id) scene;
- (id) initWithDelegate:(id) delegate ViewType:(View_Type) nType;

@end
