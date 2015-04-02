//
//  SLPagingView.m
//  NewSLPagingView
//
//  Created by Stefan Lage on 16/02/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import "SLPagingView.h"
#import "NSMutableDictionary+Minus.h"
#import <objc/runtime.h>

/**
 *  Swizzle removeFromSuperView
 */
@implementation UIView (SwizzleRemoveFromSuperview)

+(void)load{
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        Class class                               = [self class];
        SEL removeFromSuperviewSelector           = @selector(removeFromSuperview);
        SEL removeFromSuperviewPagingViewSelector = @selector(pagingViewHeader_removeFromSuperview);
        Method originalMethod                     = class_getInstanceMethod(class, removeFromSuperviewSelector);
        Method swizzledMethod                     = class_getInstanceMethod(class, removeFromSuperviewPagingViewSelector);
        // Need to add a new method to the class ? IT SHOULDN'T!!!
        if (class_addMethod(class, removeFromSuperviewSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod)))
            class_replaceMethod(class, removeFromSuperviewPagingViewSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        else
            method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

#pragma mark - Method Swizzling

/**
 *  Remove all gestures added to an UIView
 *  Then we call the original selector removeFromSuperView
 *  Normally we should call it in first place but in this case self could be deallocated before doing custom stuff resulting in CRASH
 */
- (void)pagingViewHeader_removeFromSuperview{
    // Remove all gestures before
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers)
        [self removeGestureRecognizer:recognizer];
    // Call original method
    [self pagingViewHeader_removeFromSuperview];
}

@end

//_______________________________________________________________________________________________________________

/**
 *  Instance of SLSuperPagingView
 */
@interface SLSuperPagingView() <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *stackViews;
@property (strong, nonatomic) NSMutableDictionary *restoreViews;
@property (nonatomic, readwrite) NSUInteger currentIndex;

- (NSUInteger)currentIndex:(CGFloat)offsetX subviewCount:(NSInteger)count;

@end

@implementation SLSuperPagingView

#pragma mark - Initialization
-(id) init{
    self = [super init];
    if(self)
        [self commonInit];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self commonInit];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    self.delegate                       = self;
    self.stackViews                     = [NSMutableDictionary dictionary];
    self.restoreViews                   = [NSMutableDictionary dictionary];
    self.pagingEnabled                  = YES;
    self.bounces                        = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator   = NO;
}

#pragma mark - Public methods

/**
 *  Find View in the restoreViews array using its tag
 *
 *  @param identifier Corresponding of the tag's view
 *
 *  @return UIView corresponding to the identifier, if there is no one it return nil
 */
- (id)dequeueReusableViewWithIdentifier:(NSUInteger)identifier{
    NSNumber *tag = @(identifier);
    UIView *view  = self.restoreViews[tag];
    if(view)
        [self.restoreViews removeObjectForKey:tag];
    return view;
}

-(void)moveToViewAtIndex:(NSUInteger)index animated:(BOOL)animated{}

#pragma mark - Internal methods

/**
 *  Get the number of subviews self will add
 *
 *  @return
 */
- (NSUInteger)subviewsCount
{
    return 0;
}

/**
 *  Look whether a specific view is diplaying or not
 *
 *  @param index of the view we are looking for
 *
 *  @return YES if it is displaying otherwise it return NO
 */
- (BOOL)isDisplayingViewForIndex:(NSUInteger)index
{
    for (UIView *view in self.stackViews.allValues)
        if (view.tag == index) return YES;
    return NO;
}

/**
 *  Combine width of subviews until reaches the view at a specific index
 *
 *  @param index of the limit view
 *
 *  @return return a float corresponding to the total width
 */
- (CGFloat)addWidthUntilIndex:(NSUInteger)index
{
    CGFloat width = 0.;
    for (NSInteger i = 0; i < index; i++)
        width += [self widthForSubviewAtIndex:i];
    return width;
}

/**
 *  Update the content size of self
 */
- (void)updateContentSize
{
    CGFloat minimumContentHeight = self.bounds.size.height - (self.contentInset.top + self.contentInset.bottom);
    self.contentSize             = CGSizeMake([self addWidthUntilIndex:[self subviewsCount]], minimumContentHeight);
}

- (void)configureSubview:(UIView *)view forIndex:(NSUInteger)index{}

