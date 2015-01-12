//
//  SLPagingViewController.m
//  SLPagingView
//
//  Created by Stefan Lage on 20/11/14.
//  Copyright (c) 2014 Stefan Lage. All rights reserved.
//

#import "SLPagingViewController.h"

#define SCREEN_SIZE [[UIScreen mainScreen] bounds].size

@interface SLPagingViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *navigationBarView;
@property (nonatomic, strong) NSMutableArray *subviews;
@property (nonatomic) BOOL needToShowPageControl;
@property (nonatomic) BOOL isUserInteraction;
@property (nonatomic) NSInteger indexSelected;

@end

@implementation SLPagingViewController

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
        [self initCrucialObjects:background];
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
                else if([[views objectAtIndex:i] isKindOfClass:UIViewController.class]){
                    UIViewController *ctr = [views objectAtIndex:i];
                    // Set the tag
                    ctr.view.tag = i;
                    [controllerKeys addObject:@(i)];
                }
            }
            // Number of keys equals number of controllers ?
            if(controllerKeys.count == views.count)
                _viewControllers = [[NSMutableDictionary alloc] initWithObjects:views
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
    for(int i =0; i<controllers.count; i++){
        // Be sure we got s subclass of UIViewController
        if([controllers[i] isKindOfClass:UIViewController.class]){
            UIViewController *ctr = controllers[i];
            [views addObject:[ctr view]];
            // Get associated item
            UILabel *item = [UILabel new];
            [item setText:ctr.title];
            [items addObject:item];
        }
    }
    return [self initWithNavBarItems:items
                    navBarBackground:background
                               views:views
                     showPageControl:addPageControl];
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
        if([controllers[i] isKindOfClass:UIViewController.class])
            [views addObject:[(UIViewController*)controllers[i] view]];
    }
    return [self initWithNavBarItems:items
                    navBarBackground:background
                               views:views
                     showPageControl:addPageControl];
}

#pragma mark - LifeCycle

- (void)loadView {
    [super loadView];
    [self setupPagingProcess];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setCurrentIndex:self.indexSelected
                 animated:NO];
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
    int tag = (int)self.viewControllers.count;
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
    // Adds a navigation item
    [self addNavigationItem:v
                        tag:tag];
    // Save the controller
    [self.viewControllers setObject:controller.view
                             forKey:@(tag)];
    // Do we need to refresh the UI ?
    if(refresh)
       [self setupPagingProcess];
}

#pragma mark - Internal methods

-(void) initCrucialObjects:(UIColor *)background{
    _needToShowPageControl             = NO;
    _navigationBarView                 = [[UIView alloc] init];
    _navigationBarView.backgroundColor = background;
    // UserInteraction activate by default
    _isUserInteraction                 = YES;
    // Default value for the navigation style
    _navigationSideItemsStyle          = SLNavigationSideItemsStyleDefault;
    _viewControllers                   = [NSMutableDictionary new];
    _subviews                          = [NSMutableArray new];
}

// Add a view as a navigationBarItem
-(void)addNavigationItem:(UIView*)v tag:(int)tag{
    CGSize vSize                = ([v isKindOfClass:[UILabel class]])? [self getLabelSize:(UILabel*)v] : v.frame.size;
    CGFloat originX             = (SCREEN_SIZE.width/2 - vSize.width/2) + self.subviews.count*(100 + self.navigationSideItemsStyle);
    v.frame                     = (CGRect){originX, 8, vSize.width, vSize.height};
    v.tag                       = tag;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapOnHeader:)];
    [v addGestureRecognizer:tap];
    [v setUserInteractionEnabled:YES];
    [_navigationBarView addSubview:v];
    if(!_subviews)
        _subviews = [[NSMutableArray alloc] init];
    [_subviews addObject:v];
}

-(void)setupPagingProcess{
    // Make our ScrollView
    CGRect frame                                   = CGRectMake(0, 0, SCREEN_SIZE.width, self.view.frame.size.height);
    self.scrollView                                = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.backgroundColor                = [UIColor clearColor];
    self.scrollView.pagingEnabled                  = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator   = NO;
    self.scrollView.delegate                       = self;
    self.scrollView.bounces                        = NO;
    [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, -80, 0)];
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
    [self.navigationController.navigationBar addSubview:self.navigationBarView];
}

// Add all views
-(void)addControllers{
    if(self.viewControllers
       && self.viewControllers.count > 0){
        float width                 = SCREEN_SIZE.width * self.viewControllers.count;
        float height                = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationBarView.frame);
        self.scrollView.contentSize = (CGSize){width, height};
        __block int i               = 0;
        [self.viewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            UIView *v = [self.viewControllers objectForKey:key];
            v.frame   = (CGRect){SCREEN_SIZE.width * i, 0, SCREEN_SIZE.width, CGRectGetHeight(self.view.frame)-60};
            [self.scrollView addSubview:v];
            i++;
        }];
    }
}

// Scroll to the view tapped
-(void)tapOnHeader:(UITapGestureRecognizer *)recognizer{
    if(self.isUserInteraction){
        // Get the wanted view
        UIView *view = [self.viewControllers objectForKey:@(recognizer.view.tag)];
        [self.scrollView scrollRectToVisible:view.frame
                                    animated:YES];
    }
}

-(CGSize) getLabelSize:(UILabel *)lbl{
    return [[lbl text] sizeWithAttributes:@{NSFontAttributeName:[lbl font]}];;
}

#pragma mark - SLPagingViewDidChanged delegate

-(void)sendNewIndex:(UIScrollView *)scrollView{
    CGFloat xOffset              = scrollView.contentOffset.x;
    int currentIndex             = ((int) roundf(xOffset) % (self.navigationBarView.subviews.count * (int)SCREEN_SIZE.width)) / SCREEN_SIZE.width;
    if (self.pageControl.currentPage != currentIndex)
    {
        self.pageControl.currentPage = currentIndex;
        if(self.didChangedPage)
            self.didChangedPage(currentIndex);
    }
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat xOffset = scrollView.contentOffset.x;
    int i = 0;
    for(UIView *v in self.subviews){
        CGFloat distance = 100 + self.navigationSideItemsStyle;
        CGSize vSize     = ([v isKindOfClass:[UILabel class]])? [self getLabelSize:(UILabel*)v] : v.frame.size;
        CGFloat originX  = ((SCREEN_SIZE.width/2 - vSize.width/2) + i*distance) - xOffset/(SCREEN_SIZE.width/distance);
        v.frame          = (CGRect){originX, 8, vSize.width, vSize.height};
        i++;
    }
    if(self.pagingViewMoving)
        // Customize the navigation items
        self.pagingViewMoving(self.subviews);
    if(self.pagingViewMovingRedefine)
        // Wants to redefine all behaviors
        self.pagingViewMovingRedefine(scrollView, self.subviews);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self sendNewIndex:scrollView];
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self sendNewIndex:scrollView];
}

@end
