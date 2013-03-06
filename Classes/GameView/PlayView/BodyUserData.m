//
//  BodyUserData.m
//  StackEM
//
//  Created by YunCholHo on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BodyUserData.h"


@implementation BodyUserData

@synthesize bodyType = mBodyType;
@synthesize sprite = mSprite;

- (id) initWithType:(int)nType Sprite:(CCSprite *)sprite {
	if ((self = [super init])) {
		mBodyType = nType;
		mSprite = [sprite retain];
	}
	
	return self;
}

- (void) dealloc 
{
	[mSprite release];
	[super dealloc];
}

@end
