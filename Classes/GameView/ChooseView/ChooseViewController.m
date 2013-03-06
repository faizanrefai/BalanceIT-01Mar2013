    //
//  ChooseViewController.m
//  StackEM
//
//  Created by YunCholHo on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChooseViewController.h"
#import "StackEMAppDelegate.h"
#import "RootViewController.h"
#import "MKStoreManager.h"

@implementation ChooseViewController

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
	view.image = [UIImage imageNamed:@"Back.png"];
	[self.view addSubview:view];
	
	UILabel* ctrlTitle = [[UILabel alloc] initWithFrame:CGRectMake(10 * RATE_WIDTH, 40 * RATE_HEIGHT, SCREEN_WIDTH - 20 * RATE_WIDTH, 40 * RATE_HEIGHT)];
	ctrlTitle.text = @"Choose One";
	ctrlTitle.backgroundColor = [UIColor clearColor];
	ctrlTitle.textColor = [UIColor yellowColor];
	ctrlTitle.font = [UIFont fontWithName:@"Courier" size:30 * RATE_HEIGHT];
	ctrlTitle.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:ctrlTitle];
	[ctrlTitle release];

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
	
	[self initButtons];
	
	m_pTopView = [[ExplainView alloc] init];
	m_pTopView.center = CGPointMake(m_pTopView.bounds.size.width / 2, -m_pTopView.bounds.size.height / 2);
	[self.view addSubview:m_pTopView];
	m_timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
	m_nTimer = 0;
}

- (void) appearTopView {
	CGContextRef context = UIGraphicsGetCurrentContext();
	m_pTopView.center = CGPointMake(m_pTopView.bounds.size.width / 2, -m_pTopView.bounds.size.height / 2);
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:0.3];
	m_pTopView.center = CGPointMake(m_pTopView.bounds.size.width / 2, m_pTopView.bounds.size.height / 2);
	[UIView setAnimationDelegate:self];
	[UIView commitAnimations];
}

- (void) disappearTopView {
	CGContextRef context = UIGraphicsGetCurrentContext();
	m_pTopView.center = CGPointMake(m_pTopView.bounds.size.width / 2, m_pTopView.bounds.size.height / 2);
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:0.3];
	m_pTopView.center = CGPointMake(m_pTopView.bounds.size.width / 2, -m_pTopView.bounds.size.height / 2);
	[UIView setAnimationDelegate:self];
	[UIView commitAnimations];
}

- (void) onTimer {
	m_nTimer ++;
	if (m_nTimer == 2)
		[self appearTopView];
	else if(m_nTimer == 12)
		[self disappearTopView];
}

- (void) initButtons {
	UIImage* imgBack = [UIImage imageNamed:@"ItemBack.png"];
	CGFloat cx = imgBack.size.width * RATE_WIDTH, cy = imgBack.size.height * RATE_HEIGHT, x, y;
	int i;
	for(i = 0; i < TYPE_COUNT; i++)
	{
		x = 5 * RATE_WIDTH + (cx + 10 * RATE_WIDTH) * (i % 4), y = 120 * RATE_HEIGHT + (cy + 20 * RATE_HEIGHT) * (i / 4);
		m_btnType[i] = [[MyButton alloc] initWithFrame:CGRectMake(x, y, cx, cy)];
		[m_btnType[i] setImages:[NSString stringWithFormat:@"%d_01.png", i + 1] Background:@"ItemBack.png"];
		[m_btnType[i] addTarget:self action:@selector(onTypeSet:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:m_btnType[i]];
		if(i > 1 && [MKStoreManager featureAPurchased] == NO)
		{
			//m_btnType[i].enabled = NO;
			m_btnType[i].alpha = 0.7;
		}
	}
}

- (void) onBack {
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDel.viewController setGameState:Game_Menu];
}

- (void) onTypeSet:(id) sender {
	int i;
	for(i = 0; i < TYPE_COUNT; i++)
		if (m_btnType[i] == sender)
			break;
	
	if(i > 1)
	{
		if([MKStoreManager featureAPurchased] == NO)
		{
			[[MKStoreManager sharedManager] buyFeatureA];
			return;
		}
	}
	
	if (i >= TYPE_COUNT)
		return;
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	appDel.viewController.m_nStickType = i;
	[appDel.viewController setGameState:Game_Play];
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
	[m_pTopView release];
	[m_timer invalidate];
	int i;
	for(i = 0; i < TYPE_COUNT; i++)
		[m_btnType[i] release];
    [super dealloc];
}


@end
