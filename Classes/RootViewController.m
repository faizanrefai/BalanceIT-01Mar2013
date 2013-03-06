//
//  RootViewController.m
//  StackEM
//
//  Created by OCH-Mac on 2/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


#import "RootViewController.h"
#import "StackEMAppDelegate.h"
#import "GameConfig.h"
#import <QuartzCore/QuartzCore.h>

#import "LogoViewController.h"
#import "MenuViewController.h"
#import "SettingsViewController.h"
#import "ChooseViewController.h"
#import "PlayViewController.h"
#import "LeaderViewController.h"
#import "InstructionViewController.h"
#import "CreditViewController.h"

#define REVMOB_ID @"507b6dfdd7dd810c00000013"

@implementation RootViewController

@synthesize m_nState, m_nStickType, m_bAccelerator, m_bMusic, m_bSound;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
- (void)startSession {
    [RevMobAds startSessionWithAppID:REVMOB_ID testingMode:RevMobAdsTestingModeOff];
}

- (void)testingWithAds {
    [RevMobAds startSessionWithAppID:REVMOB_ID testingMode:RevMobAdsTestingModeWithAds];
}

- (void)testingWithoutAds {
    [RevMobAds startSessionWithAppID:REVMOB_ID testingMode:RevMobAdsTestingModeWithoutAds];
}

- (void)showFullscreen {
    //    RevMobAds *revmob = [RevMobAds revMobAds];
    //    [revmob showFullscreen];
    [RevMobAds showFullscreenAd];
}

- (void)showFullscreenWithDelegate {
    [RevMobAds showFullscreenAdWithDelegate:self];
}

- (void)showFullscreenWithSpecificOrientations {
    [RevMobAds showFullscreenAdWithDelegate:self
                   withSpecificOrientations:UIInterfaceOrientationLandscapeRight, UIInterfaceOrientationLandscapeLeft, nil];
    
}

- (void)loadFullscreen {
    [RevMobAds loadFullscreenAd];
}

- (void)isLoadedFullscreen {
    NSLog(@"[RevMob Sample App] loaded = %i", [RevMobAds isLoadedFullscreenAd]);
}

- (void)releaseFullscreen {
    [RevMobAds releaseFullscreenAd];
}

- (void)showBanner {
    //    RevMobAds *revmob = [RevMobAds revMobAds];
    //    [revmob showBanner];
    [RevMobAds showBannerAdWithDelegate:self];
}

- (void)showBannerWithCustomFrame {
    [RevMobAds showBannerAdWithFrame:CGRectMake(10, 20, 200, 40) withDelegate:self];
}

- (void)showBannerWithSpecificOrientations {
    [RevMobAds showBannerAdWithDelegate:self withSpecificOrientations:UIInterfaceOrientationLandscapeRight, UIInterfaceOrientationLandscapeLeft, nil];
}

- (void)hideBanner {
    //    RevMobAds *revmob = [RevMobAds revMobAds];
    //    [revmob hideBanner];
    [RevMobAds hideBannerAd];
}

- (void)deactivateBanner {
    [RevMobAds deactivateBannerAd];
}

- (void)openAdLink {
    RevMobAds *revmob = [RevMobAds revMobAds];
    [revmob openAdLinkWithDelegate:self];
}

-(void) showAdBanner
{
    CGRect viewRect=self.view.frame;
    CGRect frame=CGRectMake(0,0,viewRect.size.width,viewRect.size.height*0.2f) ;
    [RevMobAds  showBannerAdWithFrame:frame withDelegate:nil  withSpecificOrientations:UIInterfaceOrientationLandscapeLeft ,nil];
}
-(void) hideAdBanner
{
    [RevMobAds hideBannerAd];
}
- (LogoViewController*) loadLogoViewController {
	return [LogoViewController alloc];
}

- (MenuViewController*) loadMenuViewController {
	return [MenuViewController alloc];
}

- (SettingsViewController*) loadSettingViewController {
	return [SettingsViewController alloc];
}

- (ChooseViewController*) loadChooseViewController {
	return [ChooseViewController alloc];
}

- (PlayViewController*) loadPlayViewController {
	return [PlayViewController alloc];
}

- (LeaderViewController*) loadLeaderViewController {
	return [LeaderViewController alloc];
}

- (InstructionViewController*) loadInstructionViewController {
	return [InstructionViewController alloc];
}

- (CreditViewController*) loadCreditViewController {
	return [CreditViewController alloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
      [self showFullscreen];
	m_bMusic = TRUE;
	m_bSound = TRUE;
	m_bAccelerator = FALSE;
	
	m_pNewController = [self loadLogoViewController];
	m_pPlayController = [[self loadPlayViewController] initWithNibName:nil bundle:nil];
	[self.view addSubview:m_pPlayController.view];
	[self.view addSubview:m_pNewController.view];
	m_nState = Game_Logo;
	m_nStickType = 0;
  
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	
	//
	// There are 2 ways to support auto-rotation:
	//  - The OpenGL / cocos2d way
	//     - Faster, but doesn't rotate the UIKit objects
	//  - The ViewController way
	//    - A bit slower, but the UiKit objects are placed in the right place
	//
	
#if GAME_AUTOROTATION==kGameAutorotationNone
	//
	// EAGLView won't be autorotated
	//
	return NO;
	
#elif GAME_AUTOROTATION==kGameAutorotationCCDirector
	//
	// EAGLView will be rotated by cocos2d
	//
	// Sample: Autorotate only in landscape mode
	//
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
	} else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
	}
	
	return NO;

