    //
//  PlayViewController.m
//  StackEM
//
//  Created by YunCholHo on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"
#import "cocos2d.h"

#import "GameConfig.h"
#import "GameView.h"
#import "StackEMAppDelegate.h"
#import "RootViewController.h"

@implementation PlayViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/
-(BOOL)shouldAutorotate
{
    return NO;
}
- (void)showBannerWithSpecificOrientations {
    CGRect viewRect=self.view.frame;
    CGRect frame=CGRectMake(0,0,viewRect.size.width,viewRect.size.height*0.1f) ;
    [RevMobAds  showBannerAdWithFrame:frame withDelegate:nil  withSpecificOrientations:UIInterfaceOrientationPortrait ,nil];
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	//Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[[UIScreen mainScreen] bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
							preserveBackbuffer:NO];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// To enable Hi-Red mode (iPhone4)
	//[director setContentScaleFactor:2];
	
	//
	//VERY IMPORTANT:
	//If the rotation is going to be controlled by a UIViewController
	//then the device orientation should be "Portrait".
	//
//#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
//#else
//	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
//#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
	[self setView:glView];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// Run the intro Scene
	m_pView = [GameView scene];
	[[CCDirector sharedDirector] runWithScene:m_pView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void) initView {
	GameView* view = (GameView*)[m_pView getChildByTag:kTagGameView];
	[view initialize];
    [self showBannerWithSpecificOrientations];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
//#if GAME_AUTOROTATION == kGameAutorotationUIViewController
//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//	//
//	// Assuming that the main window has the size of the screen
//	// BUG: This won't work if the EAGLView is not fullscreen
//	///
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
//}
//#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewDidAppear:(BOOL)animated
{
   // [self viewDidAppear:animated];
     
}

- (void)dealloc {
    [super dealloc];
}


@end
