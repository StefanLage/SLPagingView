//
//  NSDictionary+Minus.m
//  NewSLPagingView
//
//  Created by Stefan Lage on 20/02/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import "NSMutableDictionary+Minus.h"

@implementation NSMutableDictionary (Minus)

-(void) minusDictionary:(NSDictionary*)otherDictionary{
    NSMutableSet *setA = [NSMutableSet setWithArray:self.allKeys];
    NSMutableSet *setB = [NSMutableSet setWithArray:otherDictionary.allKeys];
    // Get the right keys to remove
    [setA intersectSet:setB];
    [self removeObjectsForKeys:setA.allObjects];
}

@end
