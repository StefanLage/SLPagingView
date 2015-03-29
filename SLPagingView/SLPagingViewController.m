//
//  SLPagingViewController.m
//  SLPagingView
//
//  Created by Stefan Lage on 20/11/14.
//  Copyright (c) 2014 Stefan Lage. All rights reserved.
//

#import "SLPagingViewController.h"

@interface SLPagingViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *navItemsViews;
@property (nonatomic) BOOL needToShowPageControl;
@property (nonatomic) BOOL isUserInteraction;
@property (nonatomic) NSInteger indexSelected;

@end

@implementation SLPagingViewController

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initCrucialObjects:[UIColor whiteColor]
                 showPageControl:NO];
    }
    return self;
}

#pragma mark - constructors with views

-(id)initWithNavBarItems:(NSArray*) items views:(NSArray*)views{
    return [self initWithNavBarItems:items
                    navBarBackground:[UIColor whiteColor]
                               views:views
                     showPageControl:YES];
}

-(id)initWithNavBarItems:(NSArray*)items views:(NSArray*)views showPageControl:(BOOL)addPageControl{
    return [self initWithNavBarItems:items
                    navBarBackground:[UIColor whiteColor]
                               views:views
                     showPageControl:addPageControl];
}

-(id)initWithNavBarItems:(NSArray*)items navBarBackground:(UIColor*)background views:(NSArray*)views showPageControl:(BOOL)addPageControl{
    self = [super init];
    if(self){
        [self initCrucialObjects:background
                 showPageControl:addPageControl];
        int i                         = 0;
        for(i=0; i<items.count; i++){
            // Be sure items contains only UIView's object
            if([[items objectAtIndex:i] isKindOfClass:UIView.class])
                [self addNavigationItem:[items objectAtIndex:i] tag:i];
        }
        
        // is there any controllers ?
        if(views
           && views.count > 0){
            NSMutableArray *controllerKeys = [NSMutableArray new];
            for(i=0; i < views.count; i++){
                if([[views objectAtIndex:i] isKindOfClass:UIView.class]){
                    UIView *ctr = [views objectAtIndex:i];
                    // Set the tag
                    ctr.tag = i;
                    [controllerKeys addObject:@(i)];
                }
            }
            // Number of keys equals number of controllers ?
            if(controllerKeys.count == views.count)
                _viewsDict = [[NSMutableDictionary alloc] initWithObjects:views
                                                                        forKeys:controllerKeys];
            else{
                // Something went wrong -> inform the client
                NSException *exc = [[NSException alloc] initWithName:@"View Controllers error"
                                                              reason:@"Some objects in viewControllers are not kind of UIViewController!"
                                                            userInfo:nil];
                @throw exc;
            }
        }
    }
    return self;
}

#pragma mark - constructors with controllers

-(id)initWithNavBarControllers:(NSArray *)controllers{
    return [self initWithNavBarControllers:controllers
                          navBarBackground:[UIColor whiteColor]
                           showPageControl:YES];
}

-(id)initWithNavBarControllers:(NSArray *)controllers showPageControl:(BOOL)addPageControl{
    return [self initWithNavBarControllers:controllers
                          navBarBackground:[UIColor whiteColor]
                           showPageControl:addPageControl];
}

-(id)initWithNavBarControllers:(NSArray *)controllers navBarBackground:(UIColor *)background showPageControl:(BOOL)addPageControl{
    NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:controllers.count];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:controllers.count];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:controllers.count];
    for(int i =0; i<controllers.count; i++){
        // Be sure we got s subclass of UIViewController
        if([controllers[i] isKindOfClass:UIViewController.class]){
            UIViewController *ctr = controllers[i];
            [viewControllers addObject:ctr];
            [views addObject:[ctr view]];
            // Get associated item
            UILabel *item = [UILabel new];
            [item setText:ctr.title];
            [items addObject:item];
        }
    }
    self = [self initWithNavBarItems:items
                    navBarBackground:background
                               views:views
                     showPageControl:addPageControl];
    if (self) {
        for(int i =0; i<controllers.count; i++){
            _viewControllersDict[@(i)] = controllers[i];
        }
    }
    return self;
}

#pragma mark - constructors with items & controllers

