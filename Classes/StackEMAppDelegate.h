//
//  StackEMAppDelegate.h
//  StackEM
//
//  Created by OCH-Mac on 2/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterManager.h"
#import "GCViewController.h"
#import <GameKit/GameKit.h>
#import "AppSpecificValues.h"
#import "Global.h"
#import "ChooseViewController.h"
#import <RevMobAds/RevMobAds.h>

@class RootViewController;

@interface StackEMAppDelegate : NSObject <UIApplicationDelegate, GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, GameCenterManagerDelegate,RevMobAdsDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
	
	GameCenterManager*	gameCenterManager;
	IBOutlet GCViewController* gcviewController;
	NSString*			currentLeaderBoard;
	NSString*			totalLeaderBoards[TYPE_COUNT];
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController* viewController;

@property (nonatomic, retain) GameCenterManager* gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;
@property (nonatomic,retain)  NSString* revMobID;
- (void) initLeaderBoardStrings;

// GameCenter
- (void) addOne;
- (void) submitScore;
- (void) showLeaderboard;
- (void) showAchievements;

- (void) abrirLDB;
- (void) abrirACHV;

// sound
- (void) playBackMusic:(int) nIndex;
- (void) stopBackMusic;
- (void) playSound:(int) nIndex;

@end
