    //
//  InstructionViewController.m
//  StackEM
//
//  Created by YunCholHo on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstructionViewController.h"
#import "StackEMAppDelegate.h"
#import "RootViewController.h"

@implementation InstructionViewController

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
	[self.view addSubview:view];
	
	UIImage* imgN = [UIImage imageNamed:@"Back btn.png"];
	UIImage* imgD = [UIImage imageNamed:@"Back Off btn.png"];
	CGFloat cx = imgN.size.width * 0.6 * RATE_WIDTH, cy = imgN.size.height * 0.6 * RATE_HEIGHT;
	UIButton* btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cx, cy)];
	[btnBack setBackgroundImage:imgN forState:UIControlStateNormal];
	[btnBack setBackgroundImage:imgD forState:UIControlStateHighlighted];
	[btnBack addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
	btnBack.center = CGPointMake(10 * RATE_WIDTH + cx / 2, 3 * RATE_HEIGHT + cy / 2);
	[self.view addSubview:btnBack];
	[btnBack release];
	
	[self initContents];
}

- (void) onBack {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDel.viewController setGameState:Game_Settings];
}

- (NSString*) title {
	return @"Instructions";
}

- (NSString*) contents {
	return @"Slide each object from the upper right hand corner of the screen to the middle stacking area on the stick while balancing your current objects. You have 10 sec to place each object and 5 sec to balance the stack between each placement. Stack as many objects as you can. Happy Stacking!!";
}

- (void) initContents {
	UILabel* ctrlTitle = [[UILabel alloc] initWithFrame:CGRectMake(10 * RATE_WIDTH, 100 * RATE_HEIGHT, SCREEN_WIDTH - 20 * RATE_WIDTH, 40 * RATE_HEIGHT)];
	ctrlTitle.text = [self title];
	ctrlTitle.backgroundColor = [UIColor clearColor];
	ctrlTitle.textColor = [UIColor blackColor];
	ctrlTitle.font = [UIFont fontWithName:@"Courier" size:28 * RATE_HEIGHT];
	ctrlTitle.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:ctrlTitle];
	[ctrlTitle release];
	
	UITextView* ctrlContents = [[UITextView alloc] initWithFrame:CGRectMake(10 * RATE_WIDTH, 150 * RATE_HEIGHT, SCREEN_WIDTH - 20 * RATE_WIDTH, SCREEN_HEIGHT - (150 + 10) * RATE_HEIGHT)];
	ctrlContents.text = [self contents];
	ctrlContents.backgroundColor = [UIColor clearColor];
	ctrlContents.textColor = [UIColor yellowColor];
	ctrlContents.textAlignment = UITextAlignmentLeft;
	ctrlContents.font = [UIFont fontWithName:@"Courier" size:18 * RATE_HEIGHT];
	ctrlContents.editable = NO;
	[self.view addSubview:ctrlContents];
	[ctrlContents release];
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
