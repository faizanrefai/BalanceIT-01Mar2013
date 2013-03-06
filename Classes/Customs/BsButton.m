//
//  Button.m
//  StickWars - Siege
//
//  Created by EricH on 8/3/09.
//
 
#import "BsButton.h"
 

@implementation BsButton

+ (BsButton*)buttonWithImage:(NSString*)normalImage 
				 selected:(NSString*)selectedImage 
				   target:(id)target
				 selector:(SEL)sel
{
	CCSprite *normalSprite = [CCSprite spriteWithFile:normalImage];
	CCSprite *selectSprite = [CCSprite spriteWithFile:selectedImage];
	
	normalSprite.anchorPoint = ccp(0,0);
	selectSprite.anchorPoint = ccp(0,0);
	
	assert(normalSprite);
	assert(selectSprite);
	
	CCMenuItem *menuItem = [CCMenuItemSprite itemFromNormalSprite:normalSprite
												   selectedSprite:selectSprite
														   target:target
														 selector:sel];
	
	BsButton *menu = [BsButton menuWithItems:menuItem, nil];
	return menu;
}

+ (BsButton*)buttonWithString:(NSString*) title
					   normal:(NSString*)normalImage 
					selected:(NSString*)selectedImage 
					  target:(id)target
					selector:(SEL)sel 
{
	CCSprite *normalSprite = [CCSprite spriteWithFile:normalImage];
	CCSprite *selectSprite = [CCSprite spriteWithFile:selectedImage];
	
	assert(normalSprite);
	assert(selectSprite);
	
	CCMenuItem *menuItem = [CCMenuItemSprite itemFromNormalSprite:normalSprite
												   selectedSprite:selectSprite
														   target:target
														 selector:sel];
	CCLabelTTF* label = [CCLabelTTF labelWithString:title fontName:@"Arial" fontSize:24];
	CGRect rtItem = [menuItem rect];
	CGSize szItem = CGSizeMake(CGRectGetWidth(rtItem), CGRectGetHeight(rtItem));
	[label setPosition: ccp(rtItem.origin.x+szItem.width, rtItem.origin.y+szItem.height)];
	[menuItem addChild:label];	
	BsButton *menu = [BsButton menuWithItems:menuItem, menuItem, nil];
	
	
	return menu;
}

+ (BsButton*)buttonWithString:(NSString*) title
					   normal:(NSString*)normalImage 
					 selected:(NSString*)selectedImage 
					   target:(id)target
					 selector:(SEL)sel 
						tag:(int) tag
{
	CCSprite *normalSprite = [CCSprite spriteWithFile:normalImage];
	CCSprite *selectSprite = [CCSprite spriteWithFile:selectedImage];
	
	assert(normalSprite);
	assert(selectSprite);
	
	CCMenuItem *menuItem = [CCMenuItemSprite itemFromNormalSprite:normalSprite
												   selectedSprite:selectSprite
														   target:target
														 selector:sel];
	menuItem.tag = tag;
	
	[CCMenuItemFont setFontSize:20];
	[CCMenuItemFont setFontName: @"Courier New"];
	
	CCMenuItem *labelItem = [CCMenuItemFont itemFromString: title target: target selector:sel];
	labelItem.tag = tag;
	
	BsButton *menu = [BsButton menuWithItems:menuItem, labelItem, nil];
	menu.tag = tag;
	
	return menu;
}

- (void) setEnable:(BOOL) bEnable {
	self.isTouchEnabled = bEnable;
	
	if (bEnable)
		[self setOpacity: 255];
	else 
		[self setOpacity: 80];	
}

@end