-(id)initWithNavBarItems:(NSArray *)items controllers:(NSArray *)controllers{
    return [self initWithNavBarItems:items
                    navBarBackground:[UIColor whiteColor]
                         controllers:controllers
                     showPageControl:YES];
}

-(id)initWithNavBarItems:(NSArray *)items controllers:(NSArray *)controllers showPageControl:(BOOL)addPageControl{
    return [self initWithNavBarItems:items
                    navBarBackground:[UIColor whiteColor]
                         controllers:controllers
                     showPageControl:addPageControl];
}

-(id)initWithNavBarItems:(NSArray *)items navBarBackground:(UIColor *)background controllers:(NSArray *)controllers showPageControl:(BOOL)addPageControl{
    NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:controllers.count];
    for(int i =0; i<controllers.count; i++){
        // Be sure we got s subclass of UIViewController
        if([controllers[i] isKindOfClass:UIViewController.class]){
            [views addObject:[(UIViewController*)controllers[i] view]];
        }
    }
    self = [self initWithNavBarItems:items
                    navBarBackground:background
                               views:views
                     showPageControl:addPageControl];
    if (self) {
        for(int i =0; i<controllers.count; i++){
            _viewControllersDict[@(i)] = controllers[i];
        }
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Try to load controller from storyboard
    [self loadStoryboardControllers];
    // Set up the controller
    [self setupPagingProcess];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Be notify when the device's orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [self.navigationController.navigationBar addSubview:self.navigationBarView];
    // call once manually to update items and execute custom behaviour blocks
    // for initial setup
    [self scrollViewDidScroll:self.scrollView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationBarView removeFromSuperview];
}

-(void)dealloc{
    // Remove Observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];

    // Close relationships
    _didChangedPage           = nil;
    _pagingViewMoving         = nil;
    _pagingViewMovingRedefine = nil;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.navigationBarView.frame = (CGRect){0, 0, SCREEN_SIZE.width, 44};
}

#pragma mark - public methods

-(void)updateUserInteractionOnNavigation:(BOOL)activate{
    self.isUserInteraction = activate;
}

-(void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated{
    // Be sure we got an existing index
    if(index < 0 || index > self.navigationBarView.subviews.count-1){
        NSException *exc = [[NSException alloc] initWithName:@"Index out of range"
                                                      reason:@"The index is out of range of subviews's count!"
                                                    userInfo:nil];
        @throw exc;
    }
    // save current index
    self.indexSelected = index;
    // Get the right position and update it
    CGFloat xOffset    = (index * ((int)SCREEN_SIZE.width));
    [self.scrollView setContentOffset:CGPointMake(xOffset, self.scrollView.contentOffset.y) animated:animated];
}

-(void)addViewControllers:(UIViewController *) controller needToRefresh:(BOOL) refresh{
    int tag = (int)self.viewsDict.count;
    // Try to get a navigation item
    UIView *v = nil;
    if(controller.title){
        UILabel *item = [UILabel new];
        [item setText:controller.title];
        v = item;
    }
    else if(controller.navigationItem && controller.navigationItem.titleView){
        v = controller.navigationItem.titleView;
    }
    else{
        UILabel *item = [UILabel new];
        [item setText:NSStringFromClass(controller.class)];
        v = item;
    }
    // Adds a navigation item
    [self addNavigationItem:v
                        tag:tag];
    // Save the controller
    [self.viewControllersDict setObject:controller
                                 forKey:@(tag)];
    [self.viewsDict setObject:controller.view
                             forKey:@(tag)];
    // Do we need to refresh the UI ?
    if(refresh)
       [self setupPagingProcess];
}

-(void)setNavigationBarColor:(UIColor*) color{
    if(color)
        self.navigationBarView.backgroundColor = color;
}

#pragma mark - Internal methods

-(void) initCrucialObjects:(UIColor *)background showPageControl:(BOOL) showPageControl{
    _needToShowPageControl             = showPageControl;
    _navigationBarView                 = [[UIView alloc] init];
    _navigationBarView.backgroundColor = background;
    // UserInteraction activate by default
    _isUserInteraction                 = YES;
    // Default value for the navigation style
    _navigationSideItemsStyle          = SLNavigationSideItemsStyleDefault;
    _viewsDict                         = [NSMutableDictionary new];
    _viewControllersDict               = [NSMutableDictionary new];
    _navItemsViews                     = [NSMutableArray new];
}

// Load any defined controllers from the storyboard
- (void)loadStoryboardControllers
{
    if (self.storyboard)
    {
        BOOL isThereNextIdentifier = YES;
        int idx = 0;
        while (isThereNextIdentifier) {
            @try
            {
                [self performSegueWithIdentifier:[NSString stringWithFormat:@"%@%d", SLPagingViewPrefixIdentifier, idx]
                                          sender:nil];
                idx++;
            }
            @catch(NSException *exception) {
                isThereNextIdentifier = NO;
            }
        }
        if(self.navigationController && self.navigationController.navigationBar)
            _navigationBarView.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    }
}

// Add a view as a navigationBarItem
-(void)addNavigationItem:(UIView*)v tag:(int)tag{
    CGFloat distance = (SCREEN_SIZE.width/2) - self.navigationSideItemsStyle;
    CGSize vSize = ([v isKindOfClass:[UILabel class]])? [self getLabelSize:(UILabel*)v] : v.frame.size;
    CGFloat originX = (SCREEN_SIZE.width/2 - vSize.width/2) + self.navItemsViews.count*distance;
    v.frame = (CGRect){originX, 8, vSize.width, vSize.height};
    v.tag = tag;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapOnHeader:)];
    [v addGestureRecognizer:tap];
    [v setUserInteractionEnabled:YES];
    [_navigationBarView addSubview:v];
    if(!_navItemsViews)
        _navItemsViews = [[NSMutableArray alloc] init];
    [_navItemsViews addObject:v];
}

