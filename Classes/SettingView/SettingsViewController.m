    //
//  SettingsViewController.m
//  StackEM
//
//  Created by YunCholHo on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "StackEMAppDelegate.h"
#import "RootViewController.h"

@implementation SettingsViewController

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
	view.image = [UIImage imageNamed:@"Back_T1.png"];
	self.view = view;
	
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	m_bMusic = appDel.viewController.m_bMusic;
	[self initButtons];
	[self updateButtons];
}

- (void) initButtons {
	UIImage* imgN = [UIImage imageNamed:@"Music On btn.png"];
	CGFloat cx = imgN.size.width * RATE_WIDTH, cy = imgN.size.height * RATE_HEIGHT;
	m_btnMusic = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[m_btnMusic setBackgroundImage:imgN forState:UIControlStateNormal];
	[m_btnMusic addTarget:self action:@selector(onMusic) forControlEvents:UIControlEventTouchUpInside];
	m_btnMusic.center = CGPointMake(SCREEN_WIDTH / 2, 130 * RATE_HEIGHT);
	[self.view addSubview:m_btnMusic];

	imgN = [UIImage imageNamed:@"Sound On btn.png"];
	cx = imgN.size.width * RATE_WIDTH, cy = imgN.size.height * RATE_HEIGHT;
	m_btnSound = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[m_btnSound setBackgroundImage:imgN forState:UIControlStateNormal];
	[m_btnSound addTarget:self action:@selector(onSound) forControlEvents:UIControlEventTouchUpInside];
	m_btnSound.center = CGPointMake(SCREEN_WIDTH / 2, 190 * RATE_HEIGHT);
	[self.view addSubview:m_btnSound];
	
	imgN = [UIImage imageNamed:@"Accelerometer On btn.png"];
	cx = imgN.size.width * RATE_WIDTH, cy = imgN.size.height * RATE_HEIGHT;
	m_btnAccelerator = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[m_btnAccelerator setBackgroundImage:imgN forState:UIControlStateNormal];
	[m_btnAccelerator addTarget:self action:@selector(onAccelerator) forControlEvents:UIControlEventTouchUpInside];
	m_btnAccelerator.center = CGPointMake(SCREEN_WIDTH / 2, 250 * RATE_HEIGHT);
	[self.view addSubview:m_btnAccelerator];
	
	imgN = [UIImage imageNamed:@"Leaderboard btn.png"];
	UIImage* imgD = [UIImage imageNamed:@"Leaderboard Off btn.png"];
	cx = imgN.size.width * RATE_WIDTH, cy = imgN.size.height * RATE_HEIGHT;
	UIButton* btnLeader = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[btnLeader setBackgroundImage:imgN forState:UIControlStateNormal];
	[btnLeader setBackgroundImage:imgD forState:UIControlStateHighlighted];
	[btnLeader addTarget:self action:@selector(onLeaderboard) forControlEvents:UIControlEventTouchUpInside];
	btnLeader.center = CGPointMake(SCREEN_WIDTH / 2, 310 * RATE_HEIGHT);
	[self.view addSubview:btnLeader];
	[btnLeader release];
	
	imgN = [UIImage imageNamed:@"Instructions btn.png"];
	imgD = [UIImage imageNamed:@"Instructions Off btn.png"];
	cx = imgN.size.width * RATE_WIDTH, cy = imgN.size.height * RATE_HEIGHT;
	UIButton* btnInstruction = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[btnInstruction setBackgroundImage:imgN forState:UIControlStateNormal];
	[btnInstruction setBackgroundImage:imgD forState:UIControlStateHighlighted];
	[btnInstruction addTarget:self action:@selector(onInstruction) forControlEvents:UIControlEventTouchUpInside];
	btnInstruction.center = CGPointMake(SCREEN_WIDTH / 2, 370 * RATE_HEIGHT);
	[self.view addSubview:btnInstruction];
	[btnInstruction release];
	
	imgN = [UIImage imageNamed:@"Credits btn.png"];
	imgD = [UIImage imageNamed:@"Credits Off btn.png"];
	cx = imgN.size.width * RATE_WIDTH, cy = imgN.size.height * RATE_HEIGHT;
	UIButton* btnCredits = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[btnCredits setBackgroundImage:imgN forState:UIControlStateNormal];
	[btnCredits setBackgroundImage:imgD forState:UIControlStateHighlighted];
	[btnCredits addTarget:self action:@selector(onCredit) forControlEvents:UIControlEventTouchUpInside];
	btnCredits.center = CGPointMake(SCREEN_WIDTH / 2, 430 * RATE_HEIGHT);
	[self.view addSubview:btnCredits];
	[btnCredits release];
	
	imgN = [UIImage imageNamed:@"Back btn.png"];
	imgD = [UIImage imageNamed:@"Back Off btn.png"];
	cx = imgN.size.width * 0.6 * RATE_WIDTH, cy = imgN.size.height * 0.6 * RATE_HEIGHT;
	UIButton* btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[btnBack setBackgroundImage:imgN forState:UIControlStateNormal];
	[btnBack setBackgroundImage:imgD forState:UIControlStateHighlighted];
	[btnBack addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
	btnBack.center = CGPointMake(10 * RATE_WIDTH + cx / 2, 3 * RATE_HEIGHT + cy / 2);
	[self.view addSubview:btnBack];
	[btnBack release];
}

- (void) updateButtons {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	if (m_bMusic)
		[m_btnMusic setBackgroundImage:[UIImage imageNamed:@"Music On btn.png"] forState:UIControlStateNormal];
	else
		[m_btnMusic setBackgroundImage:[UIImage imageNamed:@"Music Off btn.png"] forState:UIControlStateNormal];
	if (appDel.viewController.m_bSound)
		[m_btnSound setBackgroundImage:[UIImage imageNamed:@"Sound On btn.png"] forState:UIControlStateNormal];
	else
		[m_btnSound setBackgroundImage:[UIImage imageNamed:@"Sound Off btn.png"] forState:UIControlStateNormal];
	if (appDel.viewController.m_bAccelerator)
		[m_btnAccelerator setBackgroundImage:[UIImage imageNamed:@"Accelerometer On btn.png"] forState:UIControlStateNormal];
	else
		[m_btnAccelerator setBackgroundImage:[UIImage imageNamed:@"Accelerometer Off btn.png"] forState:UIControlStateNormal];
}

- (void) onMusic {
	m_bMusic ^= TRUE;
	[self updateButtons];
}

- (void) onSound {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	appDel.viewController.m_bSound ^= TRUE;
	[self updateButtons];
}

- (void) onAccelerator {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	appDel.viewController.m_bAccelerator ^= TRUE;
	[self updateButtons];
}

- (void) onLeaderboard {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
//	[appDel.viewController setGameState:Game_Leader];
	[appDel abrirLDB];
}

- (void) onInstruction {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDel.viewController setGameState:Game_Instruction];
}

- (void) onCredit {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDel.viewController setGameState:Game_Credit];
}

- (void) onBack {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	if (m_bMusic != appDel.viewController.m_bMusic)
	{
		appDel.viewController.m_bMusic = m_bMusic;
		if (m_bMusic)
			[appDel playBackMusic:0];
		else
			[appDel stopBackMusic];
	}
	[appDel.viewController setGameState:Game_Menu];
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
	[m_btnAccelerator release];
	[m_btnMusic release];
	[m_btnSound release];
    [super dealloc];
}


@end