#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
	//
	// EAGLView will be rotated by the UIViewController
	//
	// Sample: Autorotate only in landscpe mode
	//
	// return YES for the supported orientations
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	   interfaceOrientation == UIInterfaceOrientationLandscapeRight )
		return YES;
	
	// Unsupported orientations:
	// UIInterfaceOrientationPortrait, UIInterfaceOrientationPortraitUpsideDown
	return NO;
	
#else
#error Unknown value in GAME_AUTOROTATION
	
#endif // GAME_AUTOROTATION

	
	// Shold not happen
	return NO;
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//
	// Assuming that the main window has the size of the screen
	// BUG: This won't work if the EAGLView is not fullscreen
	///
//	CGRect screenRect = [[UIScreen mainScreen] bounds];
//	CGRect rect;
//
//	if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)		
//		rect = screenRect;
//			
//	else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
//		rect.size = CGSizeMake( screenRect.size.height, screenRect.size.width );
//	
//	CCDirector *director = [CCDirector sharedDirector];
//	EAGLView *glView = [director openGLView];
//	float contentScaleFactor = [director contentScaleFactor];
//	
//	if( contentScaleFactor != 1 ) {
//		rect.size.width *= contentScaleFactor;
//		rect.size.height *= contentScaleFactor;
//	}
//	glView.frame = rect;
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[m_pPlayController release];
	[m_pNewController release];
    [super dealloc];
}

- (void) setGameState:(Game_State) nState {
	if (m_nState == nState)
		return;
	
	m_pOldController = m_pNewController;
	int nAniType = Ani_FadeBlack;
	switch (nState) {
		case Game_Logo:
			break;
		case Game_Menu:
			m_pNewController = [self loadMenuViewController];
			break;
		case Game_Choose:
			m_pNewController = [self loadChooseViewController];
			break;
		case Game_Play:
			m_pNewController = m_pPlayController;//[self loadPlayViewController];
			[m_pPlayController initView];
			break;
		case Game_Settings:
			m_pNewController = [self loadSettingViewController];
			break;
		case Game_Leader:
			m_pNewController = [self loadLeaderViewController];
			break;
		case Game_Instruction:
			m_pNewController = [self loadInstructionViewController];
			break;
		case Game_Credit:
			m_pNewController = [self loadCreditViewController];
			break;
		default:
			return;
	}
	m_nState = nState;
	if (nAniType == ANI_FadeWhite || nAniType == Ani_FadeBlack)
		[self startFadeAnimation:nAniType OldView:m_pOldController.view NewView:m_pNewController.view];
	else
		[self startTransAnimation:nAniType OldView:m_pOldController.view NewView:m_pNewController.view];
}

