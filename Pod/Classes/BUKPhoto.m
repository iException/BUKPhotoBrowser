//
//  BUKPhoto.m
//  Pods
//
//  Created by hyice on 15/8/11.
//
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
    self = [super init];
    
    if (self) {
        _photoUrl = photoUrl;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
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
    
    if (self.photoUrl) {
        __block CGFloat progress = 0;
        [[SDWebImageManager sharedManager] downloadImageWithURL:self.photoUrl options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            progress = receivedSize * 1.0 / expectedSize;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (finished) {
                progress = 1.0;
                self.photo = image;
            }
            handler(image, progress);
        }];
    }
}

@end
