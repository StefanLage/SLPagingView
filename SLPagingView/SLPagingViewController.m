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
@property (nonatomic, strong) UIView *navigationBarView;
@property (nonatomic, strong) NSMutableArray *subviews;
@property (nonatomic) BOOL needToShowPageControl;
@property (nonatomic) BOOL isUserInteraction;

@end

@implementation SLPagingViewController

/*
 *  @param items should contain all subviews of the navigation bar
 */
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
        _needToShowPageControl = addPageControl;
        _navigationBarView     = [[UIView alloc] init];
        [_navigationBarView setBackgroundColor:background];
        // UserInteraction activate by default
        self.isUserInteraction = YES;

        int x                  = 140;
        int i                  = 0;
        for(i=0; i<items.count; i++){
            // Be sure items contains only UIView's object
            if([[items objectAtIndex:i] isKindOfClass:UIView.class]){
                UIView * v = [items objectAtIndex:i];
                v.frame    = (CGRect){x, 8, CGRectGetWidth(v.frame), CGRectGetHeight(v.frame)};
                v.tag      = i;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(tapOnHeader:)];
                [v addGestureRecognizer:tap];
                [v setUserInteractionEnabled:YES];
                [_navigationBarView addSubview:v];
                x += 100;
                if(!_subviews)
                    _subviews = [[NSMutableArray alloc] init];
                [_subviews addObject:[items objectAtIndex:i]];
            }
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
                _viewControllers = [[NSDictionary alloc] initWithObjects:views
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

- (void)loadView {
    [super loadView];
    [self setupPagingProcess];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.navigationBarView.frame = (CGRect){0, 0, 320, 44};    
}

#pragma mark - public methods

-(void)updateUserInteractionOnNavigation:(BOOL)activate{
    self.isUserInteraction = activate;
}

#pragma mark - Internal methods

-(void)setupPagingProcess{
    // Make our ScrollView
    self.scrollView                                = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.backgroundColor                = [UIColor clearColor];
    self.scrollView.pagingEnabled                  = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator   = NO;
    self.scrollView.delegate                       = self;
    self.scrollView.bounces                        = NO;
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
        float width                 = 320 * self.viewControllers.count;
        float height                = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationBarView.frame);
        self.scrollView.contentSize = (CGSize){width, height};
        
        NSEnumerator *enumerator    = [self.viewControllers keyEnumerator];
        id key;
        int i =0;
        while((key = [enumerator nextObject])){
            UIView *v = [self.viewControllers objectForKey:key];
            v.frame   = (CGRect){320 * i, 0, 320, CGRectGetHeight(self.view.frame)};
            [self.scrollView addSubview:v];
            i++;
        }
            
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

#pragma mark - SLPagingViewDidChanged delegate

-(void)sendNewIndex:(UIScrollView *)scrollView{
    if(self.needToShowPageControl){
        CGFloat xOffset  = scrollView.contentOffset.x;
        int currentIndex = ((int) roundf(xOffset) % (self.navigationBarView.subviews.count *320)) / 320;
        self.pageControl.currentPage = currentIndex;
        if(self.didChangedPage)
            self.didChangedPage(currentIndex);
    }
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.pagingViewMoving)
        self.pagingViewMoving(scrollView, self.subviews);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self sendNewIndex:scrollView];
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self sendNewIndex:scrollView];
}

@end
