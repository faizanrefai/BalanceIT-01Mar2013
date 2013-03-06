//
//  BodyUserData.h
//  StackEM
//
//  Created by YunCholHo on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
	BT_Static,
	BT_Dynamic,
} BodyType;

@interface BodyUserData : NSObject {
	int			mBodyType;
	CCSprite*	mSprite;
}

@property(readonly) int bodyType;
@property(retain) CCSprite* sprite;

- (id) initWithType:(int) nType Sprite:(CCSprite*) sprite;

@end
