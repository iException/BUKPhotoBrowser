//
//  BUKPhotoBrowser.m
//  Pods
//
//  Created by hyice on 15/8/11.
//
//

#import "BUKPhotoBrowser.h"
#import "BUKPhotoView.h"

static const CGFloat kBUKViewPadding = 10;

@interface BUKPhotoBrowser ()

@property (assign, nonatomic) NSInteger currentIndex;

@property (strong, nonatomic) BUKPhotoView *buk_leftView;
@property (strong, nonatomic) BUKPhotoView *buk_centerView;
@property (strong, nonatomic) BUKPhotoView *buk_rightView;

@property (nonatomic, weak) id<BUKPhotoBrowserDataSource> buk_dataSource;

@property (nonatomic, assign) BOOL buk_originNavigationHidden;
@property (nonatomic, assign) BOOL buk_originStatusBarHidden;
@property (nonatomic, assign) BOOL buk_hasAppeared;

@end

@implementation BUKPhotoBrowser

#pragma mark - lifecycle -
- (instancetype)init
{
    NSAssert(NO, @"You Can't Use This Method To Initialize, Please Use `initWithDataSource:defaultIndex:` instead!");
    return nil;
}

- (instancetype)initWithDataSource:(id<BUKPhotoBrowserDataSource>)dataSource defaultIndex:(NSInteger)index
{
    self = [super init];
    
    if (self) {
        self.currentIndex = index;
        self.buk_dataSource = dataSource;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    [self.view addGestureRecognizer:[self buk_longTapGesture]];
    [self.view addGestureRecognizer:[self buk_backTapGesture]];
    [self.view addGestureRecognizer:[self buk_panGesture]];
    
    [self reloadBrowserWithDefaultIndex:self.currentIndex];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.buk_hasAppeared) {
        self.buk_hasAppeared = YES;
        
        self.buk_originNavigationHidden = self.navigationController.isNavigationBarHidden;
        self.buk_originStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    }
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:!self.showNavigationBar animated:animated];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:!self.showStatusBar withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:self.buk_originNavigationHidden animated:animated];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.buk_originStatusBarHidden withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)prefersStatusBarHidden
{
    return !self.showStatusBar;
}

#pragma mark - public -
- (void)reloadBrowserWithDefaultIndex:(NSInteger)index
{
    if (index < 0) {
        return;
    }
    
    NSInteger count = [self buk_totalPhotosCount];
    if (index > count - 1) {
        return;
    }
    
    [self.buk_leftView removeFromSuperview];
    self.buk_leftView = nil;
    
    [self.buk_centerView removeFromSuperview];
    self.buk_centerView = nil;
    
    [self.buk_rightView removeFromSuperview];
    self.buk_rightView = nil;
    
    self.currentIndex = index;
    
    
    self.buk_centerView = [self buk_photoViewWithIndex:self.currentIndex];
    [self.view addSubview:self.buk_centerView];
    
    if (index > 0) {
        self.buk_leftView = [self buk_photoViewWithIndex:self.currentIndex - 1];
        [self.view addSubview:self.buk_leftView];
    }
    
    if (index < count - 1) {
        self.buk_rightView = [self buk_photoViewWithIndex:self.currentIndex + 1];
        [self.view addSubview:self.buk_rightView];
    }
    
    [self.view bringSubviewToFront:self.actionBar];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(buk_photoBrowser:didScrollToIndex:)]) {
        [self.delegate buk_photoBrowser:self didScrollToIndex:self.currentIndex];
    }
}

#pragma mark - events -
- (void)buk_savePhoto:(UILongPressGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(buk_photoBrowserDidLongPressed:)] && sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate buk_photoBrowserDidLongPressed:self];
    }
}