-(void)setupPagingProcess{
    // Make our ScrollView
    CGRect frame                                              = self.view.bounds;
    UIScrollView *someScrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView                                           = someScrollView;
    self.scrollView.backgroundColor                           = [UIColor clearColor];
    self.scrollView.pagingEnabled                             = YES;
    self.scrollView.showsHorizontalScrollIndicator            = NO;
    self.scrollView.showsVerticalScrollIndicator              = NO;
    self.scrollView.delegate                                  = self;
    self.scrollView.bounces                                   = NO;
    //[self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, -80, 0)];
    [self.view addSubview:self.scrollView];
    
    // Adds all views
    [self addControllers];
    
    if(self.needToShowPageControl){
        // Make the page control
        self.pageControl               = [[UIPageControl alloc] init];
        self.pageControl.frame         = (CGRect){0, 35, 0, 0};
        self.pageControl.numberOfPages = self.navigationBarView.subviews.count;
        self.pageControl.currentPage   = 0;
        if(self.currentPageControlColor) self.pageControl.currentPageIndicatorTintColor = self.currentPageControlColor;
        if(self.tintPageControlColor) self.pageControl.pageIndicatorTintColor = self.tintPageControlColor;
        [self.navigationBarView addSubview:self.pageControl];
    }
}

// Add all views
-(void)addControllers{
    if(self.viewsDict
       && self.viewsDict.count > 0){
        float width                 = SCREEN_SIZE.width * self.viewsDict.count;
        float height                = CGRectGetHeight(self.scrollView.frame);
        self.scrollView.contentSize = (CGSize){width, height};
        // Sort all keys in ascending
        NSArray *sortedIndexes = [self.viewsDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber *key1, NSNumber *key2) {
            if ([key1 integerValue] > [key2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if ([key1 integerValue] < [key2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];

        [sortedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *v = self.viewsDict[@(idx)];
            UIViewController *vc = self.viewControllersDict[@(idx)];\
            if (vc) {
                [vc willMoveToParentViewController:self];
                [self addChildViewController:vc];
            }
            [self.scrollView addSubview:v];
            if (vc) {
                [vc didMoveToParentViewController:self];
            }
            if([self useAutoLayout:v]){
                // Using AutoLayout
                v.translatesAutoresizingMaskIntoConstraints = NO;
                // Width constraint, half of parent view width
                [self.scrollView addConstraint:
                 [NSLayoutConstraint constraintWithItem:v
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.scrollView
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1.0
                                               constant:0]];
                // Height constraint, half of parent view height
                [self.scrollView addConstraint:
                 [NSLayoutConstraint constraintWithItem:v
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.scrollView
                                              attribute:NSLayoutAttributeHeight
                                             multiplier:1.0
                                               constant:0]];
                
                [self.scrollView addConstraints:
                 [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[v]", self.view.frame.size.width * idx]
                                                         options:0
                                                         metrics:nil
                                                           views:@{@"v" : v}]];
                }
            else{
                v.frame = (CGRect){SCREEN_SIZE.width * idx, 0, SCREEN_SIZE.width, CGRectGetHeight(self.view.frame)};
            }
        }];
    }
}

// Scroll to the view tapped
-(void)tapOnHeader:(UITapGestureRecognizer *)recognizer{
    if(self.isUserInteraction){
        // Get the wanted view
        UIView *view = [self.viewsDict objectForKey:@(recognizer.view.tag)];
        [self.scrollView scrollRectToVisible:view.frame
                                    animated:YES];
    }
}

-(CGSize) getLabelSize:(UILabel *)lbl{
    return [[lbl text] sizeWithAttributes:@{NSFontAttributeName:[lbl font]}];;
}

/**
 *  Check whether the app use Auto Layout
 */
-(BOOL)useAutoLayout:(UIView*)someView{
    return someView.constraints.count;
}

#pragma mark - Internal Methods
#pragma mark - Views management

/* Update all nav items frame
 *
 * @param xOffset, abscissa of the scrollview's contentOffset
 */
-(void)updateNavItems:(CGFloat) xOffset{
    __block int i = 0;
    [self.navItemsViews enumerateObjectsUsingBlock:^(UIView* v, NSUInteger idx, BOOL *stop) {
        CGFloat distance = (SCREEN_SIZE.width/2) - self.navigationSideItemsStyle;
        CGSize vSize     = ([v isKindOfClass:[UILabel class]])? [self getLabelSize:(UILabel*)v] : v.frame.size;
        CGFloat originX  = ((SCREEN_SIZE.width/2 - vSize.width/2) + i*distance) - xOffset/(SCREEN_SIZE.width/distance);
        v.frame          = (CGRect){originX, 8, vSize.width, vSize.height};
        i++;
    }];
}

// Adapt all views the main screen
-(void)adaptViews{
    // Update the nav items + the scrollview
    [self updateNavItems:self.scrollView.contentOffset.x];
    // Be sure to stay on the same view
    [self setCurrentIndex:self.indexSelected
                 animated:NO];
    [self.scrollView setNeedsUpdateConstraints];
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - Internal Methods
#pragma mark - Notifications

// Call when the screen orientation is updated
- (void)orientationChanged:(NSNotification *)notification{
    [self adaptViews];
}

#pragma mark - SLPagingViewDidChanged delegate

-(void)sendNewIndex:(UIScrollView *)scrollView{
    CGFloat xOffset    = scrollView.contentOffset.x;
    self.indexSelected = ((int) roundf(xOffset) % (self.navigationBarView.subviews.count * (int)SCREEN_SIZE.width)) / SCREEN_SIZE.width;
    if(self.pageControl){
        if (self.pageControl.currentPage != self.indexSelected)
        {
            self.pageControl.currentPage = self.indexSelected;
            if(self.didChangedPage)
                self.didChangedPage(self.indexSelected);
        }
    }
    else{
        if(self.didChangedPage)
            self.didChangedPage(self.indexSelected);
    }
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update nav items
    [self updateNavItems:scrollView.contentOffset.x];
    if(self.pagingViewMoving)
        // Customize the navigation items
        self.pagingViewMoving(self.navItemsViews);
    if(self.pagingViewMovingRedefine)
        // Wants to redefine all behaviors
        self.pagingViewMovingRedefine(scrollView, self.navItemsViews);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self sendNewIndex:scrollView];
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self sendNewIndex:scrollView];
}

@end

#pragma mark - SLPagingViewControllerSegueSetController segue identifier's prefix

NSString * const SLPagingViewPrefixIdentifier = @"sl_";

#pragma mark - SLPagingViewControllerSegueSetController class

@implementation SLPagingViewControllerSegueSetController

-(void)perform{
    // Get SLPagingViewController (sourceViewController)
    SLPagingViewController *src = self.sourceViewController;
    // Add it to the subviews
    if(self.destinationViewController)
        [src addViewControllers:self.destinationViewController
                  needToRefresh:NO];
}

@end
