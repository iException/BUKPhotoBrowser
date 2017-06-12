//
//  BUKPhotoImageContentView.m
//  BUKPhotoBrowser
//
//  Created by Yiming Tang on 6/12/17.
//  Copyright (c) 2015 - 2017 Baixing, Inc. All rights reserved.
//

#import "BUKPhotoImageContentView.h"
#import "BUKPhoto.h"
#import "BUKPhotoView.h"

@implementation BUKPhotoImageContentView

#pragma mark - Accessors

@synthesize imageView = _imageView;
@synthesize activityIndicatorView = _activityIndicatorView;

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}


- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    return _activityIndicatorView;
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}


#pragma mark - Private

- (void)initialize {
    [self addSubview:self.imageView];
    [self addSubview:self.activityIndicatorView];
    [self setupViewConstraints];
}


- (void)setupViewConstraints {
    NSDictionary *views = @{
        @"imageView": self.imageView,
        @"activityIndicatorView": self.activityIndicatorView,
    };
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:kNilOptions metrics:nil views:views]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:kNilOptions metrics:nil views:views]];

    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
    [NSLayoutConstraint activateConstraints:@[centerXConstraint, centerYConstraint]];
}


#pragma mark - BUKPhotoImageContentView

- (void)setPhoto:(BUKPhoto *)photo withPhotoView:(BUKPhotoView *)photoView {
    if (!photo) {
        return;
    }

    [self.activityIndicatorView startAnimating];
    [photo getPhoto:^(UIImage *image, CGFloat progress) {
        [self.imageView setImage:image];

        if (progress >= 1.0) {
            [photoView adjustWithContentSize:image.size];
            [self.activityIndicatorView stopAnimating];
        }
    }];
}

@end