/**
 *  Get the width of a view
 *
 *  @param index of the view we are looking for
 *
 *  @return a float corresponding to the width of the view
 */
- (CGFloat)widthForSubviewAtIndex:(NSInteger)index
{
    return CGRectGetWidth(self.frame);
}

/**
 *  Get the height of a view
 *
 *  @param index of the view we are looking for
 *
 *  @return a float corresponding to the height of the view
 */
- (CGFloat)heightForSubviewAtIndex:(NSInteger)index
{
    return CGRectGetHeight(self.frame);
}

/**
 *  Check whether the datasource is not nil and it respond to a Selector
 *
 *  @param selector we'd like to check it respond to
 *
 *  @return YES if everything is OK
 */
-(BOOL)object:(id)object respondToSelected:(SEL)selector{
    return object && [object respondsToSelector:selector];
}

/**
 *  Update the current index value
 *
 *  @param scrollView corresponding to self
 *
 *  @return the index of the current position
 */
- (NSUInteger)currentIndex:(CGFloat)offsetX subviewCount:(NSInteger)count{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.currentIndex = ((int) roundf(offsetX) % (count * (int)screenSize.width)) / screenSize.width;
    return self.currentIndex;
}

@end

//_______________________________________________________________________________________________________________

/**
 *  Instance of SLPagingView
 */
@interface SLPagingView() <UIScrollViewDelegate, SLPagingViewDelegate>

@property (nonatomic) BOOL beginToMove;
@property (nonatomic) CGFloat beginOffsetX;
@property (nonatomic, readwrite) NSUInteger currentIndex;

@end

@implementation SLPagingView

#pragma mark - Override methods

-(void)layoutSubviews{
    [super layoutSubviews];
    
    NSInteger firstViewIndex = 0;
    CGFloat width            = [self widthForSubviewAtIndex:firstViewIndex];
    
    while (width < CGRectGetMinX(self.bounds)) {
        firstViewIndex++;
        width += [self widthForSubviewAtIndex:firstViewIndex];
    }
    
    NSInteger lastViewIndex = firstViewIndex;
    while (width <= CGRectGetMaxX(self.bounds)) {
        lastViewIndex++;
        width += [self widthForSubviewAtIndex:lastViewIndex];
    }
    
    firstViewIndex = MAX(firstViewIndex, 0);
    lastViewIndex  = MIN(lastViewIndex, [self subviewsCount] - 1);
    
    // Recycled useless views in the stack views
    for (UIView *view in self.stackViews.allValues) {
        if(view && (view.tag < firstViewIndex || view.tag > lastViewIndex)) {
            [self.restoreViews setObject:view
                                  forKey:@(view.tag)];
            [view removeFromSuperview];
        }
    }
    // Remove useless visible views
    [self.stackViews minusDictionary:self.restoreViews];
    // Need to go further ?
    if ([self subviewsCount] == 0) return;
    
    for (NSUInteger index = firstViewIndex; index <= lastViewIndex; index++) {
        UIView *view = nil;
        if (![self isDisplayingViewForIndex:index]) {
            view     = [self.dataSource pagingView:self
                                   viewAtIndex:index];
            view.tag = index;
            [self insertSubview:view
                        atIndex:0];
            [self.stackViews setObject:view
                                forKey:@(index)];
        }
        else
            view = self.stackViews[@(index)];
        [self configureSubview:view
                      forIndex:index];
    }
    
    [self updateContentSize];
}

-(void)setDataSource:(id<SLPagingViewDataSource>)dataSource{
    _dataSource = dataSource;
    // Be sure to update the content size
    [self updateContentSize];
    [self layoutSubviews];
}

#pragma mark - Public methods

/**
 *  Scroll to the view at index @X
 *
 *  @param index of the wanted view
 *  @param animated animate the scroll or not
 */
- (void)moveToViewAtIndex:(NSUInteger)index animated:(BOOL)animated{
    if(index < [self subviewsCount]){
        // Get CGRect of the desire view
        CGRect moveToFrame = [self frameOfViewAtIndex:index];
        // Scroll to it
        [self scrollRectToVisible:moveToFrame
                         animated:animated];
    }
}

#pragma mark - Internal methods

/**
 *  Get the number of subviews self will add
 *
 *  @return
 */
- (NSUInteger)subviewsCount
{
    return [self.dataSource numberOfViewInPagingView:self];
}

