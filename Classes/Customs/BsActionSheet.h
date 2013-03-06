//
//  BSActionSheet.h
//  IQGomoku
//
//  Created by KCU on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol BsActionSheetDelegate;

typedef enum {
    BSActionSheetStyleAutomatic        = -1,       // take appearance from toolbar style otherwise uses 'default'
    BSActionSheetStyleDefault,
    BSActionSheetStyleBlackTranslucent,
    BSActionSheetStyleBlackOpaque,
} BsActionSheetStyle;

@interface BsActionSheet : CCColorLayer {
@private
    id <BsActionSheetDelegate> _delegate;
    CCSprite  *_originalWindow;
	NSString *_title;
    BsActionSheetStyle _actionSheetStyle;
}

- (id)initWithTitle:(NSString *)title delegate:(id<BsActionSheetDelegate>)delegate otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@property(nonatomic,assign) id<BsActionSheetDelegate> _delegate;    // weak reference
@property(nonatomic,copy) NSString *_title;
@property(nonatomic) BsActionSheetStyle _actionSheetStyle; // default is UIActionSheetStyleAutomatic. ignored if alert is visible

- (void)showInLayer: (CCLayer*) Owner;

@end


@protocol BsActionSheetDelegate <NSObject>
@optional
- (void)actionSheet:(BsActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end