- (void)buk_goBack:(id)sender
{
    if (self.disableTapToDismiss) {
        return;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(buk_photoBrowserWillDismiss:)]) {
        [self.delegate buk_photoBrowserWillDismiss:self];
    }
    
    if (!self.navigationController || self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)buk_panned:(UIPanGestureRecognizer *)pan
{
    NSInteger indexBeforePan = self.currentIndex;
    
    CGPoint translation = [pan translationInView:self.view];
    
    CGPoint leftTranslation = [self buk_swallowTranslationForPinToEdge:translation];
    leftTranslation = [self buk_swallowTranslationForPhotoView:leftTranslation];
    
    CGFloat xTranslation = leftTranslation.x;
    
    // boundary bounce
    CGFloat minCenterViewX = CGRectGetMinX(self.buk_centerView.frame);
    if (!self.buk_rightView && minCenterViewX < -3) {
        xTranslation = xTranslation*pow(0.93, -minCenterViewX/3);
    }else if (!self.buk_leftView && minCenterViewX > 3) {
        xTranslation = xTranslation*pow(0.93, minCenterViewX/3);
    }
    
    [self buk_translateViewsWithX:xTranslation];
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        if (xTranslation >= 0 && CGRectGetMinX(self.buk_centerView.frame) > kBUKViewPadding) {
            [self buk_moveToLeft];
        }else if (xTranslation <= 0 && CGRectGetMinX(self.buk_centerView.frame) < -kBUKViewPadding){
            [self buk_moveToRight];
        }else {
            [self buk_pinToCurrentIndexPosition];
        }
    }
    
    [pan setTranslation:CGPointZero inView:self.view];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(buk_photoBrowser:didScrollToIndex:)] && self.currentIndex != indexBeforePan) {
        [self.delegate buk_photoBrowser:self didScrollToIndex:self.currentIndex];
    }
}

#pragma mark - private -
- (BUKPhotoView *)buk_photoViewWithIndex:(NSInteger)index
{
    if (index < 0) {
        return nil;
    }
    
    if (index >= [self buk_totalPhotosCount]) {
        return nil;
    }
    
    BUKPhotoView *photoView = [[BUKPhotoView alloc] initWithFrame:[self buk_photoViewFrameAtIndex:index]];
    
    [photoView setupViewWithPhoto:[self buk_photoForIndex:index]];
    
    return photoView;
}

- (CGRect)buk_photoViewFrameAtIndex:(NSInteger)index
{
    CGRect frame = self.view.bounds;
    if (index < self.currentIndex) {
        frame.origin.x -= CGRectGetWidth(self.view.bounds) + kBUKViewPadding;
    }else if (index > self.currentIndex) {
        frame.origin.x += CGRectGetWidth(self.view.bounds) + kBUKViewPadding;
    }
    
    return frame;
}

- (NSInteger)buk_totalPhotosCount
{
    NSInteger count = 0;
    if (self.buk_dataSource && [self.buk_dataSource respondsToSelector:@selector(buk_numberOfPhotosForBrowser:)]) {
        count = [self.buk_dataSource buk_numberOfPhotosForBrowser:self];
    }
    return count;
}

- (BUKPhoto *)buk_photoForIndex:(NSInteger)index
{
    if (self.buk_dataSource && [self.buk_dataSource respondsToSelector:@selector(buk_photoBrowser:photoAtIndex:)]) {
        BUKPhoto *photo = [self.buk_dataSource buk_photoBrowser:self photoAtIndex:index];
        if ([photo isKindOfClass:[BUKPhoto class]]) {
            return photo;
        }
    }
    
    return nil;
}

- (void)buk_translateViewsWithX:(CGFloat)xTranslation
{
    [self buk_addFrameOriginX:xTranslation forView:self.buk_leftView];
    [self buk_addFrameOriginX:xTranslation forView:self.buk_centerView];
    [self buk_addFrameOriginX:xTranslation forView:self.buk_rightView];
}

- (void)buk_addFrameOriginX:(CGFloat)addValue forView:(UIView *)view
{
    if (!view) {
        return;
    }
    CGRect frame = view.frame;
    frame.origin.x += addValue;
    view.frame = frame;
}

- (void)buk_moveToLeft
{
    if (self.currentIndex > 0) {
        self.currentIndex -= 1;
        [self.buk_rightView removeFromSuperview];
        self.buk_rightView = self.buk_centerView;
        self.buk_centerView = self.buk_leftView;
        self.buk_leftView = [self buk_photoViewWithIndex:self.currentIndex - 1];
        if (self.buk_leftView) {
            [self.view addSubview:self.buk_leftView];
            [self.view bringSubviewToFront:self.actionBar];
        }
    }
    
    [self buk_pinToCurrentIndexPosition];
}

- (void)buk_moveToRight
{
    if (self.currentIndex < [self buk_totalPhotosCount] - 1) {
        self.currentIndex += 1;
        [self.buk_leftView removeFromSuperview];
        self.buk_leftView = self.buk_centerView;
        self.buk_centerView = self.buk_rightView;
        self.buk_rightView = [self buk_photoViewWithIndex:self.currentIndex + 1];
        if (self.buk_rightView) {
            [self.view addSubview:self.buk_rightView];
            [self.view bringSubviewToFront:self.actionBar];
        }
    }
    
    [self buk_pinToCurrentIndexPosition];
}

