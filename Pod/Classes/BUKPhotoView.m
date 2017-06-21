//
//  BUKPhotoView.m
//  BUKPhotoBrowser
//
//  Created by hyice on 15/8/11.
//  Copyright (c) 2015 - 2017 Baixing, Inc. All rights reserved.
//

#import "BUKPhotoView.h"
#import "BUKPhoto.h"
#import "BUKPhotoImageContentView.h"

@interface BUKPhotoView ()

@property (nonatomic, weak) BUKPhoto *photo;
@property (nonatomic, weak) NSLayoutConstraint *contentViewLeftConstraint;
@property (nonatomic, weak) NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *contentViewTopConstraint;
@property (nonatomic, weak) NSLayoutConstraint *contentViewBottomConstraint;
@property (nonatomic, assign) CGFloat contentWidthRatio;
@property (nonatomic, assign) CGFloat contentHeightRatio;
@property (nonatomic, assign) CGSize maxContentSize;

@end

@implementation BUKPhotoView

@synthesize contentView = _contentView;

#pragma mark - Accessors

- (UIView<BUKPhotoContentView> *)contentView {
    if (!_contentView) {
        self.contentView = [[BUKPhotoImageContentView alloc] initWithFrame:self.bounds];
    }
    return _contentView;
}


- (void)setContentView:(UIView<BUKPhotoContentView> *)contentView {
    [_contentView removeFromSuperview];
    _contentView = contentView;
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_contentView];
    [self setupViewConstraints];
    [self setupGestureRecognizer];
    [_contentView setPhoto:self.photo withPhotoView:self];
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _pinchEnabled = YES;
        self.clipsToBounds = YES;
        [self adjustWithContentSize:frame.size];
    }
    return self;
}


#pragma mark - Actions

- (void)pinch:(UIPinchGestureRecognizer *)pinch {
    if (!self.pinchEnabled) {
        return;
    }

    CGPoint center = [pinch locationInView:self.contentView];
    [self scaleContentView:pinch.scale center:center];

    pinch.scale = 1;

    if (pinch.state == UIGestureRecognizerStateEnded || pinch.state == UIGestureRecognizerStateCancelled) {
        [self checkAndAdjustPosition:YES];
    }
}


#pragma mark - Public

- (void)setupViewWithPhoto:(BUKPhoto *)photo {
    [self.contentView setPhoto:photo withPhotoView:self];
}


- (void)translateImage:(CGPoint)translation animated:(BOOL)animated {
    if (translation.x == 0 && translation.y == 0) {
        return;
    }
    
    self.contentViewLeftConstraint.constant += translation.x;
    self.contentViewRightConstraint.constant += translation.x;
    self.contentViewTopConstraint.constant += translation.y;
    self.contentViewBottomConstraint.constant += translation.y;
    
    [self checkAndAdjustPosition:animated];
}


- (CGFloat)contentOverflowLengthForDirection:(BUKPhotoViewOverflowDirection)direction {
    CGFloat viewOverflow;
    CGFloat emptyLength;
    
    switch (direction) {
        case BUKPhotoViewOverflowLeftDirection: {
            viewOverflow = -self.contentViewLeftConstraint.constant;
            emptyLength = [self emptyLengthToHorizontalBorder];
            break;
        }
        case BUKPhotoViewOverflowRightDirection: {
            viewOverflow = self.contentViewRightConstraint.constant;
            emptyLength = [self emptyLengthToHorizontalBorder];
            break;
        }
            
        case BUKPhotoViewOverflowTopDirection: {
            viewOverflow = -self.contentViewTopConstraint.constant;
            emptyLength = [self emptyLengthToVerticalBorder];
            break;
        }
            
        case BUKPhotoViewOverflowBottomDirection: {
            viewOverflow = self.contentViewBottomConstraint.constant;
            emptyLength = [self emptyLengthToVerticalBorder];
            break;
        }
            
        default:
            return 0;
    }
    
    return viewOverflow > emptyLength? viewOverflow - emptyLength : 0;
}


- (void)adjustWithContentSize:(CGSize)size {
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    CGFloat viewRatio = viewWidth / viewHeight;

    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;
    CGFloat imageRatio = imageWidth / imageHeight;

    CGFloat maxWidth;
    CGFloat maxHeight;
    if (viewRatio == imageRatio) {
        self.contentWidthRatio = 1.0;
        self.contentHeightRatio = 1.0;
        maxWidth = MAX(imageWidth, viewWidth);
        maxHeight = maxWidth / imageRatio;
    }else if (viewRatio > imageRatio) {
        self.contentWidthRatio = imageRatio / viewRatio;
        self.contentHeightRatio = 1.0;
        maxWidth = MAX(imageWidth, viewWidth);
        maxWidth /= self.contentWidthRatio;
        maxHeight = maxWidth / viewRatio;
    }else {
        self.contentWidthRatio = 1.0;
        self.contentHeightRatio = viewRatio / imageRatio;
        maxHeight = MAX(imageHeight, viewHeight);
        maxHeight /= self.contentHeightRatio;
        maxWidth = maxHeight * viewRatio;
    }
    self.maxContentSize = CGSizeMake(maxWidth, maxHeight);
}


#pragma mark - Private

- (void)setupViewConstraints {
    self.contentViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    self.contentViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    self.contentViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    self.contentViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [NSLayoutConstraint activateConstraints:@[self.contentViewLeftConstraint, self.contentViewRightConstraint, self.contentViewTopConstraint, self.contentViewBottomConstraint]];
}


