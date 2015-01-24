//
//  UIScrollView+UpdateContentSize.m
//  TinderStoryboard
//
//  Created by Stefan Lage on 23/01/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import "UIScrollView+UpdateContentSize.h"

@implementation UIScrollView (UpdateContentSize)

// Scale the content size depending on its frame
-(void)updateContentSize{
    float nWidth     = SCREEN_SIZE.width * self.subviews.count;
    float nHeight    = (self.subviews.count > 0) ? CGRectGetHeight([(UIView*)self.subviews[0] frame]):CGRectGetHeight(self.frame);
    self.contentSize = (CGSize){nWidth, nHeight};
}

#pragma mark - OVERRIDE

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    // Scale the content size
    [self updateContentSize];
}

-(void)updateConstraints{
    [super updateConstraints];
    // Scale the content size
    [self updateContentSize];
}

@end