- (void)buk_pinToCurrentIndexPosition
{
    [UIView animateWithDuration:0.25f animations:^{
        self.buk_leftView.frame = [self buk_photoViewFrameAtIndex:self.currentIndex - 1];
        self.buk_centerView.frame = [self buk_photoViewFrameAtIndex:self.currentIndex];
        self.buk_rightView.frame = [self buk_photoViewFrameAtIndex:self.currentIndex + 1];
    }];
}

- (CGPoint)buk_swallowTranslationForPinToEdge:(CGPoint)originTranslation
{
    CGFloat minX = CGRectGetMinX(self.buk_centerView.frame);
    if (minX == 0) {
        return originTranslation;
    }
    
    if (minX * originTranslation.x > 0) {
        return originTranslation;
    }
    
    if (fabs(minX) > fabs(originTranslation.x)) {
        [self buk_translateViewsWithX:originTranslation.x];
        return CGPointMake(0, originTranslation.y);
    }else {
        [self buk_translateViewsWithX:-minX];
        return CGPointMake(originTranslation.x + minX, originTranslation.y);
    }
}

- (CGPoint)buk_swallowTranslationForPhotoView:(CGPoint)originTranslation
{
    BOOL toLeft = originTranslation.x < 0;
    BOOL toTop = originTranslation.y < 0;
    
    CGFloat leftX = fabs(originTranslation.x);
    CGFloat leftY = fabs(originTranslation.y);
    
    CGFloat needForX = [self.buk_centerView imageOverflowLengthForDirection:toLeft? BUKPhotoViewOverflowRightDirection : BUKPhotoViewOverflowLeftDirection];
    CGFloat actualForX;
    if (needForX > leftX) {
        actualForX = leftX;
        leftX = 0;
    }else {
        actualForX = needForX;
        leftX -= needForX;
    }
    
    CGFloat needForY = [self.buk_centerView imageOverflowLengthForDirection:toTop? BUKPhotoViewOverflowBottomDirection : BUKPhotoViewOverflowTopDirection];
    CGFloat actualForY;
    if (needForY > leftY) {
        actualForY = leftY;
        leftY = 0;
    }else {
        actualForY = needForY;
        leftY -= needForY;
    }
    [self.buk_centerView translateImage:CGPointMake(actualForX * (toLeft? -1 : 1), actualForY * (toTop? -1 : 1)) animated:NO];
    
    return CGPointMake(leftX * (toLeft? -1 : 1), leftY * (toTop? -1 : 1));
}

#pragma mark - setters -
- (void)setShowNavigationBar:(BOOL)showNavigationBar
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(showNavigationBar))];
    _showNavigationBar = showNavigationBar;
    [self didChangeValueForKey:NSStringFromSelector(@selector(showNavigationBar))];

    if (self.navigationController && self.buk_hasAppeared) {
        [self.navigationController setNavigationBarHidden:!self.showNavigationBar animated:YES];
    }
}

- (void)setShowStatusBar:(BOOL)showStatusBar
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(showStatusBar))];
    _showStatusBar = showStatusBar;
    [self didChangeValueForKey:NSStringFromSelector(@selector(showStatusBar))];

    if (self.buk_hasAppeared) {
        [[UIApplication sharedApplication] setStatusBarHidden:!self.showStatusBar withAnimation:UIStatusBarAnimationNone];
    }
}

#pragma mark - getters -
- (UILongPressGestureRecognizer *)buk_longTapGesture
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buk_savePhoto:)];
    return longPress;
}

- (UITapGestureRecognizer *)buk_backTapGesture
{
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buk_goBack:)];
    return backTap;
}

- (UIPanGestureRecognizer *)buk_panGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(buk_panned:)];
    return pan;
}

- (void)setActionBar:(UIView *)actionBar
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(actionBar))];
    _actionBar = actionBar;
    [self.view addSubview:_actionBar];
    
    if (CGRectIsEmpty(_actionBar.frame)) {
        _actionBar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 60, CGRectGetWidth(self.view.bounds), 60);
    }
    [self didChangeValueForKey:NSStringFromSelector(@selector(actionBar))];
}
@end
