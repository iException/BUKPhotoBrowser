//
//  BUKPhotoImageContentView.h
//  BUKPhotoBrowser
//
//  Created by Yiming Tang on 6/12/17.
//  Copyright (c) 2015 - 2017 Baixing, Inc. All rights reserved.
//

#import "BUKPhotoContentView.h"

@interface BUKPhotoImageContentView : UIView <BUKPhotoContentView>

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;

@end
