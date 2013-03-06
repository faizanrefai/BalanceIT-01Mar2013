//
//  BSAlertView.m
//  IQGomoku
//
//  Created by KCU on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BsAlertView.h"
#import "BsButton.h"
#define ZOrder	1000
#define RES_WINDOW	@"bsmessagebox.png"
#define kTagStart	2000

@implementation BsAlertView
@synthesize _delegate;  
@synthesize _title;
@synthesize _message;   

- (void) createSubButtons:(NSString*) firstTitle vaList:(va_list) params {
	int i = 1;
	if (firstTitle == nil)
		return;
	BsButton* menuItem = [BsButton buttonWithString: firstTitle
											 normal:@"bsshortbutton.png" 
										   selected: @"bsshortbuttonf.png" 
											 target:self
										   selector:@selector(menuCallbackEnable:)
												tag:kTagStart];
	[menuItem setPosition: ccp(70, 440)];	
	[_originalWindow addChild: menuItem];
	
	NSString*l = va_arg(params,NSString*);
	while(l) {
		menuItem = [BsButton buttonWithString: l
									   normal:@"bsshortbutton.png" 
									 selected: @"bsshortbuttonf.png" 
									   target:self
									 selector:@selector(menuCallbackEnable:)
										  tag:kTagStart+i];
		i ++;
		[menuItem setPosition: ccp(186, 440)];
		
		[_originalWindow addChild: menuItem];
		l = va_arg(params,NSString*);
	}	
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<BSAlertViewDelegate>*/)delegate otherButtonTitles:(NSString *)otherButtonTitles, ... {
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	[self initWithColor: ccc4(0, 0, 0, 70)];
	self._delegate = delegate;
	_originalWindow = [[CCSprite alloc] initWithFile:RES_WINDOW];
	[_originalWindow setPosition: ccp(size.width/2, size.height/2)];
	[self addChild: _originalWindow];	
	
	CGRect rtWindow = [_originalWindow textureRect];
	float nCenterX = rtWindow.origin.x + CGRectGetWidth(rtWindow)/2;
	CCLabelTTF* label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:18];
	ccColor3B color;
	color.r = 255;
	color.g = 255;
	color.b = 255;
	[label setColor: color];
	[label setPosition: ccp(nCenterX, 340)];
	[_originalWindow addChild: label];
	va_list args;
	va_start(args,otherButtonTitles);
	
	[self createSubButtons:otherButtonTitles vaList:args];
	
	va_end(args);	
	
	return self;
}

- (NSInteger)addButtonWithTitle:(NSString *)title {
	return 0;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex {
	return 0;
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
	
	id scaleAction = [CCScaleTo actionWithDuration:.5 scaleX:1.0f scaleY:.0];
	id removeAction = [CCCallFuncND actionWithTarget: self selector: @selector(removeCallBack:data:) data: (void*)sender];
	id seq = [CCSequence actions: scaleAction, removeAction, nil];
	[_originalWindow runAction: seq];
}

- (void) removeCallBack: (id) sender data: (void*) data{
	[self removeFromParentAndCleanup: YES];	
	if (self._delegate == nil)
		return;
	BsButton* aButton = (BsButton*)data;
	int nTag = aButton.tag - kTagStart;	
	[self._delegate BsAlertView:self didDismissWithButtonIndex:nTag];  // after animation

}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
}

- (void) dealloc {
	[_originalWindow release];
	[super dealloc];
}

@end
