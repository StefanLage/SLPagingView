//
//  UIColor+SLAddition.m
//  TinderLike
//
//  Created by Stefan Lage on 15/1/14.
//  Copyright (c) 2015年 Stefan Lage. All rights reserved.
//

#import "UIColor+SLAddition.h"

@implementation UIColor (SLAddition)

+ (UIColor *)gradient:(double)percent top:(double)topX bottom:(double)bottomX init:(UIColor*)init goal:(UIColor*)goal {
    double t = (percent - bottomX) / (topX - bottomX);
    
    t = MAX(0.0, MIN(t, 1.0));
    
    const CGFloat *cgInit = CGColorGetComponents(init.CGColor);
    const CGFloat *cgGoal = CGColorGetComponents(goal.CGColor);
    
    double r = cgInit[0] + t * (cgGoal[0] - cgInit[0]);
    double g = cgInit[1] + t * (cgGoal[1] - cgInit[1]);
    double b = cgInit[2] + t * (cgGoal[2] - cgInit[2]);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
