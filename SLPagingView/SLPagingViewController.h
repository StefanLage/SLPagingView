//
//  SLPagingViewController.h
//  SLPagingView
//
//  Created by Stefan Lage on 20/11/14.
//  Copyright (c) 2014 Stefan Lage. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SLPagingViewMoving)(UIScrollView * scrollView, NSArray *subviews);
typedef void(^SLPagingViewDidChanged)(NSInteger currentPage);

@interface SLPagingViewController : UIViewController

/*
 *  Delegate: Called when the user scroll horizontally
 *  Allow to customized the behaviors
 *
 *  @param scrollView
 *  @param subviews, all subviews contains in the navigations bar
 */
@property (nonatomic, copy) SLPagingViewMoving pagingViewMoving;
/*
 *  Delegate: Inform when the page changed
 *  
 *  @param currentPage
 */
@property (nonatomic, copy) SLPagingViewDidChanged didChangedPage;
/*
 *  Contains all views displayed
 */
@property (nonatomic, strong) NSDictionary *viewControllers;
/*
 *  Tint color of the page control
 */
@property (nonatomic, strong) UIColor *tintPageControlColor;
/*
 *  Color of the current page (page control)
 */
@property (nonatomic, strong) UIColor *currentPageControlColor;


/*
 *  SLPagingViewController's constructor
 *
 *  @param items should contain all subviews of the navigation bar
 *  @param views all subviews corresponding to each page
 *
 *  @return Instance of SLPagingViewController
 */
-(id)initWithNavBarItems:(NSArray*)items views:(NSArray*)views;

/*
 *  SLPagingViewController's constructor
 *
 *  @param items should contain all subviews of the navigation bar
 *  @param views all subviews corresponding to each page
 *  @param showPageControl inform if we need to display the page control in the navigation bar
 *
 *  @return Instance of SLPagingViewController
 */
-(id)initWithNavBarItems:(NSArray*)items views:(NSArray*)views showPageControl:(BOOL)addPageControl;

/*
 *  SLPagingViewController's constructor
 *
 *  @param items should contain all subviews of the navigation bar
 *  @param navBarBackground navigation bar's background color
 *  @param views all subviews corresponding to each page
 *  @param showPageControl inform if we need to display the page control in the navigation bar
 *  
 *  @return Instance of SLPagingViewController
 */
-(id)initWithNavBarItems:(NSArray*)items navBarBackground:(UIColor*)background views:(NSArray*)views showPageControl:(BOOL)addPageControl;

/*
 *  Update the state of the UserInteraction on the navigation bar
 *
 *  @param activate state you want to set to UserInteraction
 */
-(void)updateUserInteractionOnNavigation:(BOOL)activate;


@end
