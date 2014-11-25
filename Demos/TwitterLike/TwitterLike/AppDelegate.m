//
//  AppDelegate.m
//  TwitterLike
//
//  Created by Stefan Lage on 24/11/14.
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
    
    self.dataSource = [[NSMutableArray alloc] initWithArray:@[@"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!",
                                                              @"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!",
                                                              @"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!",
                                                              @"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!",
                                                              @"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!"]];
    
    UILabel *navTitleLabel1 = [UILabel new];
    navTitleLabel1.text = @"Home";
    navTitleLabel1.font = [UIFont fontWithName:@"Helvetica" size:20];
    navTitleLabel1.textColor = [UIColor whiteColor];
    
    UILabel *navTitleLabel2 = [UILabel new];
    navTitleLabel2.text = @"Discover";
    navTitleLabel2.font = [UIFont fontWithName:@"Helvetica" size:20];
    navTitleLabel2.textColor = [UIColor whiteColor];
    
    UILabel *navTitleLabel3 = [UILabel new];
    navTitleLabel3.text = @"Activity";
    navTitleLabel3.font = [UIFont fontWithName:@"Helvetica" size:20];
    navTitleLabel3.textColor = [UIColor whiteColor];
    
    SLPagingViewController *pageViewController = [[SLPagingViewController alloc] initWithNavBarItems:@[navTitleLabel1, navTitleLabel2, navTitleLabel3]
                                                                                    navBarBackground:[UIColor colorWithRed:0.33 green:0.68 blue:0.91 alpha:1.000]
                                                                                               views:@[[self tableView], [self tableView], [self tableView]]
                                                                                     showPageControl:YES];
    [pageViewController setCurrentPageControlColor:[UIColor whiteColor]];
    [pageViewController setTintPageControlColor:[UIColor colorWithWhite:0.799 alpha:1.000]];
    [pageViewController updateUserInteractionOnNavigation:NO];
    
    // Twitter Like
    pageViewController.pagingViewMoving = ^(UIScrollView *scrollView, NSArray *subviews){
        CGFloat xOffset = scrollView.contentOffset.x;
        int i = 0;
        for(UILabel *v in subviews){
            CGFloat alpha = 0.0;
            if(v.frame.origin.x < 145)
                alpha = 1 - (xOffset - i*320) / 320;
            else if(v.frame.origin.x >145)
                alpha=(xOffset - i*320) / 320 + 1;
            else if(v.frame.origin.x == 140)
                alpha = 1.0;
            i++;
            v.alpha = alpha;
        }
    };
    
    pageViewController.didChangedPage = ^(NSInteger currentPageIndex){
        // Do something
        NSLog(@"index %ld", (long)currentPageIndex);
    };
    
    self.nav = [[UINavigationController alloc] initWithRootViewController:pageViewController];
    [self.window setRootViewController:self.nav];
    self.window.backgroundColor = [UIColor colorWithRed:0.33 green:0.68 blue:0.91 alpha:1.000];
    [self.window makeKeyAndVisible];
    
    [self setWindow:self.window];
    
    return YES;
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

- (UITableView*)tableView {
        CGRect tableViewFrame = CGRectMake(0, 0, 320, 568);
        tableViewFrame.size.height -= 44;
        UITableView *tableView = [[UITableView alloc] initWithFrame:tableViewFrame
                                                              style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView setScrollsToTop:NO];
    return tableView;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell           = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell                         = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                              reuseIdentifier:cellIdentifier];
        cell.textLabel.numberOfLines = 0;
    }
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"avatar_%d.jpg", (indexPath.row % 3)]];
    cell.textLabel.text  = self.dataSource[indexPath.row];
    
    return cell;
}

@end
