//
//  AppDelegate.m
//  TinderLike
//
//  Created by Stefan Lage on 25/11/14.
//  Copyright (c) 2014 Stefan Lage. All rights reserved.
//

#import "AppDelegate.h"
#import "SLPagingViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) UINavigationController *nav;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIColor *orange = [UIColor colorWithRed:255/255
                                      green:69.0/255
                                       blue:0.0/255
                                      alpha:1.0];
    
    UIColor *gray = [UIColor colorWithRed:.84
                                    green:.84
                                     blue:.84
                                    alpha:1.0];
    
    // Make views for the navigation bar
    UIImage *img1 = [UIImage imageNamed:@"gear"];
    img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIImage *img2 = [UIImage imageNamed:@"profile"];
    img2 = [img2 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIImage *img3 = [UIImage imageNamed:@"chat"];
    img3 = [img3 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    SLPagingViewController *pageViewController = [[SLPagingViewController alloc] initWithNavBarItems:@[[[UIImageView alloc] initWithImage:img1], [[UIImageView alloc] initWithImage:img2], [[UIImageView alloc] initWithImage:img3]]
                                                                                    navBarBackground:[UIColor whiteColor]
                                                                                               views:@[[self viewWithBackground:orange], [self viewWithBackground:[UIColor yellowColor]], [self viewWithBackground:gray]]
                                                                                     showPageControl:NO];
    // Tinder Like
    pageViewController.pagingViewMoving = ^(NSArray *subviews){
        int i = 0;
        for(UIImageView *v in subviews){
            UIColor *c = gray;
            if(v.frame.origin.x > 45
               && v.frame.origin.x < 145)
                // Left part
                c = [self gradient:v.frame.origin.x
                               top:46
                            bottom:144
                              init:orange
                              goal:gray];
            else if(v.frame.origin.x > 145
                    && v.frame.origin.x < 245)
                // Right part
                c = [self gradient:v.frame.origin.x
                               top:146
                            bottom:244
                              init:gray
                              goal:orange];
            else if(v.frame.origin.x == 145)
                c = orange;
            v.tintColor= c;
            i++;
        }
     };
    
    self.nav = [[UINavigationController alloc] initWithRootViewController:pageViewController];
    [self.window setRootViewController:self.nav];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setWindow:self.window];
    return YES;
}

-(UIColor *)gradient:(double)percent top:(double)topX bottom:(double)bottomX init:(UIColor*)init goal:(UIColor*)goal{
    double t = (percent - bottomX) / (topX - bottomX);

    t = MAX(0.0, MIN(t, 1.0));
    
    const CGFloat *cgInit = CGColorGetComponents(init.CGColor);
    const CGFloat *cgGoal = CGColorGetComponents(goal.CGColor);
    
    double r = cgInit[0] + t * (cgGoal[0] - cgInit[0]);
    double g = cgInit[1] + t * (cgGoal[1] - cgInit[1]);
    double b = cgInit[2] + t * (cgGoal[2] - cgInit[2]);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

-(UIView*)viewWithBackground:(UIColor *)color{
    UIView *v = [UIView new];
    v.backgroundColor = color;
    return v;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