/**
 *  Configure the frame of a view
 *
 *  @param view which need to be configured
 *  @param index of the view to configure
 */
- (void)configureSubview:(UIView *)view forIndex:(NSUInteger)index
{
    CGFloat width       = [self widthForSubviewAtIndex:index];
    CGFloat height      = ([self object:self.dataSource respondToSelected:@selector(heightForViews)])? [self.dataSource heightForViews] : self.contentSize.height;
    CGFloat originY     = ([self object:self.dataSource respondToSelected:@selector(origin)])? [self.dataSource origin] : 0.;
    CGRect newFrame     = CGRectMake(0., originY, width, height);
    newFrame.origin.x   = [self addWidthUntilIndex:index];
    newFrame.size.width = width;
    view.frame          = newFrame;
}

/**
 *  Get the view's index the scrollview is moving to
 *
 *  @param scrollView corresponding to self
 *
 *  @return index of the next view
 */
- (NSUInteger)getNextIndex:(UIScrollView *)scrollView{
    NSUInteger index = [self currentIndex:scrollView.contentOffset.x subviewCount:[self.dataSource numberOfViewInPagingView:self]];
    if(self.contentOffset.x > self.beginOffsetX)        // Moving forward
        index++;
    return index;
}

/**
 *  Get the rectangle infos of a specific view
 *
 *  @param index of the that we are interested of
 *
 *  @return CGRect corresponding to the frame of the view
 */
- (CGRect) frameOfViewAtIndex:(NSUInteger)index{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return CGRectMake(index * screenSize.width, 0, [self widthForSubviewAtIndex:index], [self heightForSubviewAtIndex:index]);
}

#pragma mark - SLPagingView Delegate interactions

/**
 *  Inform the delegate the scrollview will move to the next view
 *
 *  @param scrollView corresponding (should) to self
 */
- (void)willMoveToView:(UIScrollView *)scrollView{
    NSUInteger lastIndex = self.currentIndex;
    NSUInteger nextIdx = [self getNextIndex:scrollView];
    if([self object:self.pagingViewDelegate respondToSelected:@selector(willMoveToView:fromIndex:toIndex:)])
        [self.pagingViewDelegate willMoveToView:self.stackViews[@(nextIdx)]
                                      fromIndex:lastIndex
                                        toIndex:nextIdx];
}

/**
 *  Inform the delegate the scrollview moved to the next view
 *
 *  @param scrollView corresponding (should) to self
 */
- (void)didMoveToView:(UIScrollView *)scrollView{
    NSUInteger currentIdx = [self currentIndex:scrollView.contentOffset.x subviewCount:[self.dataSource numberOfViewInPagingView:self]];
    if(self.pagingViewDelegate
       && [self.pagingViewDelegate respondsToSelector:@selector(didMoveToView:atIndex:)])
        [self.pagingViewDelegate didMoveToView:self.stackViews[@(currentIdx)]
                                       atIndex:currentIdx];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.beginOffsetX = scrollView.contentOffset.x;
    self.beginToMove  = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.beginToMove){
        // Inform the delegate we begin to slide to another view
        self.beginToMove = NO;
        [self willMoveToView:scrollView];
    }
    // Allow custom moves for the paging menu
    // Allow client to set a custom Transition between views ?
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // Send the new index
    [self didMoveToView:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    // Send the new index
    [self didMoveToView:scrollView];
}

@end

//_______________________________________________________________________________________________________________

/**
 *  Instance of SLPagingViewHeader
 */
@interface SLPagingViewHeader(){
    __strong NSMutableDictionary *_originsX;
}

@property (nonatomic, readwrite) NSUInteger currentIndex;
@property (nonatomic) CGFloat lastOffsetX;
@end


@implementation SLPagingViewHeader

-(void)commonInit{
    [super commonInit];
    self.scrollEnabled        = NO;
    self.currentIndex         = 0;
    _originsX                 = [NSMutableDictionary new];
    self.navigationAlignment  = LeftPosition;
    self.navigationItemsSpace = SLNavigationSideItemsStyleDefault;
}

# pragma mark - Layout

