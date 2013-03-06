    //
//  MenuViewController.m
//  StackEM
//
//  Created by YunCholHo on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuViewController.h"
#import "StackEMAppDelegate.h"
#import "RootViewController.h"

@implementation MenuViewController

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
	view.userInteractionEnabled = YES;
	view.image = [UIImage imageNamed:@"Back_T.png"];
	self.view = view;
	
	[self initButtons];
}

- (void) initButtons {
	UIImage* imgN = [UIImage imageNamed:@"Start Game btn.png"];
	UIImage* imgD = [UIImage imageNamed:@"Start Game Off btn.png"];
	CGFloat cx = imgN.size.width * RATE_WIDTH, cy = imgN.size.height * RATE_HEIGHT;
	UIButton* btnPlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[btnPlay setBackgroundImage:imgN forState:UIControlStateNormal];
	[btnPlay setBackgroundImage:imgD forState:UIControlStateHighlighted];
	[btnPlay addTarget:self action:@selector(onGameStart) forControlEvents:UIControlEventTouchUpInside];
	btnPlay.center = CGPointMake(SCREEN_WIDTH / 2, 200 * RATE_HEIGHT);
	[self.view addSubview:btnPlay];
	[btnPlay release];
	
	imgN = [UIImage imageNamed:@"Settings btn.png"];
	imgD = [UIImage imageNamed:@"Settings Off btn.png"];
	cx = imgN.size.width * RATE_WIDTH, cy = imgN.size.height * RATE_HEIGHT;
	UIButton* btnSettings = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[btnSettings setBackgroundImage:imgN forState:UIControlStateNormal];
	[btnSettings setBackgroundImage:imgD forState:UIControlStateHighlighted];
	[btnSettings addTarget:self action:@selector(onSettings) forControlEvents:UIControlEventTouchUpInside];
	btnSettings.center = CGPointMake(SCREEN_WIDTH / 2, 280 * RATE_HEIGHT);
	[self.view addSubview:btnSettings];
	[btnSettings release];
	
	imgN = [UIImage imageNamed:@"More Games btn.png"];
	imgD = [UIImage imageNamed:@"More Games Off btn.png"];
	cx = imgN.size.width * RATE_WIDTH, cy = imgN.size.height * RATE_HEIGHT;
	UIButton* btnMoreGames = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[btnMoreGames setBackgroundImage:imgN forState:UIControlStateNormal];
	[btnMoreGames setBackgroundImage:imgD forState:UIControlStateHighlighted];
	[btnMoreGames addTarget:self action:@selector(onMoreGames) forControlEvents:UIControlEventTouchUpInside];
	btnMoreGames.center = CGPointMake(SCREEN_WIDTH / 2, 360 * RATE_HEIGHT);
	[self.view addSubview:btnMoreGames];
	[btnMoreGames release];
}

- (void) onGameStart {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDel.viewController setGameState:Game_Choose];
}

- (void) onSettings {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDel.viewController setGameState:Game_Settings];
}

- (void) onMoreGames {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.revolutiongamestoday.com/ipad.php"]];
	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.revolutiongamestoday.com/iphone.php"]];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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


- (void)dealloc {
    [super dealloc];
}


@end
