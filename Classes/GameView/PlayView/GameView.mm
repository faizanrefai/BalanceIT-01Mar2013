//
//  GameView.mm
//  StackEM
//
//  Created by OCH-Mac on 2/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "GameView.h"
#import "StackEMAppDelegate.h"
#import "RootViewController.h"
#import "BodyUserData.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
	kTagLabelStack = 1,
};

@interface GameView()
- (void) initButtons;
- (void) initLabels;
- (void) updateTimer;
- (void) onFinish;
- (void) calcStackCount;
- (void) drawStackCount;
- (void) moveStack:(CGPoint)ptPrev Second:(CGPoint)ptCur;
- (void) rotateStack:(CGPoint)ptPrev Second:(CGPoint)ptCur;
- (BOOL) ptInBody:(b2Body *)body Point:(CGPoint)pt;
@end


// GameView implementation
@implementation GameView

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameView *layer = [GameView node];
	
	// add layer as a child to scene
	[scene addChild:layer z:0 tag:kTagGameView];
	
	// return the scene
	return scene;
}

// initialize your instance here
-(id) init
{
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		// background and pause button
		[self initContents];
		[self initLabels];
		
		[self schedule: @selector(tick:)];
		m_pCurBody = nil;

		[self createPauseView];
        

	}
	return self;
}


#pragma mark Initialize
-(void)initialize 
{
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	m_bAceelerometer = appDel.viewController.m_bAccelerator;
	[m_StackCount setVisible:YES];
	[m_btnPause setVisible:YES];
	// create buttons
	[self initButtons];
	// create world
	[self createWorld];
	// create debug draw
//	[self createDebugDraw];
	// create listener and set
	[self initContactListener];
	// init boundary body
	[self initBoard];
	// Set up Sticker
	[self initStick];
	
	m_nStackCount = 0;
	m_nPlayState = PS_None;
	// game timer
	m_nTimeCount = 3;
	[self schedule:@selector(onGameTimer:) interval:1];
	[self drawStackCount];
	[appDel playBackMusic:1];
	[self setItemType:appDel.viewController.m_nStickType];
    
    seconds = 0;
    minutes = 0;
    hours = 0;
    
//    [self removeChild:show_TimerLbl cleanup:YES];
//    show_TimerLbl = [CCLabelTTF labelWithString:@"00:00:00" fontName:@"Verdana" fontSize:26];
//    show_TimerLbl.position = ccp(115, 140);
//    [self addChild:show_TimerLbl z:5];
//    [self gameTimerShow];
}

#pragma mark Game Timer Show
-(void)gameTimerShow
{
    showTimer = [[NSTimer alloc] init];
    showTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeUpdateShow) userInfo:nil repeats:YES];
}
#pragma mark
#pragma mark NSTimer
-(void)timeUpdateShow
{
    seconds++;
    if (seconds == 60)
    {
        minutes++;
        seconds = 0;
        if (minutes == 60)
        {
            hours++;
            minutes = 0;
            seconds = 0;
        }
    }
    NSString *strValue = [NSString stringWithFormat:@"%02i:%02i:%02i",hours, minutes, seconds];
    [self removeChild:show_TimerLbl cleanup:YES];
    
    show_TimerLbl = [CCLabelTTF labelWithString:strValue fontName:@"Verdana" fontSize:26];
    show_TimerLbl.position = ccp(115, 140);
    [self addChild:show_TimerLbl z:5];

//    NSLog(@"Hour : %02i ** Minutes : %02i ** Seconds : %02i",hours, minutes, seconds);
}

- (void) uninitialize {
	[self unschedule:@selector(onGameTimer:)];
	[m_StackCount setVisible:NO];
	[m_btnPause setVisible:NO];
	for (b2Body* b = m_pWorld->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			BodyUserData* data = (BodyUserData*)b->GetUserData();
			CCSprite *myActor = data.sprite;
			[self removeChild:myActor cleanup:YES];
			[data release];
		}
	}
	delete m_pContactListener;
	delete m_pWorld;
	m_pWorld = NULL;
	m_pCurBody = NULL;
	[(StackEMAppDelegate*) [UIApplication sharedApplication].delegate playBackMusic:0];
}

#pragma mark ON Game Timer
-(void)onGameTimer:(id) sender 
{
	m_nTimeCount --;
	if (m_nTimeCount < 0)
	{
		if (m_nPlayState != PS_Select)
		{
			m_nTimeCount = 5;
			m_nPlayState = PS_Select;
			if (!m_bAceelerometer)
				m_pWorld->SetGravity(b2Vec2(0, 0.0f));
			[self addNewSpriteWithCoords];
		}
		else if (m_nPlayState != PS_Balance)
		{
			m_nTimeCount = 3;
			m_nPlayState = PS_Balance;
			if (!m_bAceelerometer)
			{
				m_pWorld->SetGravity(b2Vec2(0, -1.5f));
				m_pCurBody->SetLinearVelocity(b2Vec2(0, -0.5f));
			}
		}
	}
	
	for (b2Body* b = m_pWorld->GetBodyList(); b; b = b->GetNext())
	{
        if(b == m_pCurBody)
            continue;
	}
    
//	if (m_nPlayState == PS_Balance && m_nTimeCount == 0)
	[self calcStackCount];
	[self updateTimer];
}

- (void) updateTimer {
//    if(m_nPlayState != PS_Balance)
        [m_labTime setString:[NSString stringWithFormat:@"%d", m_nTimeCount]];
//    else
//        [m_labTime setString:[NSString stringWithFormat:@""]];
}

#pragma mark
#pragma mark Create World
-(void)createWorld
{
	// Define the gravity vector.
	b2Vec2 gravity;
	if (m_bAceelerometer)
		gravity.Set(0.0f, -0.15f);
	else
		gravity.Set(0.0f, -0.0f);
	
	// Do we want to let bodies sleep?
	// This will speed up the physics simulation
	bool doSleep = true;
	
	// Construct a world object, which will hold and simulate the rigid bodies.
	m_pWorld = new b2World(gravity, doSleep);
	m_pWorld->SetContinuousPhysics(true);
}


-(void)createDebugDraw 
{
	// Debug Draw functions
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	m_pWorld->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
//	flags += b2DebugDraw::e_shapeBit;
//	flags += b2DebugDraw::e_jointBit;
//	flags += b2DebugDraw::e_aabbBit;
//	flags += b2DebugDraw::e_pairBit;
//	flags += b2DebugDraw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
}

#pragma mark
#pragma mark In it Methods
- (void)initContents 
{
	// background
	m_Background = [[CCSprite spriteWithFile:@"Back.png"] retain];
	[m_Background setScale:RATE_WIDTH];
	[m_Background setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)];
	
	m_CountBack = [[CCSprite spriteWithFile:@"CountBack.png"] retain];
	[m_CountBack setScale:RATE_WIDTH];
	[m_CountBack setPosition:ccp(45 * RATE_WIDTH, 30 * RATE_WIDTH)];
}

-(void)initLabels 
{
	m_StackCount = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_nStackCount] dimensions:CGSizeMake(65 * RATE_WIDTH, 34 * RATE_WIDTH) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:26 * RATE_WIDTH];
	m_StackCount.position = ccp(45 * RATE_WIDTH, 28 * RATE_WIDTH);
	[self addChild:m_StackCount];
	
	m_labTime = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(65 * RATE_WIDTH, 34 * RATE_WIDTH) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:30 * RATE_WIDTH];
	m_labTime.position = ccp(SCREEN_WIDTH - 45 * RATE_WIDTH, 28 * RATE_WIDTH);
	[self addChild:m_labTime];
}

-(void)initButtons 
{
	m_bPause = FALSE;
	// pause button
	UIImage* img = [UIImage imageNamed:@"Pause btn.png"];
	m_btnPause = [[BsButton buttonWithImage:@"Pause btn.png" selected:@"Pause Off btn.png" target:self selector:@selector(onPause:)] retain];
	[m_btnPause setContentSize:CGSizeMake(img.size.width, img.size.height)];
	[m_btnPause setScale:(0.6 * RATE_WIDTH)];
	[m_btnPause setAnchorPoint:CGPointMake(0, 0)];
	[m_btnPause setPosition:ccp((img.size.width / 2 + 5) * RATE_WIDTH, SCREEN_HEIGHT - (img.size.height / 2) * RATE_WIDTH - 50)];
	[self addChild:m_btnPause];
}

-(void)initBoard 
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = m_pWorld->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2PolygonShape groundBox;		
	
	// bottom
//	groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
//	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void)initStick 
{
	CCSprite *sprite = [CCSprite spriteWithFile:@"Stick.png"];
	[sprite setScale:RATE_HEIGHT];
	[self addChild:sprite];
	CGPoint p = CGPointMake(SCREEN_WIDTH / 2, 10 * RATE_WIDTH);
	sprite.position = ccp( p.x, p.y);
	
	BodyUserData* data = [[BodyUserData alloc] initWithType:BT_Static Sprite:sprite];
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p.x / PTM_RATIO, p.y / PTM_RATIO);
	bodyDef.userData = data;
	b2Body *body = m_pWorld->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(sprite.contentSize.width * RATE_WIDTH1 / PTM_RATIO, sprite.contentSize.height * RATE_HEIGHT1 / PTM_RATIO);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	fixtureDef.restitution = 0.0f;
	body->CreateFixture(&fixtureDef);
    
    m_pStick = body;
}

