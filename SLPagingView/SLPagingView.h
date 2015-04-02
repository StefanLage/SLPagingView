//
//  SLPagingView.h
//  NewSLPagingView
//
//  Created by Stefan Lage on 16/02/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Instance of SLSuperPagingView
 */
@interface SLSuperPagingView : UIScrollView

@property (nonatomic, readonly) NSUInteger currentIndex;

-(id)dequeueReusableViewWithIdentifier:(NSUInteger)identifier;
-(void)moveToViewAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end

//_______________________________________________________________________________________________________________

@class SLPagingView;

/**
 *  SLPagingViewDelegate
 *
 *  Represents the display and behaviours of the views
 */
@protocol SLPagingViewDelegate <NSObject, UIScrollViewDelegate>

@optional
-(void)willMoveToView:(UIView*)view fromIndex:(NSUInteger)lastIndex toIndex:(NSUInteger)index;
-(void)didMoveToView:(UIView*)view atIndex:(NSUInteger)index;

@end

/**
 *  SLPagingViewDataSource
 *
 *  Represents the data model object
 */
@protocol SLPagingViewDataSource <NSObject>

@required
-(NSInteger)numberOfViewInPagingView:(SLPagingView*)pagingView;
-(UIView*)pagingView:(SLPagingView*)pagingView viewAtIndex:(NSUInteger)index;

@optional
-(CGFloat)heightForViews;
-(CGFloat)origin;

@end

/**
 *  Instance of SLPagingView
 */
@interface SLPagingView : SLSuperPagingView

@property (nonatomic, weak) id<SLPagingViewDataSource> dataSource;
@property (nonatomic, weak) id<SLPagingViewDelegate> pagingViewDelegate;

@end

//_______________________________________________________________________________________________________________

typedef NS_ENUM(NSInteger, SLNavigationAlignment) {
    LeftPosition,
    CenterPosition
};

typedef NS_ENUM(NSInteger, SLNavigationSpaceBetweenItems) {
    SLNavigationSideItemsStyleOnBounds = 150,
    SLNavigationSideItemsStyleClose = 70,
    SLNavigationSideItemsStyleNormal = 80,
    SLNavigationSideItemsStyleFar = 90,
    SLNavigationSideItemsStyleDefault = 60,
    SLNavigationSideItemsStyleCloseToEachOne = 100
};

@class SLPagingViewHeader;

/**
 *  SLPagingViewHeaderDataSource
 *
 *  Represents the data model object
 */
@protocol SLPagingViewHeaderDataSource <NSObject>

-(NSInteger)numberOfHeadersInPagingViewHeader:(SLPagingViewHeader*)pagingViewHeader;
-(UIView*)pagingViewHeader:(SLPagingViewHeader*)paginViewHeader viewAtIndex:(NSUInteger)index;

@optional
-(CGFloat)widthViewForIndex:(NSUInteger)index;
-(CGFloat)originXForIndex:(NSInteger)index;
-(CGFloat)originYForIndex:(NSInteger)index;
-(void)needToMoveToIndex:(NSUInteger)index;

@end

/**
 *  Instance of SLPagingViewHeader
 */
@interface SLPagingViewHeader : SLSuperPagingView

@property (nonatomic, weak) id<SLPagingViewHeaderDataSource> dataSource;
@property (nonatomic) SLNavigationAlignment navigationAlignment;
@property (nonatomic) SLNavigationSpaceBetweenItems navigationItemsSpace;

-(void)updateView;
-(void)updatePosition:(CGFloat)contentOffsetX width:(CGFloat)width;
-(void)updateIndex:(NSUInteger)index;

@end