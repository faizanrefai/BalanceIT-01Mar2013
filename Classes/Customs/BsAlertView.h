//
//  BSActionSheet.h
//  IQGomoku
//
//  Created by KCU on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@protocol BsAlertViewDelegate;

@interface BsAlertView : CCColorLayer {
@private
	CCSprite  *_originalWindow;
    id <BsAlertViewDelegate> _delegate;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<BSAlertViewDelegate>*/)delegate otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@property(nonatomic,assign) id _delegate;
@property(nonatomic,copy) NSString *_title;
@property(nonatomic,copy) NSString *_message;   // secondary explanation text

// shows popup alert animated.
- (void)showInLayer: (CCLayer*) Owner;
@end

@protocol BsAlertViewDelegate <NSObject>
@optional
- (void)BsAlertView:(BsAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end