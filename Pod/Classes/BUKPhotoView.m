//
//  BUKPhotoView.m
//  Pods
//
//  Created by hyice on 15/8/11.
//
//

#import "BUKPhotoView.h"
#import "BUKPhoto.h"

@interface BUKPhotoView ()

@property (strong, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) NSLayoutConstraint *imageViewLeftConstraint;
@property (weak, nonatomic) NSLayoutConstraint *imageViewRightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) NSLayoutConstraint *imageViewBottomConstraint;

@property (assign, nonatomic) CGFloat photoWidthRate;
@property (assign, nonatomic) CGFloat photoHeightRate;
@property (assign, nonatomic) CGSize maxPhotoSize;

@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;

@end

@implementation BUKPhotoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.clipsToBounds = YES;
        [self initImageView];
        [self initPinchGesture];
        [self initLoadingIndicator];
    }
    
    return self;
}

- (void)setupViewWithPhoto:(BUKPhoto *)photo
{
    if (!photo) {
        return;
    }
    [self.loadingIndicator startAnimating];
    [photo getPhoto:^(UIImage *image, CGFloat progress) {
        [self.imageView setImage:image];
        
        if (progress == 1.0) {
            [self setupConfigurationWithImage:image];
            [self.loadingIndicator stopAnimating];
        }
    }];
}

- (void)translateImage:(CGPoint)translation animated:(BOOL)animated
{
    if (translation.x == 0 && translation.y == 0) {
        return;
    }
    
    self.imageViewLeftConstraint.constant += translation.x;
    self.imageViewRightConstraint.constant += translation.x;
    self.imageViewTopConstraint.constant += translation.y;
    self.imageViewBottomConstraint.constant += translation.y;
    
    [self checkAndAdjustPosition:animated];
}

- (CGFloat)imageOverflowLengthForDirection:(BUKPhotoViewOverflowDirection)direction
{
    CGFloat viewOverflow;
    CGFloat emptyLength;
    
    switch (direction) {
        case BUKPhotoViewOverflowLeftDirection: {
            viewOverflow = -self.imageViewLeftConstraint.constant;
            emptyLength = [self emptyLengthToHorizontalBorder];
            break;
        }
        case BUKPhotoViewOverflowRightDirection: {
            viewOverflow = self.imageViewRightConstraint.constant;
            emptyLength = [self emptyLengthToHorizontalBorder];
            break;
        }
            
        case BUKPhotoViewOverflowTopDirection: {
            viewOverflow = -self.imageViewTopConstraint.constant;
            emptyLength = [self emptyLengthToVerticalBorder];
            break;
        }
            
        case BUKPhotoViewOverflowBottomDirection: {
            viewOverflow = self.imageViewBottomConstraint.constant;
            emptyLength = [self emptyLengthToVerticalBorder];
            break;
        }
            
        default:
            return 0;
    }
    
    return viewOverflow > emptyLength? viewOverflow - emptyLength : 0;
}

#pragma mark - photo configuration
- (void)setupConfigurationWithImage:(UIImage *)image
{
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    CGFloat viewRatio = viewWidth / viewHeight;
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat imageRatio = imageWidth / imageHeight;
    
    CGFloat maxWidth;
    CGFloat maxHeight;
    if (viewRatio == imageRatio) {
        self.photoWidthRate = 1.0;
        self.photoHeightRate = 1.0;
        maxWidth = MAX(imageWidth, viewWidth);
        maxHeight = maxWidth / imageRatio;
    }else if (viewRatio > imageRatio) {
        self.photoWidthRate = imageRatio / viewRatio;
        self.photoHeightRate = 1.0;
        maxWidth = MAX(imageWidth, viewWidth);
        maxWidth /= self.photoWidthRate;
        maxHeight = maxWidth / viewRatio;
    }else {
        self.photoWidthRate = 1.0;
        self.photoHeightRate = viewRatio / imageRatio;
        maxHeight = MAX(imageHeight, viewHeight);
        maxHeight /= self.photoHeightRate;
        maxWidth = maxHeight * viewRatio;
    }
    self.maxPhotoSize = CGSizeMake(maxWidth, maxHeight);
}

- (CGFloat)emptyLengthToHorizontalBorder
{
    return CGRectGetWidth(self.imageView.frame) * (1.0 - self.photoWidthRate)/2.0;
}

- (CGFloat)emptyLengthToVerticalBorder
{
    return CGRectGetHeight(self.imageView.frame) * (1.0 - self.photoHeightRate)/2.0;
}

#pragma mark - pinch
- (void)initPinchGesture
{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.imageView addGestureRecognizer:pinch];
    self.imageView.userInteractionEnabled = YES;
}

- (void)pinch:(UIPinchGestureRecognizer *)pinch
{
    CGPoint center = [pinch locationInView:self.imageView];
    [self scaleImageView:pinch.scale center:center];
    
    pinch.scale = 1;
    
    if (pinch.state == UIGestureRecognizerStateEnded || pinch.state == UIGestureRecognizerStateCancelled) {
        [self checkAndAdjustPosition:YES];
    }
}