- (void)setupGestureRecognizer {
    [self.contentView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)]];
    self.contentView.userInteractionEnabled = YES;
}


- (CGFloat)emptyLengthToHorizontalBorder {
    return CGRectGetWidth(self.contentView.frame) * (1.0 - self.contentWidthRatio) / 2.0;
}


- (CGFloat)emptyLengthToVerticalBorder {
    return CGRectGetHeight(self.contentView.frame) * (1.0 - self.contentHeightRatio) / 2.0;
}


- (void)scaleContentView:(CGFloat)scale center:(CGPoint)center {
    CGFloat rate = 1 - scale;
    
    if (isnan(rate) || isinf(rate) || rate == 0) {
        return;
    }
    
    CGFloat leftLength = center.x;
    CGFloat rightLength = CGRectGetWidth(self.contentView.frame) - leftLength;
    CGFloat topLength = center.y;
    CGFloat bottomLength = CGRectGetHeight(self.contentView.frame) - topLength;
    
    if (isnan(leftLength) || isinf(leftLength)
        || isnan(rightLength) || isinf(rightLength)
        || isnan(topLength) || isinf(topLength)
        || isnan(bottomLength) || isinf(bottomLength)) {
        return;
    }
    
    self.contentViewLeftConstraint.constant += leftLength * rate;
    self.contentViewRightConstraint.constant -= rightLength * rate;
    self.contentViewTopConstraint.constant += topLength * rate;
    self.contentViewBottomConstraint.constant -= bottomLength * rate;
    [self setNeedsLayout];
}


- (void)checkAndAdjustPosition:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25f animations:^{
            [self checkAndAdjustPositionWithoutAnimation];
        }];
    }else {
        [self checkAndAdjustPositionWithoutAnimation];
    }
}


- (void)checkAndAdjustPositionWithoutAnimation {
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat actualPhotoWidth = contentViewWidth * self.contentWidthRatio;
    
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    CGFloat contentViewHeight = CGRectGetHeight(self.contentView.frame);
    CGFloat actualPhotoHeight = contentViewHeight * self.contentHeightRatio;
    
    if (actualPhotoWidth == 0 || actualPhotoHeight == 0 || contentViewWidth == 0 || contentViewHeight == 0) {
        return;
    }
    
    // scale image to specified size first
    
    CGFloat scale = 1.0;
    
    if (self.contentWidthRatio == 1.0 && actualPhotoWidth < viewWidth) {
        scale = viewWidth / actualPhotoWidth;
    } else if (self.contentHeightRatio == 1.0 && actualPhotoHeight < viewHeight) {
        scale = viewHeight / actualPhotoHeight;
    } else if (self.contentWidthRatio != 1.0 && contentViewWidth > self.maxContentSize.width) {
        scale = self.maxContentSize.width / contentViewWidth;
    } else if (self.contentHeightRatio != 1.0 && contentViewHeight > self.maxContentSize.height) {
        scale = self.maxContentSize.height / contentViewHeight;
    }
    
    CGPoint center = CGPointMake(self.center.x - CGRectGetMinX(self.contentView.frame), self.center.y - CGRectGetMinY(self.contentView.frame));
    [self scaleContentView:scale center:center];
    
    // translate image to specified position
    contentViewWidth = contentViewWidth * scale;
    actualPhotoWidth = round(actualPhotoWidth * scale);
    
    contentViewHeight = contentViewHeight * scale;
    actualPhotoHeight = round(actualPhotoHeight * scale);
    
    if (actualPhotoWidth < viewWidth && self.contentWidthRatio != 1.0) { // centre
        CGFloat xPadding = (contentViewWidth - viewWidth)/2.0;
        self.contentViewLeftConstraint.constant = -xPadding;
        self.contentViewRightConstraint.constant = xPadding;
    } else { // pin to border if has empty space
        CGFloat horizontalEmptyLength = contentViewWidth * (1.0 - self.contentWidthRatio)/2.0;
        if (self.contentViewLeftConstraint.constant > -horizontalEmptyLength) {
            CGFloat offset = -horizontalEmptyLength - self.contentViewLeftConstraint.constant;
            self.contentViewLeftConstraint.constant += offset;
            self.contentViewRightConstraint.constant += offset;
        }else if (self.contentViewRightConstraint.constant < horizontalEmptyLength) {
            CGFloat offset = horizontalEmptyLength - self.contentViewRightConstraint.constant;
            self.contentViewRightConstraint.constant += offset;
            self.contentViewLeftConstraint.constant += offset;
        }
    }
    
    if (actualPhotoHeight < viewHeight && self.contentHeightRatio != 1.0) {
        CGFloat yPadding = (contentViewHeight - viewHeight)/2.0;
        self.contentViewTopConstraint.constant = -yPadding;
        self.contentViewBottomConstraint.constant = yPadding;
    } else {
        CGFloat verticalEmptyLength = contentViewHeight * (1.0 - self.contentHeightRatio) / 2.0;
        if (self.contentViewTopConstraint.constant > -verticalEmptyLength) {
            CGFloat offset = -verticalEmptyLength - self.contentViewTopConstraint.constant;
            self.contentViewTopConstraint.constant += offset;
            self.contentViewBottomConstraint.constant += offset;
        }else if (self.contentViewBottomConstraint.constant < verticalEmptyLength) {
            CGFloat offset = verticalEmptyLength - self.contentViewBottomConstraint.constant;
            self.contentViewTopConstraint.constant += offset;
            self.contentViewBottomConstraint.constant += offset;
        }
    }
    
    [self layoutIfNeeded];
}

@end
