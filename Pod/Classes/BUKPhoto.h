//
//  BUKPhoto.h
//  BUKPhotoBrowser
//
//  Created by hyice on 15/8/11.
//  Copyright (c) 2015 - 2017 Baixing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BUKPhoto : NSObject

- (instancetype)initWithUrl:(NSURL *)photoUrl;
- (instancetype)initWithImage:(UIImage *)image;

/**
 *  If photo was inited with image, method will directly return the image.
 *
 *  If photo was inited with url, method will try to download the photo. During downloading,
 *  method will call the handler several times with partial image and specified progress. When
 *  photo is downloaded, progress will be 1.0. Method will use cache to avoid downloading multi
 *  times.
 *
 *  @param handler Handler can be called multi times if image was downloading from url.
 */
- (void)getPhoto:(void (^)(UIImage *image, CGFloat progress))handler;

@end
