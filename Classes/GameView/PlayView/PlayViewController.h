//
//  PlayViewController.h
//  StackEM
//
//  Created by YunCholHo on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RevMobAds/RevMobAds.h>
@class CCScene;

@interface PlayViewController : UIViewController<RevMobAdsDelegate> {
	CCScene* m_pView;
}

- (void) initView;

@end
