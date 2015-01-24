//
//  UIColor+SLAddition.h
//  TinderLike
//
//  Created by Stefan Lage on 15/1/14.
//  Copyright (c) 2015年 Stefan Lage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SLAddition)

+ (UIColor *)gradient:(double)percent top:(double)topX bottom:(double)bottomX init:(UIColor*)init goal:(UIColor*)goal;

@end
