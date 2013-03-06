//
//  StackEMAppDelegate.mm
//  StackEM
//
//  Created by OCH-Mac on 2/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

#import "StackEMAppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"
#import "PlayViewController.h"
#import "SimpleAudioEngine.h"
#import "MKStoreManager.h"

@implementation StackEMAppDelegate

@synthesize window, viewController;
@synthesize gameCenterManager, currentLeaderBoard;
@synthesize  revMobID;
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    
    revMobID=@"507b6dfdd7dd810c00000013";
    [RevMobAds startSessionWithAppID:revMobID];
    
    
    
    
	[MKStoreManager sharedManager];
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
//	[window addSubview:controller.view];
	
	[window makeKeyAndVisible];
	
	[self initLeaderBoardStrings];
	[self playBackMusic:0];

	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] setMultipleTouchEnabled:YES];
}

- (void) initLeaderBoardStrings {
	totalLeaderBoards[0] = kHeaderLeaderboardID;
	totalLeaderBoards[1] = kDiceLeaderboardID;
	totalLeaderBoards[2] = kBlockLeaderboardID;
	totalLeaderBoards[3] = kStickerLeaderboardID;
	totalLeaderBoards[4] = kStoneLeaderboardID;
	totalLeaderBoards[5] = kCupLeaderboardID;
	totalLeaderBoards[6] = kBallLeaderboardID;
	totalLeaderBoards[7] = kWatermelonLeaderboardID;
	totalLeaderBoards[8] = kBreadLeaderboardID;
	totalLeaderBoards[9] = kGolfLeaderboardID;
	totalLeaderBoards[10] = kAppleLeaderboardID;
	totalLeaderBoards[11] = kPorcelainLeaderboardID;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}
 

- (void)applicationDidBecomeActive:(UIApplication *)application {
 
    
	[[CCDirector sharedDirector] resume];
     
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

#pragma mark Action Methods
- (void) initGameCenter {
	if (gcviewController != nil)
		return;
	gcviewController = [GCViewController alloc];
	if ([GameCenterManager isGameCenterAvailable])
	{
		self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate:self];
		[self.gameCenterManager authenticateLocalUser];
	}
}

- (void) addOne {
	[self performSelector:@selector(submitScore) withObject:nil afterDelay:0.2];
}

- (void) submitScore {
	if (g_nStackCount > 0)
	{
		[self initGameCenter];
		self.currentLeaderBoard = totalLeaderBoards[viewController.m_nStickType];
		[self.gameCenterManager reportScore:g_nStackCount forCategory:self.currentLeaderBoard];
	}
}

#pragma mark GameCenter View Controllers

- (void) abrirLDB{
	if([GameCenterManager isGameCenterAvailable])
	{
		[self initGameCenter];
		[gcviewController.view setHidden:YES];
		[self.window addSubview:gcviewController.view];
		[self showLeaderboard];
	}
	else 
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Gamecenter is not available in your iOS version" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
}

- (void) abrirACHV {
	if([GameCenterManager isGameCenterAvailable])
	{
		[self initGameCenter];
		[gcviewController.view setHidden:YES];
//		[self.window addSubview:gcviewController.view];
		[self showAchievements];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Gamecenter is not available in your iOS version" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) showLeaderboard {
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) {
		leaderboardController.category = self.currentLeaderBoard;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self; 
		[gcviewController presentModalViewController: leaderboardController animated: YES];
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
	[viewController dismissModalViewControllerAnimated:YES];
//	[gcviewController.view removeFromSuperview];
//	[gcviewController.view setHidden:YES];
}

- (void) showAchievements {
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL){
		achievements.achievementDelegate = self;
		[gcviewController presentModalViewController: achievements animated: YES];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;{
	[viewController dismissModalViewControllerAnimated: YES];
	//	[gcviewController.view removeFromSuperview];
	//	[gcviewController.view setHidden:YES];
}

- (IBAction) resetAchievements:(id) sender {
	[gameCenterManager resetAchievements];
}

#pragma mark Sound function

- (void) playBackMusic:(int) nIndex {
	if (!viewController.m_bMusic)
		return;
	NSString* strMusic = nil;
	switch (nIndex) {
		case 0:
			strMusic = @"Menu.mp3";
			break;
		case 1:
			strMusic = @"Back.mp3";
			break;
		default:
			return;
	}
	[self stopBackMusic];
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.1f];
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:strMusic];
}

- (void) stopBackMusic {
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

- (void) playSound:(int) nIndex {
	if (!viewController.m_bSound)
		return;
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:0.2f];
	if (nIndex == 0)
		[[SimpleAudioEngine sharedEngine] playEffect:@"collison.wav"];
	else if (nIndex == 1)
		[[SimpleAudioEngine sharedEngine] playEffect:@"BtnClick.wav"];
}

@end
