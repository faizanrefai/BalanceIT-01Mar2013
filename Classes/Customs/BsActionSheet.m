//
//  BSActionSheet.m
//  IQGomoku
//
//  Created by KCU on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BsActionSheet.h"
#import "BsButton.h"

#define ZOrder	1000
#define RES_WINDOW	@"bsselectbox.png"
#define kTagStart	2000
@implementation BsActionSheet
@synthesize _delegate;    
@synthesize _title;
@synthesize _actionSheetStyle; 

- (void) createSubButtons:(NSString*) firstTitle vaList:(va_list) params {
	int i = 1;
	if (firstTitle == nil)
		return;
	
	CGRect rtWindow = [_originalWindow textureRect];
	float nCenterX = rtWindow.origin.x + CGRectGetWidth(rtWindow)/2;
	BsButton* menuItem = [BsButton buttonWithString: firstTitle
											  normal:@"bslongbutton.png" 
											selected: @"bslongbuttonf.png" 
											  target:self
											selector:@selector(menuCallbackEnable:)
												tag: kTagStart];
	[menuItem setPosition: ccp(nCenterX, 180+60)];	
	[_originalWindow addChild: menuItem];

	NSString*l = va_arg(params,NSString*);
	while(l) {
		menuItem = [BsButton buttonWithString: l
									  normal:@"bslongbutton.png" 
									selected: @"bslongbuttonf.png" 
									  target:self
									selector:@selector(menuCallbackEnable:)
										  tag: kTagStart+i];
		i ++;
		[menuItem setPosition: ccp(nCenterX, (180+60*i))];
		
		[_originalWindow addChild: menuItem];
		l = va_arg(params,NSString*);
	}	
	
	for (int j = 0; j < i; j ++) {
		CCNode *s = [self getChildByTag:kTagStart+j];
		[s setPosition: ccp(0, 180+60)];	
	}
}

-(void) alignItemsVerticallyWithPadding:(float)padding
{
	float height = -padding;
	CGRect rtWindow = [_originalWindow textureRect];
	float nCenterX = rtWindow.origin.x + CGRectGetWidth(rtWindow)/2;	
	
	CCMenu *item;
	CCARRAY_FOREACH(_originalWindow.children, item)
	height += 40 * item.scaleY + padding;
	
	float y = 320;
	
	CCARRAY_FOREACH(_originalWindow.children, item) {
	    [item setPosition:ccp(nCenterX, y - 40 * item.scaleY / 2.0f)];
	    y -= 40 * item.scaleY + padding;
	}
}

- (id)initWithTitle:(NSString *)title delegate:(id<BsActionSheetDelegate>)delegate otherButtonTitles:(NSString *)otherButtonTitles, ... {
	CGSize size = [[CCDirector sharedDirector] winSize];

	[self initWithColor: ccc4(0, 0, 0, 70)];
	self._delegate = delegate;
	_originalWindow = [[CCSprite alloc] initWithFile:RES_WINDOW];
	[_originalWindow setPosition: ccp(size.width/2, size.height/2)];
	[self addChild: _originalWindow];	
	
	CGRect rtWindow = [_originalWindow textureRect];
	float nCenterX = rtWindow.origin.x + CGRectGetWidth(rtWindow)/2;
	CCLabelTTF* label = [CCLabelTTF labelWithString:title fontName:@"Arial" fontSize:24];
	[label setPosition: ccp(nCenterX, 185)];
	[_originalWindow addChild: label];
	
	va_list args;
	va_start(args,otherButtonTitles);
	
	[self createSubButtons:otherButtonTitles vaList:args];
	[self alignItemsVerticallyWithPadding: 20];
	
	va_end(args);	
	
	return self;
}

- (void) setEnableAllControl: (CCLayer*) sender bEnable: (BOOL) bEnable{
	sender.isTouchEnabled = bEnable;
	CCNode *node;
	CCARRAY_FOREACH(sender.children, node){
		if ([node isKindOfClass:[CCLayer class]])
			((CCLayer*)node).isTouchEnabled = bEnable;
	}	
}

- (void)showInLayer: (CCLayer*) Owner{
	[Owner addChild: self z:ZOrder];
	[self setEnableAllControl: Owner bEnable: NO];
	[_originalWindow setScaleY:0.0];
	id action = [CCScaleTo actionWithDuration:.3 scaleX:1.0f scaleY:1];
	[_originalWindow runAction: action];		
}

- (void) menuCallbackEnable: (id) sender {
	CCLayer* parentLayer = (CCLayer*)[self parent];
	[self setEnableAllControl: parentLayer bEnable: YES];
	
	id scaleAction = [CCScaleTo actionWithDuration:.3 scaleX:1.0f scaleY:.0];
	id removeAction = [CCCallFuncND actionWithTarget: self selector: @selector(removeCallBack:data:) data: (void*)sender];
	id seq = [CCSequence actions: scaleAction, removeAction, nil];
	[_originalWindow runAction: seq];
}

- (void) removeCallBack: (id) sender data:(void*) data{
	[self removeFromParentAndCleanup: YES];
	
	if (self._delegate == nil)
		return;
	
	BsButton* aButton = (BsButton*)data;
	int nTag = aButton.tag - kTagStart;
	[self._delegate actionSheet: self didDismissWithButtonIndex:nTag];
}

- (void) dealloc {
	[_originalWindow release];
	[super dealloc];
}
@end
