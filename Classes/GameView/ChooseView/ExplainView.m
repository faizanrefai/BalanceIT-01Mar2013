//
//  ExplainView.m
//  StackEM
//
//  Created by YunCholHo on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ExplainView.h"


@implementation ExplainView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (id) init {
	UIImage* img = [UIImage imageNamed:@"topExp.png"];
	CGRect rc = CGRectMake(0, 0, img.size.width * RATE_WIDTH1, img.size.height * RATE_HEIGHT1);
	if ((self = [super initWithFrame:rc])) {
		self.image = img;
		self.userInteractionEnabled = YES;
		
		UILabel* content = [[UILabel alloc] initWithFrame:CGRectMake(0, 20 * RATE_HEIGHT1, rc.size.width, rc.size.height - 40 * RATE_HEIGHT1)];
		content.text = @"Please select object to stack & balance.";
		content.textAlignment = UITextAlignmentCenter;
		content.textColor = [UIColor whiteColor];
		content.backgroundColor = [UIColor clearColor];
		content.font = [UIFont systemFontOfSize:(40 * RATE_HEIGHT1)];
		[self addSubview:content];
		[content release];
	}
	
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
