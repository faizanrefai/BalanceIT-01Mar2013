//
//  RootViewController.h
//  StackEM
//
//  Created by OCH-Mac on 2/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RevMobAds/RevMobAds.h>
typedef enum {
	Game_Logo,
	Game_Menu,
	Game_Choose,
	Game_Play,
	Game_Settings,
	Game_Leader,
	Game_Instruction,
	Game_Credit,
	Game_More,
} Game_State;

enum {
	ANI_None,
	ANI_MoveInL,
	ANI_MoveInR,
	ANI_MoveInT,
	ANI_MoveInB,
	ANI_DisappearToL,
	ANI_DisappearToR,
	ANI_DisappearToT,
	ANI_DisappearToB,
	ANI_SlideInL,
	ANI_SlideInR,
	ANI_SlideInT,
	ANI_SlideInB,
	ANI_FadeWhite,
	Ani_FadeBlack,
};

@class PlayViewController;

@interface RootViewController : UIViewController<RevMobAdsDelegate> {
	Game_State m_nState;
	UIViewController* m_pOldController;
	UIViewController* m_pNewController;
	
	PlayViewController* m_pPlayController;
	
	int		m_nStickType;
	
	// Animation
	CALayer*			m_layerMask;
	
	// Accelerator
	BOOL	m_bAccelerator;
	// Sounds
	BOOL	m_bMusic;
	BOOL	m_bSound;
}

@property(nonatomic) Game_State m_nState;
@property(nonatomic) int  m_nStickType;
@property(nonatomic) BOOL m_bAccelerator;
@property(nonatomic) BOOL m_bMusic;
@property(nonatomic) BOOL m_bSound;
-(void) showAdBanner;
-(void) hideAdBanner;

- (void) setGameState:(Game_State) nState;

// Animation operates
- (void) startTransAnimation:(int) nAniType OldView:(UIView*) oldView NewView:(UIView*) newView;
- (void) stopTransAnimation;
- (void) startFadeAnimation:(int)nAniType OldView:(UIView*) oldView NewView:(UIView*) newView;

@end
