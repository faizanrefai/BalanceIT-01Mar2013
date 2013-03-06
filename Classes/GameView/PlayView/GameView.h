//
//  GameView.h
//  StackEM
//
//  Created by OCH-Mac on 2/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "BsButton.h"
#import "MyListener.h"
#import "PauseView.h"

#define kTagGameView	123

typedef enum {
	PS_None = 0,
	PS_Balance,
	PS_Select,
} PlayingState;

// GameView Layer
@interface GameView : CCLayer
{
	b2World*	m_pWorld;
	b2Body*		m_pCurBody;
	b2Body*		m_pStick;
	GLESDebugDraw *m_debugDraw;
	
	CCSprite*	m_Background;
	CCSprite*	m_CountBack;
	CCLabelTTF*	m_StackCount;
	
	CCLabelTTF*	m_labTime;
	int			m_nTimeCount;
	
	BsButton*	m_btnPause;
	BOOL		m_bPause;
	PauseView*	m_pPauseView;
	PauseView*	m_pFinishView;
	
	int			m_nItemType;
	int			m_nStackCount;
	
	PlayingState m_nPlayState;
	
	MyListener*	m_pContactListener;
	DestructionListener m_DestructionListener;
	
	CGPoint		m_ptPrev;
	CGPoint		m_ptOrigin;
	CGFloat		m_fAlpha;
	CGFloat		m_fDistX;
	CGFloat		m_fDistY;
	
	BOOL		m_bAceelerometer;
	BOOL		m_bSelected;
    
    BOOL        isOtherBody;
    
    //For Timer
    NSInteger seconds, minutes, hours;
    NSTimer *showTimer;
    CCLabelTTF *show_TimerLbl;
}

// returns a Scene that contains the GameView as the only child
+ (id) scene;
- (void) initContents;
- (void) createWorld;
- (void) createDebugDraw;
- (void) initBoard;
- (void) initStick;
- (void) initContactListener;
- (void) createPauseView;

- (void) initialize;
- (void) uninitialize;

// adds a new sprite at a given coordinate
-(void) addNewSpriteWithCoords;

// set Item Type
- (void) setItemType:(int) nType;

-(void)gameTimerShow;

@end
