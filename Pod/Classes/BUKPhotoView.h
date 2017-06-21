//
//  BUKPhotoView.h
//  BUKPhotoBrowser
//
//  Created by hyice on 15/8/11.
//  Copyright (c) 2015 - 2017 Baixing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BUKPhotoViewOverflowDirection) {
    BUKPhotoViewOverflowLeftDirection,
    BUKPhotoViewOverflowRightDirection,
    BUKPhotoViewOverflowTopDirection,
    BUKPhotoViewOverflowBottomDirection
};

@class BUKPhoto;
@protocol BUKPhotoContentView;

@interface BUKPhotoView : UIView

@property (nonatomic) UIView<BUKPhotoContentView> *contentView;
@property (nonatomic) BOOL pinchEnabled;

- (void)setupViewWithPhoto:(BUKPhoto *)photo;
- (void)adjustWithContentSize:(CGSize)size;
- (void)translateImage:(CGPoint)translation animated:(BOOL)animated;
- (CGFloat)contentOverflowLengthForDirection:(BUKPhotoViewOverflowDirection)direction;

@end