- (void)scaleImageView:(CGFloat)scale center:(CGPoint)center
{
    if (scale == 1.0) {
        return;
    }
    
    if (!isfinite(scale)) {
        return;
    }
    
    CGFloat leftLength = center.x;
    CGFloat rightLength = CGRectGetWidth(self.imageView.frame) - leftLength;
    CGFloat topLength = center.y;
    CGFloat bottomLength = CGRectGetHeight(self.imageView.frame) - topLength;
    
    self.imageViewLeftConstraint.constant += leftLength * (1 - scale);
    self.imageViewRightConstraint.constant -= rightLength * (1 - scale);
    self.imageViewTopConstraint.constant += topLength * (1 - scale);
    self.imageViewBottomConstraint.constant -= bottomLength * (1 - scale);
    [self setNeedsLayout];
}

- (void)checkAndAdjustPosition:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25f animations:^{
            [self checkAndAdjustPositionWithoutAnimation];
        }];
    }else {
        [self checkAndAdjustPositionWithoutAnimation];
    }
}

- (void)checkAndAdjustPositionWithoutAnimation
{
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat imageViewWidth = CGRectGetWidth(self.imageView.frame);
    CGFloat actualPhotoWidth = imageViewWidth * self.photoWidthRate;
    
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    CGFloat imageViewHeight = CGRectGetHeight(self.imageView.frame);
    CGFloat actualPhotoHeight = imageViewHeight * self.photoHeightRate;
    
    if (actualPhotoWidth == 0 || actualPhotoHeight == 0 || imageViewWidth == 0 || imageViewHeight == 0) {
        return;
    }
    
    // scale image to specified size first
    
    CGFloat scale = 1.0;
    
    if (self.photoWidthRate == 1.0 && actualPhotoWidth < viewWidth) {
        scale = viewWidth / actualPhotoWidth;
    }else if (self.photoHeightRate == 1.0 && actualPhotoHeight < viewHeight) {
        scale = viewHeight / actualPhotoHeight;
    }
    else if (self.photoWidthRate != 1.0 && imageViewWidth > self.maxPhotoSize.width) {
        scale = self.maxPhotoSize.width / imageViewWidth;
    }else if (self.photoHeightRate != 1.0 && imageViewHeight > self.maxPhotoSize.height) {
        scale = self.maxPhotoSize.height / imageViewHeight;
    }
    
    CGPoint center = CGPointMake(self.center.x - CGRectGetMinX(self.imageView.frame), self.center.y - CGRectGetMinY(self.imageView.frame));
    [self scaleImageView:scale center:center];
    
    // translate image to specified position
    imageViewWidth = imageViewWidth * scale;
    actualPhotoWidth = round(actualPhotoWidth * scale);
    
    imageViewHeight = imageViewHeight * scale;
    actualPhotoHeight = round(actualPhotoHeight * scale);
    
    if (actualPhotoWidth < viewWidth && self.photoWidthRate != 1.0) { // centre
        CGFloat xPadding = (imageViewWidth - viewWidth)/2.0;
        self.imageViewLeftConstraint.constant = -xPadding;
        self.imageViewRightConstraint.constant = xPadding;
    }else { // pin to border if has empty space
        CGFloat horizontalEmptyLength = imageViewWidth * (1.0 - self.photoWidthRate)/2.0;
        if (self.imageViewLeftConstraint.constant > -horizontalEmptyLength) {
            CGFloat offset = -horizontalEmptyLength - self.imageViewLeftConstraint.constant;
            self.imageViewLeftConstraint.constant += offset;
            self.imageViewRightConstraint.constant += offset;
        }else if (self.imageViewRightConstraint.constant < horizontalEmptyLength) {
            CGFloat offset = horizontalEmptyLength - self.imageViewRightConstraint.constant;
            self.imageViewRightConstraint.constant += offset;
            self.imageViewLeftConstraint.constant += offset;
        }
    }
    
    if (actualPhotoHeight < viewHeight && self.photoHeightRate != 1.0) {
        CGFloat yPadding = (imageViewHeight - viewHeight)/2.0;
        self.imageViewTopConstraint.constant = -yPadding;
        self.imageViewBottomConstraint.constant = yPadding;
    }else {
        CGFloat verticalEmptyLength = imageViewHeight * (1.0 - self.photoHeightRate)/2.0;
        if (self.imageViewTopConstraint.constant > -verticalEmptyLength) {
            CGFloat offset = -verticalEmptyLength - self.imageViewTopConstraint.constant;
            self.imageViewTopConstraint.constant += offset;
            self.imageViewBottomConstraint.constant += offset;
        }else if (self.imageViewBottomConstraint.constant < verticalEmptyLength) {
            CGFloat offset = verticalEmptyLength - self.imageViewBottomConstraint.constant;
            self.imageViewTopConstraint.constant += offset;
            self.imageViewBottomConstraint.constant += offset;
        }
    }
    
    [self layoutIfNeeded];
}

#pragma mark - image view
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imageView;
}

- (void)initImageView
{
    [self addSubview:self.imageView];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.imageViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self addConstraint:self.imageViewLeftConstraint];
    
    self.imageViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self addConstraint:self.imageViewRightConstraint];
    
    self.imageViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [self addConstraint:self.imageViewTopConstraint];
    
    self.imageViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraint:self.imageViewBottomConstraint];
}

#pragma mark - loading indicator
- (UIActivityIndicatorView *)loadingIndicator
{
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingIndicator.hidesWhenStopped = YES;
    }
    
    return _loadingIndicator;
}

- (void)initLoadingIndicator
{
    [self addSubview:self.loadingIndicator];
    
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingIndicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
}
#pragma mark -

@end
