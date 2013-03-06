//
//  BsToggleButton.h
//  StickWars - Siege
//
//  Created by EricH on 8/3/09.
//
 
#import "cocos2d.h"


@interface BsToggleButton: CCMenu {
}

+ (BsToggleButton*)buttonWithImage:(NSString*)normalImage 
					selected:(NSString*)selectedImage 
					  target:(id)target
					selector:(SEL)sel;

- (void)setEnable:(BOOL)bEnable;
- (void)setState:(BOOL)state;
- (BOOL)state;

@end
 
