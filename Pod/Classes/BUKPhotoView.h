//
//  BUKPhotoView.h
//  Pods
//
//  Created by hyice on 15/8/11.
//
//

#import <UIKit/UIKit.h>

@class BUKPhoto;

typedef NS_ENUM(NSInteger, BUKPhotoViewOverflowDirection) {
    BUKPhotoViewOverflowLeftDirection,
    BUKPhotoViewOverflowRightDirection,
    BUKPhotoViewOverflowTopDirection,
    BUKPhotoViewOverflowBottomDirection
};

@interface BUKPhotoView : UIView

- (void)setupViewWithPhoto:(BUKPhoto *)photo;

- (void)translateImage:(CGPoint)translation animated:(BOOL)animated;

- (CGFloat)imageOverflowLengthForDirection:(BUKPhotoViewOverflowDirection)direction;

@end
