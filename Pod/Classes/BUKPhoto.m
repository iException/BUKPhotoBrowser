//
//  BUKPhoto.m
//  BUKPhotoBrowser
//
//  Created by hyice on 15/8/11.
//  Copyright (c) 2015 - 2017 Baixing, Inc. All rights reserved.
//

#import "BUKPhoto.h"
#import "SDWebImageManager.h"

@interface BUKPhoto ()

@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSURL *photoUrl;

@end

@implementation BUKPhoto

- (instancetype)initWithUrl:(NSURL *)photoUrl
{
    NSAssert(!photoUrl || [photoUrl isKindOfClass:[NSURL class]], @"BUKPhoto: photoUrl is not NSURL!");
    
    self = [super init];
    
    if (self) {
        _photoUrl = photoUrl;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    NSAssert(!image || [image isKindOfClass:[UIImage class]], @"BUKPhoto: image is not UIImage!");
    
    self = [super init];
    
    if (self) {
        self.photo = image;
    }
    
    return self;
}

- (void)setPhoto:(UIImage *)photo
{
    if ([photo isKindOfClass:[UIImage class]]) {
        _photo = photo;
    }
}

- (void)getPhoto:(void (^)(UIImage *, CGFloat))handler
{
    if (!handler) {
        return;
    }
    
    if (self.photo) {
        handler(self.photo, 1.0);
        return;
    }
    
    if (!self.photoUrl) {
        handler(nil, 1.0);
        return;
    }
    
    UIImage *photo = [UIImage imageWithContentsOfFile:self.photoUrl.absoluteString];
    if (photo) {
        self.photo = photo;
        handler(photo, 1.0);
        return;
    }
    
    __block CGFloat progress = 0;
    __weak typeof(self)weakSelf = self;
    [[SDWebImageManager sharedManager] loadImageWithURL:self.photoUrl options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        progress = receivedSize * 1.0 / expectedSize;
        handler(nil, progress);
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (finished) {
            progress = 1.0;
            strongSelf.photo = image;
        }
        handler(image, progress);
    }];
}

@end
