//
//  MyButton.m
//  StackEM
//
//  Created by YunCholHo on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyButton.h"


@implementation MyButton

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void) setImages:(NSString*) img Background:(NSString*) backImg {
	[self setBackgroundImage:[UIImage imageNamed:backImg] forState:UIControlStateNormal];

	UIImage* image = [UIImage imageNamed:img];
	if (image == nil)
		return;
	CGSize sizeImage = image.size;
	CGRect rect = self.frame;
	CGFloat xScale = rect.size.width * 3 / 5 / sizeImage.width;
	CGFloat yScale = rect.size.height * 3 / 5 / sizeImage.height;
	if (xScale > yScale)
		xScale = yScale;
	UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sizeImage.width * xScale, sizeImage.height * xScale)];
	view.center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
	view.image = image;
	[self addSubview:view];
	[view release];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}*/

- (void)dealloc {
    [super dealloc];
}


@end