- (void) initContactListener {
	m_pContactListener = new MyListener;
	m_pWorld->SetContactListener(m_pContactListener);
	m_pWorld->SetDestructionListener(&m_DestructionListener);
}

- (void) createPauseView {
	m_pPauseView = [[[PauseView alloc] initWithDelegate:self ViewType:VT_Pause] retain];
	[m_pPauseView setVisible:NO];
	m_pFinishView = [[[PauseView alloc] initWithDelegate:self ViewType:VT_Finish] retain];
	[m_pFinishView setVisible:NO];
}

#pragma  mark 
#pragma mark On Method
-(void) onPause:(id) sender 
{
    [showTimer invalidate];
    
	if (m_bPause)
		return;
	m_bPause = TRUE;
	[self addChild:m_pPauseView z:1];
	[m_pPauseView setVisible:YES];
	[self pauseSchedulerAndActions];
}

-(void) onResume:(id) sender 
{
//    [self gameTimerShow];
    
	[self removeChild:m_pPauseView cleanup:YES];
	[m_pPauseView setVisible:NO];
	m_bPause = FALSE;
	[self resumeSchedulerAndActions];
}

-(void) onFinish {
	m_bPause = TRUE;
	[self pauseSchedulerAndActions];
	[self addChild:m_pFinishView z:1];
	[m_pFinishView setVisible:YES];
}

-(void) onRestart:(id) sender {
	[self removeChild:m_pFinishView cleanup:YES];
	[m_pPauseView setVisible:NO];
	[self resumeSchedulerAndActions];
	[self uninitialize];
	[self initialize];
	m_bPause = FALSE;
}

- (void) onMenu:(id) sender {
	[self removeChild:m_pPauseView cleanup:YES];
	[self removeChild:m_pFinishView cleanup:YES];
	[m_pPauseView setVisible:NO];
	[m_pFinishView setVisible:NO];
	[self resumeSchedulerAndActions];
	[self uninitialize];
	m_bPause = FALSE;
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDel.viewController setGameState:Game_Menu];
}

- (void) onQuit:(id) sender {
	[self removeChild:m_pPauseView cleanup:YES];
	[self removeChild:m_pFinishView cleanup:YES];
	[m_pPauseView setVisible:NO];
	[m_pFinishView setVisible:NO];
	[self resumeSchedulerAndActions];
	[self uninitialize];
	m_bPause = FALSE;
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDel.viewController setGameState:Game_Choose];
}

- (void) onGameEnd {
	[self unschedule:@selector(tick:)];
}

- (void) drawStackCount {
	[m_StackCount setString:[NSString stringWithFormat:@"%d", m_nStackCount]];
}