-(void)layoutSubviews{
    [super layoutSubviews];
    
    NSInteger firstViewIndex = 0;
    while ([self abscissaWidthForIndex:firstViewIndex] < CGRectGetMinX(self.bounds))
        firstViewIndex++;
    NSInteger lastViewIndex = firstViewIndex;
    while ([self abscissaForIndex:lastViewIndex+1] <= CGRectGetMaxX(self.bounds))
        lastViewIndex++;
    
    firstViewIndex = MAX(firstViewIndex, 0);
    lastViewIndex  = MIN(lastViewIndex, [self subviewsCount] - 1);
    
    // Recycled useless views in the stack views
    for (UIView *view in self.stackViews.allValues) {
        if(view && (view.tag < firstViewIndex || view.tag > lastViewIndex)) {
            [self.restoreViews setObject:view
                                  forKey:@(view.tag)];
            [view removeFromSuperview];
        }
    }
    
    // Remove useless visible views
    [self.stackViews minusDictionary:self.restoreViews];
    // Need to go further ?
    if ([self subviewsCount] == 0) return;
    for (NSUInteger index = firstViewIndex; index <= lastViewIndex; index++) {
        UIView *view = nil;
        if (![self isDisplayingViewForIndex:index]) {
            view = [self.dataSource pagingViewHeader:self
                                         viewAtIndex:index];
            view.tag = index;
            [self insertSubview:view
                        atIndex:0];
            [self.stackViews setObject:view
                                forKey:@(index)];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(tapOnHeader:)];
            [view addGestureRecognizer:tap];
            [view setUserInteractionEnabled:YES];
        }
        else
            view = self.stackViews[@(index)];
        [self configureSubview:view
                      forIndex:index];
    }
    [self updateContentSize];
}

#pragma mark - Public methods

-(void)setDataSource:(id<SLPagingViewHeaderDataSource>)dataSource{
    _dataSource = dataSource;
    // Be sure to update the content size
    [_originsX removeAllObjects];
    [self updateContentSize];
    [self layoutSubviews];
}

/**
 *  Update the scrollview's horizontal position (offset X)
 *  with another offset X and widht as a references
 *
 *  @param contentOffsetX
 *  @param width
 */
-(void)updatePosition:(CGFloat)contentOffsetX width:(CGFloat)width{
    CGFloat lastIndexOffsetX    = [self currentIndex:self.lastOffsetX subviewCount:[self subviewsCount]] * width;
    CGFloat ratio               = (contentOffsetX - lastIndexOffsetX) / width;
    // Moving forward ?
    BOOL isMovingToNextIndex    = (contentOffsetX > lastIndexOffsetX);
    NSInteger targetIndex       = (isMovingToNextIndex) ? self.currentIndex + 1 : self.currentIndex - 1;
    CGFloat nextIndexOffsetX    = 1.0f;
    CGFloat currentIndexOffsetX = 1.0f;
    // Do we need to Update the contentOffset ?
    if(targetIndex >=0 && targetIndex <= [self subviewsCount]){
        nextIndexOffsetX    = [self abscissaForIndex:targetIndex];
        currentIndexOffsetX = [self abscissaForIndex:self.currentIndex];
        CGPoint offset      = self.contentOffset;
        if (isMovingToNextIndex) {
            offset.x = (nextIndexOffsetX - currentIndexOffsetX) * ratio + currentIndexOffsetX;
            [self setContentOffset:offset animated:NO];
        }
        else{
            offset.x = currentIndexOffsetX - (nextIndexOffsetX - currentIndexOffsetX) * ratio;
            [self setContentOffset:offset animated:NO];
        }
    }
    // Save last Offset X
    self.lastOffsetX = contentOffsetX;
}

-(void)updateIndex:(NSUInteger)newIndex{
    if(self.currentIndex == newIndex)
        return;
    self.currentIndex = newIndex;
}

/**
 *  Move to a view at a specific index
 *
 *  @param index of the view we'd to display
 *  @param animated, teel if we need to animate the move
 */
-(void)moveToViewAtIndex:(NSUInteger)index animated:(BOOL)animated{
    self.currentIndex = index;
    CGPoint offset = self.contentOffset;
    offset.x = [self abscissaForIndex:index];
    [self setContentOffset:offset animated:animated];
}

/**
 *  Refresh the view
 */
-(void)updateView{
    [self moveToViewAtIndex:self.currentIndex
                   animated:NO];
}

#pragma mark - Internal methods

/**
 *  Get the number of subviews self will add
 *
 *  @return
 */
- (NSUInteger)subviewsCount
{
    return [self.dataSource numberOfHeadersInPagingViewHeader:self];
}

