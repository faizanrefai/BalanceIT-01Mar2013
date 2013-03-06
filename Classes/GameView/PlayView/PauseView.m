//
//  PauseView.m
//  StackEM
//
//  Created by YunCholHo on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PauseView.h"

@interface PauseView()
@end

@implementation PauseView

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PauseView *layer = [PauseView node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// initialize your instance here
-(id) initWithDelegate:(id) delegate ViewType:(View_Type) nType
{
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		if (nType == VT_Pause)
			m_background = [[CCSprite spriteWithFile:@"PauseBack.png"] retain];
		else
			m_background = [[CCSprite spriteWithFile:@"FinishBack.png"] retain];
		[m_background setScale:RATE_WIDTH];
		[m_background setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)];
		[self addChild:m_background];
		
		UIImage* img;
		if (nType == VT_Pause)
		{
			img = [UIImage imageNamed:@"Resume btn.png"];
			m_btnResume = [[BsButton buttonWithImage:@"Resume btn.png" selected:@"Resume Off btn.png" target:delegate selector:@selector(onResume:)] retain];
			[m_btnResume setContentSize:CGSizeMake(img.size.width, img.size.height)];
			[m_btnResume setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 + 15 * RATE_WIDTH)];
			[m_btnResume setAnchorPoint:CGPointMake(0, 0)];
			[m_btnResume setScale:RATE_WIDTH];
			[self addChild:m_btnResume];
		}
		else // nType == VT_Finish
		{
			img = [UIImage imageNamed:@"Retart btn.png"];
			m_btnResume = [[BsButton buttonWithImage:@"Restart btn.png" selected:@"Restart Off btn.png" target:delegate selector:@selector(onRestart:)] retain];
			[m_btnResume setContentSize:CGSizeMake(img.size.width, img.size.height)];
			[m_btnResume setPosition:ccp(SCREEN_WIDTH / 2, 10 + SCREEN_HEIGHT / 2)];
			[m_btnResume setAnchorPoint:CGPointMake(0, 0)];
			[m_btnResume setScale:RATE_WIDTH];
			[self addChild:m_btnResume];
		}
		
		if (nType == VT_Pause)
			m_btnMenu = [[BsButton buttonWithImage:@"Quit btn.png" selected:@"Quit Off btn.png" target:delegate selector:@selector(onQuit:)] retain];
		else
			m_btnMenu = [[BsButton buttonWithImage:@"Quit btn.png" selected:@"Quit Off btn.png" target:delegate selector:@selector(onMenu:)] retain];
		[m_btnMenu setContentSize:CGSizeMake(img.size.width, img.size.height)];
		[m_btnMenu setScale:RATE_WIDTH];
		[m_btnMenu setAnchorPoint:CGPointMake(0, 0)];
		[m_btnMenu setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 50 * RATE_WIDTH)];
		[self addChild:m_btnMenu];
	}
	return self;
}

@end
