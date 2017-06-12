//
//  BUKPhotoContentView.h
//  BUKPhotoBrowser
//
//  Created by Yiming Tang on 6/12/17.
//  Copyright (c) 2017 Baixing, Inc. All rights reserved.
//

@class BUKPhoto;
@class BUKPhotoView;

@protocol BUKPhotoContentView <NSObject>

@required
- (void)setPhoto:(BUKPhoto *)photo withPhotoView:(BUKPhotoView *)photoView;

@end