/**
 *  Combine width of subviews until reaches the view at a specific index
 *
 *  @param index of the limit view
 *
 *  @return return a float corresponding to the total width
 */
- (CGFloat)addWidthUntilIndex:(NSUInteger)index
{
    CGFloat width = [super addWidthUntilIndex:index];
    width += (index-1) * self.navigationItemsSpace;
    return width;
}

/**
 *  Configure the frame of a view
 *
 *  @param view which need to be configured
 *  @param index of the view to configure
 */
- (void)configureSubview:(UIView *)view forIndex:(NSUInteger)index
{
    CGFloat width   = [self widthForSubviewAtIndex:index];
    CGFloat height  = self.contentSize.height;
    CGFloat originX = [self abscissaForIndex:index];
    if (self.navigationAlignment == CenterPosition)
        originX     += CGRectGetWidth(self.frame) / 2 - [self widthForSubviewAtIndex:index]/2;
    CGFloat originY = [self object:self.dataSource respondToSelected:@selector(originYForIndex:)]? [self.dataSource originYForIndex:index] : 0.;
    CGRect newFrame = CGRectMake(originX, originY, width, height);
    view.frame      = newFrame;
}

/**
 *  Get the width of a view
 *
 *  @param index of the view we are looking for
 *
 *  @return a float corresponding to the width of the view
 */
- (CGFloat)widthForSubviewAtIndex:(NSUInteger)index
{
    CGFloat width = [self object:self.dataSource respondToSelected:@selector(widthViewForIndex:)]? [self.dataSource widthViewForIndex:index] : [super widthForSubviewAtIndex:index];
    return width;
}

/**
 *  Get the abscissa of the view at a specific index
 *  Depending of superview's frame
 *
 *  @param index of the view we are looking for
 *
 *  @return the abscissa
 */
-(CGFloat)abscissaForIndex:(NSUInteger)index{
    if(!_originsX[@(index)]){
        CGFloat origin = (_originsX[@(index-1)])? [_originsX[@(index-1)] floatValue] : ([self object:self.dataSource respondToSelected:@selector(originXForIndex:)]? [self.dataSource originXForIndex:index-1] : 0.);
        if (self.navigationAlignment == LeftPosition){
            // Navigation items on the left side
            origin += [self widthForSubviewAtIndex:index-1];
            origin += self.navigationItemsSpace;
        }
        else
            // Navigations items centered
            origin += [self spaceWithIndex:index origin:origin];
        _originsX[@(index)] = @(origin);
        return origin;
    }
    else
        return [_originsX[@(index)] floatValue];
}

/**
 *  Get absissa of the view at a specific index additionned to it's width
 *  Depending of superview's frame
 *
 *  @param index index of the view we are looking for
 *
 *  @return the abscissa
 */
-(CGFloat)abscissaWidthForIndex:(NSUInteger)index{
    CGFloat origin = [self abscissaForIndex:index];
    origin         += [self widthForSubviewAtIndex:index];
    if (self.navigationAlignment == CenterPosition){
        CGFloat width = CGRectGetWidth(self.frame) / 2 - [self widthForSubviewAtIndex:index]/2;
        origin += width;
    }
    return origin;
}

// Scroll to the view tapped
-(void)tapOnHeader:(UITapGestureRecognizer *)recognizer{
    // Get index of view
    NSInteger indexSelected = recognizer.view.tag;
    // Inform delegate need to move to this index
    if([self object:self.dataSource respondToSelected:@selector(needToMoveToIndex:)])
        [self.dataSource needToMoveToIndex:indexSelected];
}

/**
 *  Get the height of a view
 *
 *  @param index of the view we are looking for
 *
 *  @return a float corresponding to the height of the view
 */
- (CGFloat)heightForSubviewAtIndex:(NSInteger)index{
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

/**
 *  Get the space between two views
 *
 *  @param index of the next view
 *  @param origin (abscissa) of the reference view
 *
 *  @return a float corresponding to space between both views
 */
-(CGFloat)spaceWithIndex:(NSInteger)index origin:(CGFloat)origin{
    CGFloat result = CGRectGetWidth([UIScreen mainScreen].bounds)/2-(origin / self.contentSize.width);
    if(index > 0 && index-1 <= [self subviewsCount])
        result -= [self widthForSubviewAtIndex:index-1];
    return result;
}

@end