#pragma mark
#pragma mark Draw
-(void) draw
{
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	if (appDel.viewController.m_nState != Game_Play)
		return;
	// draw background
	[m_Background visit];
	
	[m_CountBack visit];
	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	m_pWorld->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

#pragma mark New Sprite With Coords
-(void) addNewSpriteWithCoords
{
	CGPoint pt = CGPointMake(SCREEN_WIDTH - 50 * RATE_WIDTH, SCREEN_HEIGHT - 100 * RATE_WIDTH);
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int num = ((int)(CCRANDOM_0_1() * 10)) % 6;
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	int nType = appDel.viewController.m_nStickType;
	CCSprite *sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%d_%02d.png", nType + 1, num + 1]];
	[sprite setScale:RATE_WIDTH1];
	[self addChild:sprite];
	
	sprite.position = ccp(pt.x, pt.y);
	
	BodyUserData* data = [[BodyUserData alloc] initWithType:BT_Dynamic Sprite:sprite];
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(pt.x / PTM_RATIO, pt.y / PTM_RATIO);
	bodyDef.userData = data;
	b2Body *body = m_pWorld->CreateBody(&bodyDef);
	
	CGFloat rate = RATE_WIDTH1 / PTM_RATIO;
	CGFloat w1 = sprite.contentSize.width / 2;
	CGFloat h1 = sprite.contentSize.height / 2;
	CGFloat a = sprite.contentSize.width / 2 * rate; // width of sprite
	CGFloat b = sprite.contentSize.height / 2 * rate; // height of sprite
	int nVert = 0;
	b2Vec2 vertex[24];
	switch (nType) {
		case 0:
			{
				switch (num) {
					case 0:
					{
						vertex[0].Set((60.0f - w1) * rate, (h1 - 79.0f) * rate);
						vertex[1].Set((74.0f - w1) * rate, (h1 - 46.0f) * rate);
						vertex[2].Set((71.0f - w1) * rate, (h1 - 18.0f) * rate);
						vertex[3].Set((64.0f - w1) * rate, (h1 - 7.0f) * rate);
						vertex[4].Set((49.0f - w1) * rate, (h1 - 0.0f) * rate);
						vertex[5].Set((30.0f - w1) * rate, (h1 - 0.0f) * rate);
						vertex[6].Set((18.0f - w1) * rate, (h1 - 6.0f) * rate);
						vertex[7].Set((10.0f - w1) * rate, (h1 - 18.0f) * rate);
						vertex[8].Set((7.0f - w1) * rate, (h1 - 47.0f) * rate);
						vertex[9].Set((21.0f - w1) * rate, (h1 - 79.0f) * rate);
						nVert = 10;
						b2PolygonShape box1;
						box1.Set(vertex, nVert);
						b2FixtureDef fixtureDef1;
						fixtureDef1.shape = &box1;	
						fixtureDef1.density = 2.0f;
						fixtureDef1.friction = 0.2f;
						fixtureDef1.restitution = 0.0f;
						body->CreateFixture(&fixtureDef1);
						
						vertex[0].Set((60.0f - w1) * rate, (h1 - 79.0f) * rate);
						vertex[1].Set((21.0f - w1) * rate, (h1 - 79.0f) * rate);
						vertex[2].Set(-a, -b);
						vertex[3].Set(a, -b);
						nVert = 4;
						break;
					}
					case 1:
					case 4:
					{
						vertex[0].Set((67.0f - w1) * rate, -b);
						vertex[1].Set(a, (h1 - 68.0f) * rate);
						vertex[2].Set(a, (h1 - 54.0f) * rate);
						vertex[3].Set((72.0f - w1) * rate, (h1 - 17.0f) * rate);
						vertex[4].Set((62.0f - w1) * rate, (h1 - 9.0f) * rate);
						vertex[5].Set((46.0f - w1) * rate, b);
						vertex[6].Set((34.0f - w1) * rate, b);
						vertex[7].Set((15.0f - w1) * rate, (h1 - 9.0f) * rate);
						vertex[8].Set((6.0f - w1) * rate, (h1 - 17.0f) * rate);
						vertex[9].Set(-a, (h1 - 55.0f) * rate);
						vertex[10].Set(-a, (h1 - 67.0f) * rate);
						vertex[11].Set((11.0f - w1) * rate, -b);
						nVert = 12;
						break;
					}
					case 2:
						vertex[0].Set((44 - w1) * rate, -b);
						vertex[1].Set((77 - w1) * rate, (h1 - 50) * rate);
						vertex[2].Set(a, (h1 - 40) * rate);
						vertex[3].Set((51 - w1) * rate, (h1 - 3) * rate);
						vertex[4].Set((45 - w1) * rate, b);
						vertex[5].Set((35 - w1) * rate, b);
						vertex[6].Set((28 - w1) * rate, (h1 - 4) * rate);
						vertex[7].Set(-a, (h1 - 39) * rate);
						vertex[8].Set((2 - w1) * rate, (h1 - 49) * rate);
						vertex[9].Set((36 - w1) * rate, -b);
						nVert = 10;
						break;
					case 3:
					case 5:
					{
						vertex[0].Set((75.0f - w1) * rate, (h1 - 95.0f) * rate);
						vertex[1].Set(a, (h1 - 91.0f) * rate);
						vertex[2].Set(a, (h1 - 60.0f) * rate);
						vertex[3].Set((72.0f - w1) * rate, (h1 - 17.0f) * rate);
						vertex[4].Set((51.0f - w1) * rate, b);
						vertex[5].Set((29.0f - w1) * rate, b);
						vertex[6].Set((7.0f - w1) * rate, (h1 - 17.0f) * rate);
						vertex[7].Set(-a, (h1 - 60.0f) * rate);
						vertex[8].Set(-a, (h1 - 91.0f) * rate);
						vertex[9].Set((5.0f - w1) * rate, (h1 - 95.0f) * rate);
						nVert = 10;
						b2PolygonShape box1;
						box1.Set(vertex, nVert);
						b2FixtureDef fixtureDef1;
						fixtureDef1.shape = &box1;	
						fixtureDef1.density = 2.0f;
						fixtureDef1.friction = 0.2f;
						fixtureDef1.restitution = 0.0f;
						body->CreateFixture(&fixtureDef1);
						vertex[0].Set((63.0f - w1) * rate, -b);
						vertex[1].Set((63.0f - w1) * rate, (h1 - 95.0f) * rate);
						vertex[2].Set((16.0f - w1) * rate, (h1 - 95.0f) * rate);
						vertex[3].Set((16.0f - w1) * rate, -b);
						nVert = 4;
						break;
					}
				}
				b2PolygonShape box;
				box.Set(vertex, nVert);
				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &box;	
				fixtureDef.density = 2.0f;
				fixtureDef.friction = 0.2f;
				fixtureDef.restitution = 0.0f;
				body->CreateFixture(&fixtureDef);
			}
			break;
		case 1:
		case 2:
		case 3:
			{
				// Define another box shape for our dynamic body.
				b2PolygonShape box;
				box.SetAsBox(a, b);//These are mid points for our 1m box

				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &box;	
				fixtureDef.density = 2.0f;
				fixtureDef.friction = 0.2f;
				fixtureDef.restitution = 0.0f;
				body->CreateFixture(&fixtureDef);
			}
			break;
		case 4:
			{
				switch (num) {
					case 0:
					case 1:
					case 2:
					case 3:
					case 4:
						for(nVert = 0; nVert < 24; nVert++)
						{
							CGFloat alpha = (float)nVert * (float)15 / float(180) * b2_pi;
							float32 x = (a * a * cosf(alpha)) / sqrt((a * a * cosf(alpha) * cosf(alpha)) + (b * b * sinf(alpha) * sinf(alpha)));
							float32 y = (b * b * sinf(alpha)) / sqrt((a * a * cosf(alpha) * cosf(alpha)) + (b * b * sinf(alpha) * sinf(alpha)));
							vertex[nVert].Set(x, y);
						}
						break;
					case 5:
						vertex[0].Set(a, (h1 - 15) * rate);
						vertex[1].Set((66 - w1) * rate, (h1 - 8) * rate);
						vertex[2].Set((44 - w1) * rate, (h1 - 3) * rate);
						vertex[3].Set((30 - w1) * rate, b);
						vertex[4].Set((15 - w1) * rate, b);
						vertex[5].Set((6 - w1) * rate, (h1 - 2) * rate);
						vertex[6].Set((1 - w1) * rate, (h1 - 6) * rate);
						vertex[7].Set(-a, (h1 - 9) * rate);
						vertex[8].Set(-a, (h1 - 14) * rate);
						vertex[9].Set((7 - w1) * rate, (h1 - 21) * rate);
						vertex[10].Set((16 - w1) * rate, -b);
						vertex[11].Set((37 - w1) * rate, -b);
						vertex[12].Set((60 - w1) * rate, (h1 - 22) * rate);
						vertex[13].Set((74 - w1) * rate, (h1 - 19) * rate);
						vertex[14].Set(a, (h1 - 16) * rate);
						nVert = 15;
						break;
				}
				b2PolygonShape box;
				box.Set(vertex, nVert);
				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &box;	
				fixtureDef.density = 2.0f;
				fixtureDef.friction = 0.2f;
				fixtureDef.restitution = 0.0f;
				body->CreateFixture(&fixtureDef);
			}
			break;
		case 5:
			{
				switch (num) {
					case 0:
					case 1:
					{
						vertex[0].Set((58 - w1) * rate, (h1 - 71) * rate);
						vertex[1].Set((68 - w1) * rate, (h1 - 69) * rate);
						vertex[2].Set((73 - w1) * rate, (h1 - 65) * rate);
						vertex[3].Set(a, (h1 - 47) * rate);
						vertex[4].Set(a, (h1 - 32) * rate);
						vertex[5].Set((74 - w1) * rate, (h1 - 19) * rate);
						vertex[6].Set((68 - w1) * rate, (h1 - 13) * rate);
						vertex[7].Set((58 - w1) * rate, (h1 - 12) * rate);
						nVert = 8;
						b2PolygonShape box1;
						box1.Set(vertex, nVert);
						b2FixtureDef fixtureDef1;
						fixtureDef1.shape = &box1;	
						fixtureDef1.density = 5.0f;
						fixtureDef1.friction = 0.2f;
						fixtureDef1.restitution = 0.0f;
						body->CreateFixture(&fixtureDef1);
						
						vertex[0].Set((58 - w1) * rate, b);
						vertex[1].Set((52 - w1) * rate, b);
						vertex[2].Set((52 - w1) * rate, -b);
						vertex[3].Set((58 - w1) * rate, -b);
						nVert = 4;
						b2PolygonShape box2;
						box2.Set(vertex, nVert);
						b2FixtureDef fixtureDef2;
						fixtureDef2.shape = &box2;	
						fixtureDef2.density = 5.0f;
						fixtureDef2.friction = 0.2f;
						fixtureDef2.restitution = 0.0f;
						body->CreateFixture(&fixtureDef2);

						vertex[0].Set((6 - w1) * rate, -b);
						vertex[1].Set((6 - w1) * rate, b);
						vertex[2].Set(-a, b);
						vertex[3].Set(-a, -b);
						b2PolygonShape box3;
						box3.Set(vertex, nVert);
						b2FixtureDef fixtureDef3;
						fixtureDef3.shape = &box3;	
						fixtureDef3.density = 5.0f;
						fixtureDef3.friction = 0.2f;
						fixtureDef3.restitution = 0.0f;
						body->CreateFixture(&fixtureDef3);
						
						vertex[0].Set((52 - w1) * rate, -b);
						vertex[1].Set((52 - w1) * rate, (h1 - 15) * rate);
						vertex[2].Set((6 - w1) * rate, (h1 - 15) * rate);
						vertex[3].Set((6 - w1) * rate, -b);
						nVert = 4;
						break;
					}
					case 2:
					case 3:
					{
						vertex[0].Set((20 - w1) * rate, (h1 - 8) * rate);
						vertex[1].Set((9 - w1) * rate, (h1 - 9) * rate);
						vertex[2].Set(-a, (h1 - 16) * rate);
						vertex[3].Set(-a, (h1 - 26) * rate);
						vertex[4].Set((9 - w1) * rate, (h1 - 32) * rate);
						vertex[5].Set((20 - w1) * rate, (h1 - 34) * rate);
						nVert = 6;
						b2PolygonShape box2;
						box2.Set(vertex, nVert);
						b2FixtureDef fixtureDef2;
						fixtureDef2.shape = &box2;	
						fixtureDef2.density = 5.0f;
						fixtureDef2.friction = 0.2f;
						fixtureDef2.restitution = 0.0f;
						body->CreateFixture(&fixtureDef2);
						
						vertex[0].Set((22 - w1) * rate, (h1 - 42) * rate);
						vertex[1].Set((30 - w1) * rate, -b);
						vertex[2].Set((70 - w1) * rate, -b);
						vertex[3].Set((77 - w1) * rate, (h1 - 42) * rate);
						nVert = 4;
						b2PolygonShape box3;
						box3.Set(vertex, nVert);
						b2FixtureDef fixtureDef3;
						fixtureDef3.shape = &box3;	
						fixtureDef3.density = 5.0f;
						fixtureDef3.friction = 0.2f;
						fixtureDef3.restitution = 0.0f;
						body->CreateFixture(&fixtureDef3);
						
						vertex[0].Set((20 - w1) * rate, (h1 - 40) * rate);
						vertex[1].Set((22 - w1) * rate, (h1 - 42) * rate);
						vertex[2].Set((77 - w1) * rate, (h1 - 42) * rate);
						vertex[3].Set(a, (h1 - 40) * rate);
						nVert = 4;
						b2PolygonShape box1;
						box1.Set(vertex, nVert);
						b2FixtureDef fixtureDef1;
						fixtureDef1.shape = &box1;	
						fixtureDef1.density = 5.0f;
						fixtureDef1.friction = 0.2f;
						fixtureDef1.restitution = 0.0f;
						body->CreateFixture(&fixtureDef1);
						
						vertex[0].Set((20 - w1) * rate, b);
						vertex[1].Set((20 - w1) * rate, (h1 - 15) * rate);
						vertex[2].Set((26 - w1) * rate, (h1 - 15) * rate);
						vertex[3].Set((26 - w1) * rate, b);
						nVert = 4;
						b2PolygonShape box4;
						box4.Set(vertex, nVert);
						b2FixtureDef fixtureDef4;
						fixtureDef4.shape = &box4;	
						fixtureDef4.density = 5.0f;
						fixtureDef4.friction = 0.2f;
						fixtureDef4.restitution = 0.0f;
						body->CreateFixture(&fixtureDef4);
						
						vertex[0].Set((74 - w1) * rate, b);
						vertex[1].Set((74 - w1) * rate, (h1 - 15) * rate);
						vertex[2].Set(a, (h1 - 15) * rate);
						vertex[3].Set(a, b);
						nVert = 4;
						break;
					}
					case 4:
					case 5:
					{
						vertex[0].Set((60 - w1) * rate, (h1 - 55) * rate);
						vertex[1].Set(a, (h1 - 30) * rate);
						vertex[2].Set(a, (h1 - 12) * rate);
						vertex[3].Set((73 - w1) * rate, (h1 - 6) * rate);
						vertex[4].Set((60 - w1) * rate, (h1 - 6) * rate);
						nVert = 5;
						b2PolygonShape box1;
						box1.Set(vertex, nVert);
						b2FixtureDef fixtureDef1;
						fixtureDef1.shape = &box1;	
						fixtureDef1.density = 5.0f;
						fixtureDef1.friction = 0.2f;
						fixtureDef1.restitution = 0.0f;
						body->CreateFixture(&fixtureDef1);

						vertex[0].Set((60 - w1) * rate, b);
						vertex[1].Set((54 - w1) * rate, b);
						vertex[2].Set((54 - w1) * rate, -b);
						vertex[3].Set((60 - w1) * rate, -b);
						nVert = 4;
						b2PolygonShape box2;
						box2.Set(vertex, nVert);
						b2FixtureDef fixtureDef2;
						fixtureDef2.shape = &box2;	
						fixtureDef2.density = 5.0f;
						fixtureDef2.friction = 0.2f;
						fixtureDef2.restitution = 0.0f;
						body->CreateFixture(&fixtureDef2);
						
						vertex[0].Set((6 - w1) * rate, -b);
						vertex[1].Set((6 - w1) * rate, b);
						vertex[2].Set(-a, b);
						vertex[3].Set(-a, -b);
						b2PolygonShape box3;
						box3.Set(vertex, nVert);
						b2FixtureDef fixtureDef3;
						fixtureDef3.shape = &box3;	
						fixtureDef3.density = 5.0f;
						fixtureDef3.friction = 0.2f;
						fixtureDef3.restitution = 0.0f;
						body->CreateFixture(&fixtureDef3);
						
						vertex[0].Set((6 - w1) * rate, (h1 - 15) * rate);
						vertex[1].Set((6 - w1) * rate, -b);
						vertex[2].Set((54 - w1) * rate, -b);
						vertex[3].Set((54 - w1) * rate, (h1 - 15) * rate);
						nVert = 4;
						break;
					}
				}
				b2PolygonShape box;
				box.Set(vertex, nVert);
				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &box;	
				fixtureDef.density = 5.0f;
				fixtureDef.friction = 0.2f;
				fixtureDef.restitution = 0.0f;
				body->CreateFixture(&fixtureDef);
			}
			break;
		case 6:
			{
				if (num == 1)
				{ // ellipse
					b2Vec2 vertex[24];
					for(nVert = 0; nVert < 24; nVert++)
					{
						CGFloat alpha = (float)nVert * (float)15 / float(180) * b2_pi;
						float32 x = (a * a * cosf(alpha)) / sqrt((a * a * cosf(alpha) * cosf(alpha)) + (b * b * sinf(alpha) * sinf(alpha)));
						float32 y = (b * b * sinf(alpha)) / sqrt((a * a * cosf(alpha) * cosf(alpha)) + (b * b * sinf(alpha) * sinf(alpha)));
						vertex[nVert].Set(x, y);
					}
					b2PolygonShape box;
					box.Set(vertex, nVert);
					
					// Define the dynamic body fixture.
					b2FixtureDef fixtureDef;
					fixtureDef.shape = &box;	
					fixtureDef.density = 2.0f;
					fixtureDef.friction = 0.2f;
					fixtureDef.restitution = 0.0f;
					body->CreateFixture(&fixtureDef);
				}
				else
				{ // circle
					b2CircleShape box;
					box.m_radius = sprite.contentSize.width / 2 / PTM_RATIO * RATE_WIDTH1;

					// Define the dynamic body fixture.
					b2FixtureDef fixtureDef;
					fixtureDef.shape = &box;	
					fixtureDef.density = 2.0f;
					fixtureDef.friction = 0.2f;
					fixtureDef.restitution = 0.0f;
					body->CreateFixture(&fixtureDef);
				}
			}
			break;
		case 7:
			{
				for(nVert = 0; nVert < 24; nVert++)
				{
					CGFloat alpha = (float)nVert * (float)15 / float(180) * b2_pi;
					float32 x = (a * a * cosf(alpha)) / sqrt((a * a * cosf(alpha) * cosf(alpha)) + (b * b * sinf(alpha) * sinf(alpha)));
					float32 y = (b * b * sinf(alpha)) / sqrt((a * a * cosf(alpha) * cosf(alpha)) + (b * b * sinf(alpha) * sinf(alpha)));
					vertex[nVert].Set(x, y);
				}
				b2PolygonShape box;
				box.Set(vertex, nVert);
				
				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &box;	
				fixtureDef.density = 2.0f;
				fixtureDef.friction = 0.2f;
				fixtureDef.restitution = 0.0f;
				body->CreateFixture(&fixtureDef);
			}
			break;
		case 8:
			{
				switch (num) {
					case 0:
						vertex[0].Set((48 - w1) * rate, -b);
						vertex[1].Set((63 - w1) * rate, (h1 - 25) * rate);
						vertex[2].Set((72 - w1) * rate, (h1 - 23) * rate);
						vertex[3].Set((76 - w1) * rate, (h1 - 21) * rate);
						vertex[4].Set((78 - w1) * rate, (h1 - 20) * rate);
						vertex[5].Set(a, (h1 - 16) * rate);
						vertex[6].Set(a, (h1 - 13) * rate);
						vertex[7].Set((78 - w1) * rate, (h1 - 9) * rate);
						vertex[8].Set((75 - w1) * rate, (h1 - 7) * rate);
						vertex[9].Set((71 - w1) * rate, (h1 - 5) * rate);
						vertex[10].Set((63 - w1) * rate, (h1 - 3) * rate);
						vertex[11].Set((56 - w1) * rate, (h1 - 2) * rate);
						vertex[12].Set((47 - w1) * rate, b);
						vertex[13].Set((36 - w1) * rate, b);
						vertex[14].Set((12 - w1) * rate, (h1 - 4) * rate);
						vertex[15].Set((6 - w1) * rate, (h1 - 6) * rate);
						vertex[16].Set((2 - w1) * rate, (h1 - 10) * rate);
						vertex[17].Set(-a, (h1 - 13) * rate);
						vertex[18].Set(-a, (h1 - 16) * rate);
						vertex[19].Set((5 - w1) * rate, (h1 - 23) * rate);
						vertex[20].Set((14 - w1) * rate, (h1 - 24) * rate);
						vertex[21].Set((32 - w1) * rate, -b);
						nVert = 22;
						break;
					case 1:
						vertex[0].Set((44 - w1) * rate, -b);
						vertex[1].Set((63 - w1) * rate, (h1 - 30) * rate);
						vertex[2].Set((74 - w1) * rate, (h1 - 27) * rate);
						vertex[3].Set(a, (h1 - 20) * rate);
						vertex[4].Set(a, (h1 - 16) * rate);
						vertex[5].Set((74 - w1) * rate, (h1 - 8) * rate);
						vertex[6].Set((72 - w1) * rate, (h1 - 6) * rate);
						vertex[7].Set((58 - w1) * rate, (h1 - 2) * rate);
						vertex[8].Set((48 - w1) * rate, b);
						vertex[9].Set((42 - w1) * rate, b);
						vertex[10].Set((20 - w1) * rate, (h1 - 2) * rate);
						vertex[11].Set((9 - w1) * rate, (h1 - 5) * rate);
						vertex[12].Set(-a, (h1 - 13) * rate);
						vertex[13].Set(-a, (h1 - 18) * rate);
						vertex[14].Set((7 - w1) * rate, (h1 - 27) * rate);
						vertex[15].Set((25 - w1) * rate, (h1 - 31) * rate);
						vertex[16].Set((37 - w1) * rate, -b);
						nVert = 17;
						break;
					case 2:
						vertex[0].Set((46 - w1) * rate, -b);
						vertex[1].Set((71 - w1) * rate, (h1 - 40) * rate);
						vertex[2].Set(a, (h1 - 31) * rate);
						vertex[3].Set(a, (h1 - 22) * rate);
						vertex[4].Set((76 - w1) * rate, (h1 - 15) * rate);
						vertex[5].Set((71 - w1) * rate, (h1 - 9) * rate);
						vertex[6].Set((60 - w1) * rate, (h1 - 3) * rate);
						vertex[7].Set((54 - w1) * rate, (h1 - 1) * rate);
						vertex[8].Set((48 - w1) * rate, b);
						vertex[9].Set((30 - w1) * rate, b);
						vertex[10].Set((18 - w1) * rate, (h1 - 1) * rate);
						vertex[11].Set((12 - w1) * rate, (h1 - 5) * rate);
						vertex[12].Set((8 - w1) * rate, (h1 - 9) * rate);
						vertex[13].Set(-a, (h1 - 22) * rate);
						vertex[14].Set(-a, (h1 - 28) * rate);
						vertex[15].Set((7 - w1) * rate, (h1 - 40) * rate);
						vertex[16].Set((18 - w1) * rate, (h1 - 43) * rate);
						vertex[17].Set((39 - w1) * rate, -b);
						nVert = 18;
						break;
					case 3:
						vertex[0].Set((50 - w1) * rate, -b);
						vertex[1].Set((73 - w1) * rate, (h1 - 35) * rate);
						vertex[2].Set(a, (h1 - 23) * rate);
						vertex[3].Set(a, (h1 - 19) * rate);
						vertex[4].Set((73 - w1) * rate, (h1 - 6) * rate);
						vertex[5].Set((64 - w1) * rate, (h1 - 2) * rate);
						vertex[6].Set((55 - w1) * rate, b);
						vertex[7].Set((45 - w1) * rate, b);
						vertex[8].Set((25 - w1) * rate, (h1 - 4) * rate);
						vertex[9].Set((11 - w1) * rate, (h1 - 10) * rate);
						vertex[10].Set((2 - w1) * rate, (h1 - 19) * rate);
						vertex[11].Set(-a, (h1 - 21) * rate);
						vertex[12].Set(-a, (h1 - 27) * rate);
						vertex[13].Set((10 - w1) * rate, (h1 - 36) * rate);
						vertex[14].Set((24 - w1) * rate, (h1 - 40) * rate);
						vertex[15].Set((32 - w1) * rate, -b);
						nVert = 16;
						break;
					case 4:
						vertex[0].Set((43 - w1) * rate, -b);
						vertex[1].Set((66 - w1) * rate, (h1 - 38) * rate);
						vertex[2].Set((72 - w1) * rate, (h1 - 35) * rate);
						vertex[3].Set((78 - w1) * rate, (h1 - 28) * rate);
						vertex[4].Set(a, (h1 - 25) * rate);
						vertex[5].Set(a, (h1 - 22) * rate);
						vertex[6].Set((74 - w1) * rate, (h1 - 14) * rate);
						vertex[7].Set((65 - w1) * rate, (h1 - 7) * rate);
						vertex[8].Set((55 - w1) * rate, (h1 - 4) * rate);
						vertex[9].Set((44 - w1) * rate, (h1 - 2) * rate);
						vertex[10].Set((35 - w1) * rate, b);
						vertex[11].Set((26 - w1) * rate, b);
						vertex[12].Set((12 - w1) * rate, (h1 - 3) * rate);
						vertex[13].Set((5 - w1) * rate, (h1 - 7) * rate);
						vertex[14].Set(-a, (h1 - 17) * rate);
						vertex[15].Set(-a, (h1 - 22) * rate);
						vertex[16].Set((3 - w1) * rate, (h1 - 30) * rate);
						vertex[17].Set((7 - w1) * rate, (h1 - 35) * rate);
						vertex[18].Set((13 - w1) * rate, (h1 - 38) * rate);
						vertex[19].Set((21 - w1) * rate, (h1 - 40) * rate);
						vertex[20].Set((31 - w1) * rate, -b);
						nVert = 21;
						break;
					case 5:
						vertex[0].Set((48 - w1) * rate, -b);
						vertex[1].Set((73 - w1) * rate, (h1 - 43) * rate);
						vertex[2].Set(a, (h1 - 33) * rate);
						vertex[3].Set(a, (h1 - 24) * rate);
						vertex[4].Set((72 - w1) * rate, (h1 - 13) * rate);
						vertex[5].Set((41 - w1) * rate, b);
						vertex[6].Set((21 - w1) * rate, b);
						vertex[7].Set((9 - w1) * rate, (h1 - 9) * rate);
						vertex[8].Set((5 - w1) * rate, (h1 - 9) * rate);
						vertex[9].Set(-a, (h1 - 19) * rate);
						vertex[10].Set(-a, (h1 - 29) * rate);
						vertex[11].Set((7 - w1) * rate, (h1 - 42) * rate);
						vertex[12].Set((15 - w1) * rate, (h1 - 47) * rate);
						vertex[13].Set((29 - w1) * rate, -b);
						nVert = 14;
						break;
				}
				b2PolygonShape box;
				box.Set(vertex, nVert);
				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &box;	
				fixtureDef.density = 2.0f;
				fixtureDef.friction = 0.2f;
				fixtureDef.restitution = 0.0f;
				body->CreateFixture(&fixtureDef);
			}
			break;
		case 9:
			{
				b2CircleShape box;
				box.m_radius = a;

				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &box;	
				fixtureDef.density = 2.0f;
				fixtureDef.friction = 0.2f;
				fixtureDef.restitution = 0.0f;
				body->CreateFixture(&fixtureDef);
			}
			break;
		case 10:
			{
				switch (num) {
					case 0:
						vertex[0].Set((43 - w1) * rate, -b);
						vertex[1].Set((56 - w1) * rate, (h1 - 84) * rate);
						vertex[2].Set((62 - w1) * rate, (h1 - 80) * rate);
						vertex[3].Set((71 - w1) * rate, (h1 -67 ) * rate);
						vertex[4].Set((75 - w1) * rate, (h1 - 59) * rate);
						vertex[5].Set((78 - w1) * rate, (h1 - 52) * rate);
						vertex[6].Set(a, (h1 - 46) * rate);
						vertex[7].Set(a, (h1 - 40) * rate);
						vertex[8].Set((77 - w1) * rate, (h1 - 33) * rate);
						vertex[9].Set((74 - w1) * rate, (h1 - 26) * rate);
						vertex[10].Set((61 - w1) * rate, (h1 - 13) * rate);
						vertex[11].Set((51 - w1) * rate, (h1 - 9) * rate);
						vertex[12].Set((28 - w1) * rate, (h1 - 9) * rate);
						vertex[13].Set((20 - w1) * rate, (h1 - 11) * rate);
						vertex[14].Set((8 - w1) * rate, (h1 - 20) * rate);
						vertex[15].Set((3 - w1) * rate, (h1 - 30) * rate);
						vertex[16].Set(-a, (h1 - 40) * rate);
						vertex[17].Set(-a, (h1 - 46) * rate);
						vertex[18].Set((4 - w1) * rate, (h1 - 59) * rate);
						vertex[19].Set((14 - w1) * rate, (h1 - 74) * rate);
						vertex[20].Set((22 - w1) * rate, (h1 - 82) * rate);
						vertex[21].Set((36 - w1) * rate, -b);
						nVert = 22;
						break;
					case 1:
						vertex[0].Set((44 - w1) * rate, (h1 - 87) * rate);
						vertex[1].Set((58 - w1) * rate, (h1 - 83) * rate);
						vertex[2].Set((64 - w1) * rate, (h1 - 78) * rate);
						vertex[3].Set((70 - w1) * rate, (h1 - 72) * rate);
						vertex[4].Set((74 - w1) * rate, (h1 - 68) * rate);
						vertex[5].Set((77 - w1) * rate, (h1 - 59) * rate);
						vertex[6].Set(a, (h1 - 51) * rate);
						vertex[7].Set(a, (h1 - 44) * rate);
						vertex[8].Set((76 - w1) * rate, (h1 - 34) * rate);
						vertex[9].Set((73 - w1) * rate, (h1 - 28) * rate);
						vertex[10].Set((68 - w1) * rate, (h1 - 21) * rate);
						vertex[11].Set((62 - w1) * rate, (h1 - 17) * rate);
						vertex[12].Set((53 - w1) * rate, (h1 - 15) * rate);
						vertex[13].Set((24 - w1) * rate, (h1 - 15) * rate);
						vertex[14].Set((16 - w1) * rate, (h1 - 17) * rate);
						vertex[15].Set((8 - w1) * rate, (h1 - 25) * rate);
						vertex[16].Set((1 - w1) * rate, (h1 - 38) * rate);
						vertex[17].Set(-a, (h1 - 44) * rate);
						vertex[18].Set(-a, (h1 - 52) * rate);
						vertex[19].Set((5 - w1) * rate, (h1 - 68) * rate);
						vertex[20].Set((14 - w1) * rate, (h1 - 78) * rate);
						vertex[21].Set((22 - w1) * rate, (h1 - 83) * rate);
						vertex[22].Set((32 - w1) * rate, (h1 - 87) * rate);
						nVert = 23;
						break;
					case 2:
						vertex[0].Set((43 - w1) * rate, (h1 - 79) * rate);
						vertex[1].Set((58 - w1) * rate, (h1 - 73) * rate);
						vertex[2].Set((68 - w1) * rate, (h1 - 64) * rate);
						vertex[3].Set((73 - w1) * rate, (h1 - 56) * rate);
						vertex[4].Set((77 - w1) * rate, (h1 - 44) * rate);
						vertex[5].Set(a, (h1 - 38) * rate);
						vertex[6].Set(a, (h1 - 31) * rate);
						vertex[7].Set((76 - w1) * rate, (h1 - 24) * rate);
						vertex[8].Set((68 - w1) * rate, (h1 - 14) * rate);
						vertex[9].Set((60 - w1) * rate, (h1 - 10) * rate);
						vertex[10].Set((19 - w1) * rate, (h1 - 9) * rate);
						vertex[11].Set((9 - w1) * rate, (h1 - 15) * rate);
						vertex[12].Set((4 - w1) * rate, (h1 - 21) * rate);
						vertex[13].Set((2 - w1) * rate, (h1 - 28) * rate);
						vertex[14].Set(-a, (h1 - 33) * rate);
						vertex[15].Set(-a, (h1 - 37) * rate);
						vertex[16].Set((3 - w1) * rate, (h1 - 50) * rate);
						vertex[17].Set((7 - w1) * rate, (h1 - 59) * rate);
						vertex[18].Set((12 - w1) * rate, (h1 - 66) * rate);
						vertex[19].Set((22 - w1) * rate, (h1 - 73) * rate);
						vertex[20].Set((31 - w1) * rate, (h1 - 78) * rate);
						vertex[21].Set((37 - w1) * rate, (h1 - 79) * rate);
						nVert = 22;
						break;
					case 3:
						vertex[0].Set((43 - w1) * rate, (h1 - 75) * rate);
						vertex[1].Set((54 - w1) * rate, (h1 - 72) * rate);
						vertex[2].Set((60 - w1) * rate, (h1 - 69) * rate);
						vertex[3].Set((69 - w1) * rate, (h1 - 59) * rate);
						vertex[4].Set((74 - w1) * rate, (h1 - 48) * rate);
						vertex[5].Set(a, (h1 - 42) * rate);
						vertex[6].Set(a, (h1 - 33) * rate);
						vertex[7].Set((74 - w1) * rate, (h1 - 24) * rate);
						vertex[8].Set((72 - w1) * rate, (h1 - 20) * rate);
						vertex[9].Set((64 - w1) * rate, (h1 - 11) * rate);
						vertex[10].Set((60 - w1) * rate, (h1 - 9) * rate);
						vertex[11].Set((19 - w1) * rate, (h1 - 7) * rate);
						vertex[12].Set((14 - w1) * rate, (h1 - 9) * rate);
						vertex[13].Set((7 - w1) * rate, (h1 - 16) * rate);
						vertex[14].Set((4 - w1) * rate, (h1 - 22) * rate);
						vertex[15].Set((1 - w1) * rate, (h1 - 27) * rate);
						vertex[16].Set(-a, (h1 - 32) * rate);
						vertex[17].Set(-a, (h1 - 40) * rate);
						vertex[18].Set((4 - w1) * rate, (h1 - 51) * rate);
						vertex[19].Set((7 - w1) * rate, (h1 - 58) * rate);
						vertex[20].Set((14 - w1) * rate, (h1 - 66) * rate);
						vertex[21].Set((22 - w1) * rate, (h1 - 71) * rate);
						vertex[22].Set((35 - w1) * rate, (h1 - 75) * rate);
						nVert = 23;
						break;
					case 4:
						vertex[0].Set((43 - w1) * rate, (h1 - 75) * rate);
						vertex[1].Set((54 - w1) * rate, (h1 - 72) * rate);
						vertex[2].Set((60 - w1) * rate, (h1 - 69) * rate);
						vertex[3].Set((69 - w1) * rate, (h1 - 59) * rate);
						vertex[4].Set((74 - w1) * rate, (h1 - 48) * rate);
						vertex[5].Set(a, (h1 - 42) * rate);
						vertex[6].Set(a, (h1 - 33) * rate);
						vertex[7].Set((74 - w1) * rate, (h1 - 24) * rate);
						vertex[8].Set((72 - w1) * rate, (h1 - 20) * rate);
						vertex[9].Set((64 - w1) * rate, (h1 - 11) * rate);
						vertex[10].Set((59 - w1) * rate, (h1 - 7) * rate);
						vertex[11].Set((18 - w1) * rate, (h1 - 8) * rate);
						vertex[12].Set((14 - w1) * rate, (h1 - 9) * rate);
						vertex[13].Set((7 - w1) * rate, (h1 - 16) * rate);
						vertex[14].Set((4 - w1) * rate, (h1 - 22) * rate);
						vertex[15].Set((1 - w1) * rate, (h1 - 27) * rate);
						vertex[16].Set(-a, (h1 - 32) * rate);
						vertex[17].Set(-a, (h1 - 40) * rate);
						vertex[18].Set((4 - w1) * rate, (h1 - 51) * rate);
						vertex[19].Set((7 - w1) * rate, (h1 - 58) * rate);
						vertex[20].Set((14 - w1) * rate, (h1 - 66) * rate);
						vertex[21].Set((22 - w1) * rate, (h1 - 71) * rate);
						vertex[22].Set((35 - w1) * rate, (h1 - 75) * rate);
						nVert = 23;
						break;
					case 5:
						vertex[0].Set((42 - w1) * rate, (h1 - 73) * rate);
						vertex[1].Set((55 - w1) * rate, (h1 - 70) * rate);
						vertex[2].Set((63 - w1) * rate, (h1 - 64) * rate);
						vertex[3].Set((70 - w1) * rate, (h1 - 58) * rate);
						vertex[4].Set((75 - w1) * rate, (h1 - 48) * rate);
						vertex[5].Set(a, (h1 - 39) * rate);
						vertex[6].Set(a, (h1 - 28) * rate);
						vertex[7].Set((75 - w1) * rate, (h1 - 23) * rate);
						vertex[8].Set((73 - w1) * rate, (h1 - 18) * rate);
						vertex[9].Set((66 - w1) * rate, (h1 - 8) * rate);
						vertex[10].Set((57 - w1) * rate, (h1 - 2) * rate);
						vertex[11].Set((51 - w1) * rate, (h1 - 2) * rate);
						vertex[12].Set((11 - w1) * rate, (h1 - 12) * rate);
						vertex[13].Set((8 - w1) * rate, (h1 - 15) * rate);
						vertex[14].Set((6 - w1) * rate, (h1 - 18) * rate);
						vertex[15].Set((2 - w1) * rate, (h1 - 28) * rate);
						vertex[16].Set(-a, (h1 - 34) * rate);
						vertex[17].Set(-a, (h1 - 40) * rate);
						vertex[18].Set((4 - w1) * rate, (h1 - 50) * rate);
						vertex[19].Set((16 - w1) * rate, (h1 - 65) * rate);
						vertex[20].Set((22 - w1) * rate, (h1 - 70) * rate);
						vertex[21].Set((29 - w1) * rate, (h1 - 72) * rate);
						vertex[22].Set((34 - w1) * rate, (h1 - 73) * rate);
						nVert = 23;
						break;
				}
				b2PolygonShape box;
				box.Set(vertex, nVert);
				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &box;	
				fixtureDef.density = 2.0f;
				fixtureDef.friction = 0.2f;
				fixtureDef.restitution = 0.0f;
				body->CreateFixture(&fixtureDef);
			}
			break;
		case 11:
			{
				switch (num) {
					case 0:
					{
						vertex[0].Set((30 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((35 - w1) * rate, b);
						vertex[2].Set((28 - w1) * rate, b);
						vertex[3].Set((22 - w1) * rate, (h1 - 5) * rate);
						nVert = 4;
						b2PolygonShape box1;
						box1.Set(vertex, nVert);
						b2FixtureDef fixtureDef1;
						fixtureDef1.shape = &box1;	
						fixtureDef1.density = 2.0f;
						fixtureDef1.friction = 0.2f;
						fixtureDef1.restitution = 0.0f;
						body->CreateFixture(&fixtureDef1);

						vertex[0].Set((22 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((17 - w1) * rate, b);
						vertex[2].Set((9 - w1) * rate, b);
						vertex[3].Set((14 - w1) * rate, (h1 - 5) * rate);
						nVert = 4;
						b2PolygonShape box2;
						box2.Set(vertex, nVert);
						b2FixtureDef fixtureDef2;
						fixtureDef2.shape = &box2;	
						fixtureDef2.density = 2.0f;
						fixtureDef2.friction = 0.2f;
						fixtureDef2.restitution = 0.0f;
						body->CreateFixture(&fixtureDef2);
						
						vertex[0].Set((31 - w1) * rate, (h1 - 63) * rate);
						vertex[1].Set((41 - w1) * rate, (h1 - 40) * rate);
						vertex[2].Set(a, (h1 - 30) * rate);
						vertex[3].Set(a, (h1 - 20) * rate);
						vertex[4].Set((41 - w1) * rate, (h1 - 13) * rate);
						vertex[5].Set((37 - w1) * rate, (h1 - 9) * rate);
						vertex[6].Set((30 - w1) * rate, (h1 - 5) * rate);
						vertex[7].Set((14 - w1) * rate, (h1 - 5) * rate);
						vertex[8].Set((7 - w1) * rate, (h1 - 9) * rate);
						vertex[9].Set((3 - w1) * rate, (h1 - 13) * rate);
						vertex[10].Set(-a, (h1 - 20) * rate);
						vertex[11].Set(-a, (h1 - 30) * rate);
						vertex[12].Set((2 - w1) * rate, (h1 - 40) * rate);
						vertex[13].Set((12 - w1) * rate, (h1 - 63) * rate);
						nVert = 14;
						b2PolygonShape box3;
						box3.Set(vertex, nVert);
						b2FixtureDef fixtureDef3;
						fixtureDef3.shape = &box3;	
						fixtureDef3.density = 2.0f;
						fixtureDef3.friction = 0.2f;
						fixtureDef3.restitution = 0.0f;
						body->CreateFixture(&fixtureDef3);
						
						vertex[0].Set((31 - w1) * rate, (h1 - 63) * rate);
						vertex[1].Set((12 - w1) * rate, (h1 - 63) * rate);
						vertex[2].Set((8 - w1) * rate, -b);
						vertex[3].Set((36 - w1) * rate, -b);
						nVert = 4;
						break;
					}
					case 1:
					{
						vertex[0].Set((49 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((52 - w1) * rate, b);
						vertex[2].Set((46 - w1) * rate, b);
						vertex[3].Set((44 - w1) * rate, (h1 - 5) * rate);
						nVert = 4;
						b2PolygonShape box1;
						box1.Set(vertex, nVert);
						b2FixtureDef fixtureDef1;
						fixtureDef1.shape = &box1;	
						fixtureDef1.density = 2.0f;
						fixtureDef1.friction = 0.2f;
						fixtureDef1.restitution = 0.0f;
						body->CreateFixture(&fixtureDef1);
						
						vertex[0].Set((35 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((33 - w1) * rate, b);
						vertex[2].Set((27 - w1) * rate, b);
						vertex[3].Set((30 - w1) * rate, (h1 - 5) * rate);
						nVert = 4;
						b2PolygonShape box2;
						box2.Set(vertex, nVert);
						b2FixtureDef fixtureDef2;
						fixtureDef2.shape = &box2;	
						fixtureDef2.density = 2.0f;
						fixtureDef2.friction = 0.2f;
						fixtureDef2.restitution = 0.0f;
						body->CreateFixture(&fixtureDef2);
						
						vertex[0].Set((49 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((30 - w1) * rate, (h1 - 5) * rate);
						vertex[2].Set((30 - w1) * rate, (h1 - 7) * rate);
						vertex[3].Set((49 - w1) * rate, (h1 - 7) * rate);
						nVert = 4;
						b2PolygonShape box3;
						box3.Set(vertex, nVert);
						b2FixtureDef fixtureDef3;
						fixtureDef3.shape = &box3;	
						fixtureDef3.density = 2.0f;
						fixtureDef3.friction = 0.2f;
						fixtureDef3.restitution = 0.0f;
						body->CreateFixture(&fixtureDef3);
						
						vertex[0].Set((59 - w1) * rate, -b);
						vertex[1].Set((71 - w1) * rate, (h1 - 59) * rate);
						vertex[2].Set(a, (h1 - 47) * rate);
						vertex[3].Set(a, (h1 - 35) * rate);
						vertex[4].Set((72 - w1) * rate, (h1 - 24) * rate);
						vertex[5].Set((62 - w1) * rate, (h1 - 14) * rate);
						vertex[6].Set((49 - w1) * rate, (h1 - 7) * rate);
						vertex[7].Set((30 - w1) * rate, (h1 - 7) * rate);
						vertex[8].Set((18 - w1) * rate, (h1 - 14) * rate);
						vertex[9].Set((7 - w1) * rate, (h1 - 23) * rate);
						vertex[10].Set(-a, (h1 - 35) * rate);
						vertex[11].Set(-a, (h1 - 47) * rate);
						vertex[12].Set((7 - w1) * rate, (h1 - 59) * rate);
						vertex[13].Set((20 - w1) * rate, -b);
						nVert = 14;
						break;
					}
					case 2:
					case 3:
						vertex[0].Set(a, -b);
						vertex[1].Set(a, b);
						vertex[2].Set(-a, b);
						vertex[3].Set(-a, -b);
						nVert = 4;
						break;
					case 4:
					{
						vertex[0].Set((49 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((52 - w1) * rate, b);
						vertex[2].Set((46 - w1) * rate, b);
						vertex[3].Set((44 - w1) * rate, (h1 - 5) * rate);
						nVert = 4;
						b2PolygonShape box1;
						box1.Set(vertex, nVert);
						b2FixtureDef fixtureDef1;
						fixtureDef1.shape = &box1;	
						fixtureDef1.density = 2.0f;
						fixtureDef1.friction = 0.2f;
						fixtureDef1.restitution = 0.0f;
						body->CreateFixture(&fixtureDef1);
						
						vertex[0].Set((35 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((33 - w1) * rate, b);
						vertex[2].Set((27 - w1) * rate, b);
						vertex[3].Set((30 - w1) * rate, (h1 - 5) * rate);
						nVert = 4;
						b2PolygonShape box2;
						box2.Set(vertex, nVert);
						b2FixtureDef fixtureDef2;
						fixtureDef2.shape = &box2;	
						fixtureDef2.density = 2.0f;
						fixtureDef2.friction = 0.2f;
						fixtureDef2.restitution = 0.0f;
						body->CreateFixture(&fixtureDef2);
						
						vertex[0].Set((49 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((30 - w1) * rate, (h1 - 5) * rate);
						vertex[2].Set((30 - w1) * rate, (h1 - 7) * rate);
						vertex[3].Set((49 - w1) * rate, (h1 - 7) * rate);
						nVert = 4;
						b2PolygonShape box3;
						box3.Set(vertex, nVert);
						b2FixtureDef fixtureDef3;
						fixtureDef3.shape = &box3;	
						fixtureDef3.density = 2.0f;
						fixtureDef3.friction = 0.2f;
						fixtureDef3.restitution = 0.0f;
						body->CreateFixture(&fixtureDef3);
						
						vertex[0].Set((59 - w1) * rate, (h1 - 55) * rate);
						vertex[1].Set((72 - w1) * rate, (h1 - 43) * rate);
						vertex[2].Set(a, (h1 - 29) * rate);
						vertex[3].Set(a, (h1 - 19) * rate);
						vertex[4].Set((74 - w1) * rate, (h1 - 14) * rate);
						vertex[5].Set((49 - w1) * rate, (h1 - 7) * rate);
						vertex[6].Set((30 - w1) * rate, (h1 - 7) * rate);
						vertex[7].Set((4 - w1) * rate, (h1 - 14) * rate);
						vertex[8].Set(-a, (h1 - 19) * rate);
						vertex[9].Set(-a, (h1 - 29) * rate);
						vertex[10].Set((7 - w1) * rate, (h1 - 43) * rate);
						vertex[11].Set((21 - w1) * rate, (h1 - 55) * rate);
						nVert = 12;
						break;
					}
					case 5:
					{
						vertex[0].Set((38 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((42 - w1) * rate, b);
						vertex[2].Set((37 - w1) * rate, b);
						vertex[3].Set((33 - w1) * rate, (h1 - 5) * rate);
						nVert = 4;
						b2PolygonShape box1;
						box1.Set(vertex, nVert);
						b2FixtureDef fixtureDef1;
						fixtureDef1.shape = &box1;	
						fixtureDef1.density = 2.0f;
						fixtureDef1.friction = 0.2f;
						fixtureDef1.restitution = 0.0f;
						body->CreateFixture(&fixtureDef1);
						
						vertex[0].Set((31 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((27 - w1) * rate, b);
						vertex[2].Set((22 - w1) * rate, b);
						vertex[3].Set((26 - w1) * rate, (h1 - 5) * rate);
						nVert = 4;
						b2PolygonShape box2;
						box2.Set(vertex, nVert);
						b2FixtureDef fixtureDef2;
						fixtureDef2.shape = &box2;	
						fixtureDef2.density = 2.0f;
						fixtureDef2.friction = 0.2f;
						fixtureDef2.restitution = 0.0f;
						body->CreateFixture(&fixtureDef2);
						
						vertex[0].Set((38 - w1) * rate, (h1 - 5) * rate);
						vertex[1].Set((26 - w1) * rate, (h1 - 5) * rate);
						vertex[2].Set((26 - w1) * rate, (h1 - 7) * rate);
						vertex[3].Set((38 - w1) * rate, (h1 - 7) * rate);
						nVert = 4;
						b2PolygonShape box3;
						box3.Set(vertex, nVert);
						b2FixtureDef fixtureDef3;
						fixtureDef3.shape = &box3;	
						fixtureDef3.density = 2.0f;
						fixtureDef3.friction = 0.2f;
						fixtureDef3.restitution = 0.0f;
						body->CreateFixture(&fixtureDef3);
						
						vertex[0].Set((50 - w1) * rate, (h1 - 41) * rate);
						vertex[1].Set((58 - w1) * rate, (h1 - 37) * rate);
						vertex[2].Set(a, (h1 - 30) * rate);
						vertex[3].Set(a, (h1 - 22) * rate);
						vertex[4].Set((56 - w1) * rate, (h1 - 13) * rate);
						vertex[5].Set((38 - w1) * rate, (h1 - 7) * rate);
						vertex[6].Set((26 - w1) * rate, (h1 - 7) * rate);
						vertex[7].Set((8 - w1) * rate, (h1 - 13) * rate);
						vertex[8].Set(-a, (h1 - 22) * rate);
						vertex[9].Set(-a, (h1 - 30) * rate);
						vertex[10].Set((6 - w1) * rate, (h1 - 37) * rate);
						vertex[11].Set((14 - w1) * rate, (h1 - 41) * rate);
						nVert = 12;
						b2PolygonShape box4;
						box4.Set(vertex, nVert);
						b2FixtureDef fixtureDef4;
						fixtureDef4.shape = &box4;	
						fixtureDef4.density = 2.0f;
						fixtureDef4.friction = 0.2f;
						fixtureDef4.restitution = 0.0f;
						body->CreateFixture(&fixtureDef4);
						
						vertex[0].Set((45 - w1) * rate, (h1 - 78) * rate);
						vertex[1].Set((58 - w1) * rate, (h1 - 69) * rate);
						vertex[2].Set(a, (h1 - 61) * rate);
						vertex[3].Set(a, (h1 - 55) * rate);
						vertex[4].Set((58 - w1) * rate, (h1 - 48) * rate);
						vertex[5].Set((50 - w1) * rate, (h1 - 42) * rate);
						vertex[6].Set((14 - w1) * rate, (h1 - 42) * rate);
						vertex[7].Set((5 - w1) * rate, (h1 - 48) * rate);
						vertex[8].Set(-a, (h1 - 55) * rate);
						vertex[9].Set(-a, (h1 - 61) * rate);
						vertex[10].Set((6 - w1) * rate, (h1 - 69) * rate);
						vertex[11].Set((19 - w1) * rate, (h1 - 78) * rate);
						nVert = 12;
						break;
					}
				}
				b2PolygonShape box;
				box.Set(vertex, nVert);
				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &box;	
				fixtureDef.density = 2.0f;
				fixtureDef.friction = 0.2f;
				fixtureDef.restitution = 0.0f;
				body->CreateFixture(&fixtureDef);
			}
			break;
	}
	
	if (m_pCurBody != nil)
	{
		m_pCurBody->SetLinearVelocity(b2Vec2(0, 0));
		m_pCurBody->SetAngularVelocity(0);
//		m_pCurBody->SetType(b2_staticBody);
	}
	m_pCurBody = body;
	m_pContactListener->setContact(FALSE);
    isOtherBody = YES;
//	m_pCurBody->ApplyForce(b2Vec2(-30, 0), m_pCurBody->GetPosition());
}

- (void) calcStackCount {
	m_nStackCount = 0;
	for (b2Body* b = m_pWorld->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			BodyUserData *myData = (BodyUserData*)b->GetUserData();
			if ([myData bodyType] == BT_Static)
				continue;
			m_nStackCount ++;
		}
	}
    
//    m_nStackCount = m_pContactListener->getContactCount();
    
	if (m_nStackCount != g_nStackCount)
	{
		g_nStackCount = m_nStackCount;
		[(StackEMAppDelegate*)[[UIApplication sharedApplication] delegate] addOne];
	}
	[self drawStackCount];
}

- (void) setItemType:(int) nType {
	m_nItemType = nType;
}

#pragma mark Schedule Tick
-(void)tick:(ccTime)dt
{
//    NSLog(@"Called");
	StackEMAppDelegate* appDel = (StackEMAppDelegate*)[UIApplication sharedApplication].delegate;
	if (appDel.viewController.m_nState != Game_Play)
		return;
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	m_pWorld->Step(dt, velocityIterations, positionIterations);

	
	//Iterate over the bodies in the physics world
	for (b2Body* b = m_pWorld->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) 
        {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			BodyUserData *myData = (BodyUserData*)b->GetUserData();
			if ([myData bodyType] == BT_Static)
				continue;
			CCSprite* myActor = myData.sprite;
			CGPoint pt = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);

			myActor.position = pt;
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
			if ([myData bodyType] == BT_Dynamic)
			{
                if (pt.y + myActor.contentSize.height / 2 > pt.y + 10) 
                {
//                    NSLog(@"Point of Body : %@",NSStringFromCGPoint(pt));                    
                }
                
				if ((pt.y + myActor.contentSize.height / 2) < 0)
				{
                    [showTimer invalidate];
					[self onFinish];
					break;
				}
			}
		}
	}
}


#pragma mark Selected Body
-(BOOL) isSelectedCurBody:(CGPoint) pt 
{
	return [self ptInBody:m_pCurBody Point:pt];
}


-(BOOL)ptInBody:(b2Body*) body Point:(CGPoint) pt {
	if (body == NULL)
		return FALSE;
	BodyUserData* data = (BodyUserData*)body->GetUserData();
	if (data == NULL)
		return FALSE;
	if ([data bodyType] == BT_Static)
		return FALSE;
	CCSprite* sprite = data.sprite;
	CGPoint center = sprite.position;
	CGFloat width = sprite.contentSize.width * RATE_WIDTH1, height = sprite.contentSize.height * RATE_WIDTH1;
	CGRect rc = CGRectMake(center.x - width / 2.0f, center.y - height / 2.0f, width, height);
	if (CGRectContainsPoint(rc, pt))
		return TRUE;
	return FALSE;
}

- (b2Body*) getSelectBody:(CGPoint) pt {
	for (b2Body* b = m_pWorld->GetBodyList(); b; b = b->GetNext())
	{
		if ([self ptInBody:b Point:pt])
			return b;
	}
	return NULL;
}

#pragma mark
#pragma mark Touch Began

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (m_bPause)
		return;
	if (m_pCurBody == NULL)
		return;
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		m_ptPrev = location;
		if (m_bAceelerometer == FALSE)
		{
			if (m_nPlayState == PS_Balance)
			{
				b2Body* b = [self getSelectBody:location];
				if (b != NULL)
					m_pCurBody = b;
			}
			m_bSelected = [self isSelectedCurBody:location];
		}
	}
    
    isOtherBody = NO;
	m_ptOrigin = CGPointMake(m_pCurBody->GetPosition().x * PTM_RATIO, m_pCurBody->GetPosition().y * PTM_RATIO);
	m_fAlpha = 0;
	m_fDistX = 0;
	m_fDistY = 0;
}

- (CGFloat)angleBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2
{ 
	CGFloat deltaY = point1.y - point2.y;
	CGFloat deltaX = point1.x - point2.x;
	return atan2(deltaY, deltaX);
}


- (NSInteger)distanceBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
	CGFloat deltaX = fabsf(point1.x - point2.x);
	CGFloat deltaY = fabsf(point1.y - point2.y);
	return sqrt((deltaY*deltaY)+(deltaX*deltaX));
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (m_bPause)
		return;
	if (m_pCurBody == NULL)
		return;

    if(isOtherBody == YES)
        return;
    if([touches count] == 1)
    {
        for( UITouch *touch in touches ) {
            CGPoint location = [touch locationInView: [touch view]];
            location = [[CCDirector sharedDirector] convertToGL: location];
            if (!m_bAceelerometer && m_bSelected)
                [self moveStack:m_ptPrev Second:location];
    //		else
    //		[self rotateStack:m_ptPrev Second:location];
            m_ptPrev = location;
            m_ptOrigin = CGPointMake(m_pCurBody->GetPosition().x * PTM_RATIO, m_pCurBody->GetPosition().y * PTM_RATIO);
        }
    }
    else
    {
        UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
        UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
		CGPoint prevPoint1 = [touch1 previousLocationInView:[touch1 view]];		
		CGPoint prevPoint2 = [touch2 previousLocationInView:[touch2 view]];		
		CGPoint curPoint1 = [touch1 locationInView:[touch1 view]];
		CGPoint curPoint2 = [touch2 locationInView:[touch2 view]];

        float prevAngle = [self angleBetweenPoint1:prevPoint1 andPoint2:prevPoint2];
        float curAngle = [self angleBetweenPoint1:curPoint1 andPoint2:curPoint2];
        float angleDifference = curAngle - prevAngle;
        
        m_fAlpha -= angleDifference;
        m_pCurBody->SetAngularVelocity(m_fAlpha);
    }
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (m_bPause)
		return;
	if (m_pCurBody == NULL)
		return;
	m_pCurBody->SetAngularVelocity(0);
	if (m_bSelected)
	{
		b2Vec2 velocity = m_pCurBody->GetLinearVelocity();
		velocity.x = 0;
		velocity.y = 0;
		m_pCurBody->SetLinearVelocity(velocity);
	}
}

- (void) moveStack:(CGPoint) ptPrev Second:(CGPoint) ptCur {
	if (m_pCurBody == NULL)
		return;
	if (CGPointEqualToPoint(ptPrev, ptCur))
		return;
//	m_fDistX += (ptCur.x - ptPrev.x) / PTM_RATIO;
//	m_fDistY += (ptCur.y - ptPrev.y) / PTM_RATIO;
//	b2Vec2 velocity = m_pCurBody->GetLinearVelocity();
//	velocity.x = m_fDistX;
//	velocity.y = m_fDistY;
//	m_pCurBody->SetLinearVelocity(velocity);

    b2Vec2 velocity;
	velocity.x = ptCur.x / PTM_RATIO;
	velocity.y = ptCur.y / PTM_RATIO;
    
    m_pCurBody->SetTransform(velocity, 0.0f);
}

- (void) rotateStack:(CGPoint) ptPrev Second:(CGPoint) ptCur {
	if (m_pCurBody == NULL)
		return;
	if (CGPointEqualToPoint(ptPrev, ptCur))
		return;
	CGFloat alpha1 = atan2(ptPrev.y - m_ptOrigin.y, ptPrev.x - m_ptOrigin.x);
	CGFloat alpha2 = atan2(ptCur.y - m_ptOrigin.y, ptCur.x - m_ptOrigin.x);
	if ((alpha1 > 0 && alpha1 < M_PI / 2) && (alpha2 < 0 && alpha2 > -M_PI / 2) ||
		(alpha2 > 0 && alpha2 < M_PI / 2) && (alpha1 < 0 && alpha1 > -M_PI / 2))
	{
	}
	else
	{
		if (alpha1 < 0)
			alpha1 += 2 * M_PI;
		if (alpha2 < 0)
			alpha2 += 2 * M_PI;
	}
	CGFloat delta = alpha2 - alpha1;
	m_fAlpha += delta;
	m_pCurBody->SetAngularVelocity(m_fAlpha);
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	if (m_bAceelerometer == FALSE && m_nPlayState != PS_Balance)
		return;
	if (m_bPause)
		return;
	if (m_pCurBody == nil)
		return;
	
	static float prevX = 0, prevY = 0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = acceleration.x * kFilterFactor + (1- kFilterFactor) * prevX;
	float accelY = acceleration.y * kFilterFactor + (1- kFilterFactor) * prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 5
//	b2Vec2 gravity( accelX * 5, accelY * 5);
//	
//	m_pWorld->SetGravity( gravity );
//	b2Vec2 force(accelX * 20, accelY * 20);
	int n = 20;
	if (m_nItemType == 4)
		n = n * 2 / 5;
	b2Vec2 force;
	if (accelY < 0)
		force = b2Vec2(accelX * n, accelY * n / 4);
	else
		force = b2Vec2(accelX * n, accelY * n);
	b2Vec2 position = m_pCurBody->GetPosition();
	m_pCurBody->ApplyForce(force, position);
	b2Vec2 velocity = m_pCurBody->GetLinearVelocity();
	if (velocity.y > 0)
		velocity.y = -velocity.y;
	m_pCurBody->SetLinearVelocity(velocity);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	[m_Background release];
	[m_CountBack release];
	[m_StackCount release];
	[m_labTime release];
	[m_btnPause release];
	
	[m_pPauseView release];
	[m_pFinishView release];
	
	delete m_pWorld;
	m_pWorld = NULL;
	
//	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
