//
//  AppDelegate.h
//  TwitterLike
//
//  Created by Stefan Lage on 24/11/14.
//  Copyright (c) 2014 Stefan Lage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *rootViewController;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

