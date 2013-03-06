    //
//  LeaderViewController.m
//  StackEM
//
//  Created by YunCholHo on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LeaderViewController.h"
#import "StackEMAppDelegate.h"
#import "RootViewController.h"

@implementation LeaderViewController

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
	[self.view addSubview:view];
	
	UIImage* imgN = [UIImage imageNamed:@"Back btn.png"];
	UIImage* imgD = [UIImage imageNamed:@"Back Off btn.png"];
	CGFloat cx = imgN.size.width * 0.6 * RATE_WIDTH, cy = imgN.size.height * 0.6 * RATE_HEIGHT;
	UIButton* btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[btnBack setBackgroundImage:imgN forState:UIControlStateNormal];
	[btnBack setBackgroundImage:imgD forState:UIControlStateHighlighted];
	[btnBack addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
	btnBack.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - cy);
	[self.view addSubview:btnBack];
	[btnBack release];
}

- (void) onBack {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDel.viewController setGameState:Game_Settings];
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