- (void) startTransAnimation:(int) nAniType OldView:(UIView*) oldView NewView:(UIView*) newView {
	// perform the fade out or fade in
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self.view addSubview:newView];
	
	CGRect newFrame = newView.frame;
	CGRect oldFrame = oldView.frame;
	switch (nAniType)
	{
		case ANI_MoveInL:
			newFrame.origin.x = -newFrame.size.width;
			newFrame.origin.y = 0;
			break;
		case ANI_MoveInR:
			newFrame.origin.x = newFrame.size.width;
			newFrame.origin.y = 0;
			break;
		case ANI_MoveInT:
			newFrame.origin.x = 0;
			newFrame.origin.y = -newFrame.size.height;
			break;
		case ANI_MoveInB:
			newFrame.origin.x = 0;
			newFrame.origin.y = newFrame.size.height;
			break;
		case ANI_DisappearToL:
		case ANI_DisappearToR:
		case ANI_DisappearToT:
		case ANI_DisappearToB:
			[self.view bringSubviewToFront:oldView];
			newFrame.origin.x = 0;
			newFrame.origin.y = 0;
			oldFrame.origin.x = 0;
			oldFrame.origin.y = 0;
			break;
		case ANI_SlideInL:
			newFrame.origin.x = -newFrame.size.width;
			newFrame.origin.y = 0;
			oldFrame.origin.x = 0;
			oldFrame.origin.y = 0;
			break;
		case ANI_SlideInR:
			newFrame.origin.x = newFrame.size.width;
			newFrame.origin.y = 0;
			oldFrame.origin.x = 0;
			oldFrame.origin.y = 0;
			break;
		case ANI_SlideInT:
			newFrame.origin.x = 0;
			newFrame.origin.y = -newFrame.size.height;
			oldFrame.origin.x = 0;
			oldFrame.origin.y = 0;
			break;
		case ANI_SlideInB:
			newFrame.origin.x = 0;
			newFrame.origin.y = newFrame.size.height;
			oldFrame.origin.x = 0;
			oldFrame.origin.y = 0;
			break;
		default:
			return;
	}
	newView.frame = newFrame;
	oldView.frame = oldFrame;
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:0.5];
	switch (nAniType)
	{
		case ANI_MoveInL:
		case ANI_MoveInR:
		case ANI_MoveInT:
		case ANI_MoveInB:
			newFrame.origin.x = 0;
			newFrame.origin.y = 0;
			break;
		case ANI_DisappearToL:
			oldFrame.origin.x = -oldFrame.size.width;
			oldFrame.origin.y = 0;
			break;
		case ANI_DisappearToR:
			oldFrame.origin.x = oldFrame.size.width;
			oldFrame.origin.y = 0;
			break;
		case ANI_DisappearToT:
			oldFrame.origin.x = 0;
			oldFrame.origin.y = -oldFrame.size.height;
			break;
		case ANI_DisappearToB:
			oldFrame.origin.x = 0;
			oldFrame.origin.y = oldFrame.size.height;
			break;
		case ANI_SlideInL:
			newFrame.origin.x = 0;
			newFrame.origin.y = 0;
			oldFrame.origin.x = oldFrame.size.width;
			oldFrame.origin.y = 0;
			break;
		case ANI_SlideInR:
			newFrame.origin.x = 0;
			newFrame.origin.y = 0;
			oldFrame.origin.x = -oldFrame.size.width;
			oldFrame.origin.y = 0;
			break;
		case ANI_SlideInT:
			newFrame.origin.x = 0;
			newFrame.origin.y = 0;
			oldFrame.origin.x = 0;
			oldFrame.origin.y = oldFrame.size.height;
			break;
		case ANI_SlideInB:
			newFrame.origin.x = 0;
			newFrame.origin.y = 0;
			oldFrame.origin.x = 0;
			oldFrame.origin.y = -oldFrame.size.height;
			break;
		default:
			return;
	}
	newView.frame = newFrame;
	oldView.frame = oldFrame;
	
	[UIView setAnimationDidStopSelector:@selector(stopTransAnimation)];
	[UIView setAnimationDelegate:self];
	[UIView commitAnimations];
}

- (void) stopTransAnimation {
	[m_pOldController.view removeFromSuperview];
	[m_pOldController release];
}

- (void) startFadeAnimation:(int)nAniType OldView:(UIView *)oldView NewView:(UIView *)newView {
	m_layerMask = [[CALayer alloc] init];
	oldView.userInteractionEnabled = NO;
	
	StackEMAppDelegate* appDelegate = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDelegate.window.layer addSublayer:m_layerMask]; 
	if (nAniType == ANI_FadeWhite)
		m_layerMask.backgroundColor = [UIColor whiteColor].CGColor;
	else if (nAniType == Ani_FadeBlack)
		m_layerMask.backgroundColor = [UIColor blackColor].CGColor;
	m_layerMask.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
	m_layerMask.position = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
	m_layerMask.zPosition = 500;
	
	CABasicAnimation* pulseAnimation = [CABasicAnimation animation];
	[pulseAnimation setValue: @"opacity" forKey: @"name"];
	pulseAnimation.keyPath = @"opacity";
	pulseAnimation.fromValue = [NSNumber numberWithFloat: 0];
	pulseAnimation.toValue = [NSNumber numberWithFloat: 1];
	pulseAnimation.delegate = self;
	pulseAnimation.duration = 0.5f;
	pulseAnimation.fillMode = kCAFillModeForwards;
	pulseAnimation.removedOnCompletion = NO;
	
	[m_layerMask addAnimation:pulseAnimation forKey: @"animateOpacity"];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	NSString* str = [anim valueForKey: @"name"];
	if ([str isEqual: @"opacity"]) {	
		[m_layerMask removeAllAnimations];		 
		
		CABasicAnimation* pulseAnimation1 = [CABasicAnimation animation];
		[pulseAnimation1 setValue: @"opacity1" forKey: @"name"];
		pulseAnimation1.keyPath = @"opacity";
		pulseAnimation1.fromValue = [NSNumber numberWithFloat: 1.0];
		pulseAnimation1.toValue = [NSNumber numberWithFloat: 0.0];
		pulseAnimation1.delegate = self;
		pulseAnimation1.duration = .4f;
		pulseAnimation1.fillMode = kCAFillModeForwards;
		pulseAnimation1.removedOnCompletion = NO;
		
		if (m_pNewController != m_pPlayController)
			[self.view addSubview: m_pNewController.view];
		m_pNewController.view.userInteractionEnabled = NO;
		if (m_pOldController != m_pPlayController)
		{
			[m_pOldController.view removeFromSuperview];
			[m_pOldController release];
		}
		
		StackEMAppDelegate* appDelegate = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
		[appDelegate.window.layer addSublayer: m_layerMask]; 	
		[m_layerMask addAnimation:pulseAnimation1 forKey: @"animateOpacity1"];
	} else if ([str isEqual: @"opacity1"]) {
		[m_layerMask removeAllAnimations];		 
		[m_layerMask removeFromSuperlayer];
		[m_layerMask release];
		m_pNewController.view.userInteractionEnabled = YES;
	}
}

@end
