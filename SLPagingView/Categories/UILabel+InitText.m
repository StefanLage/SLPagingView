//
//  UILabel+InitText.m
//  NewSLPagingView
//
//  Created by Stefan Lage on 11/03/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import "UILabel+InitText.h"

@implementation UILabel (InitText)

- (instancetype)initWithText:(NSString*)text{
    self = [super init];
    if(self)
       [self setText:text];
    return self;
}

@end
