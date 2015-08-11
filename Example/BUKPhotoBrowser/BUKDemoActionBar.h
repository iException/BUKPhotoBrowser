//
//  BUKDemoActionBar.h
//  BUKPhotoBrowser
//
//  Created by hyice on 15/8/11.
//  Copyright (c) 2015年 hyice. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VoidBlock)();

@interface BUKDemoActionBar : UIView

- (void)setLeftButtonWithTitle:(NSString *)title action:(VoidBlock)action;
- (void)setLeftButtonWithImage:(UIImage *)image action:(VoidBlock)action;

- (void)setCenterButtonWithTitle:(NSString *)title action:(VoidBlock)action;

- (void)setRightButtonWithTitle:(NSString *)title action:(VoidBlock)action;

@end
