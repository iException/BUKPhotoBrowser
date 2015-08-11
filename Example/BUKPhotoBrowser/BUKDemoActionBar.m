//
//  BUKDemoActionBar.m
//  BUKPhotoBrowser
//
//  Created by hyice on 15/8/11.
//  Copyright (c) 2015年 hyice. All rights reserved.
//

#import "BUKDemoActionBar.h"

@interface BUKDemoActionBar ()

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, copy) VoidBlock leftAction;
@property (nonatomic, copy) VoidBlock rightAction;
@property (nonatomic, copy) VoidBlock titleAction;

@end

@implementation BUKDemoActionBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initBackgroundView];
        [self initLeftButton];
        [self initTitleButton];
        [self initRightButton];
        [self initSwallowTap];
    }
    
    return self;
}

- (void)setLeftButtonWithTitle:(NSString *)title action:(VoidBlock)action
{
    [self.leftButton setTitle:title forState:UIControlStateNormal];
    self.leftAction = action;
}

- (void)setLeftButtonWithImage:(UIImage *)image action:(VoidBlock)action
{
    [self.leftButton setImage:image forState:UIControlStateNormal];
    self.leftAction = action;
}

- (void)setCenterButtonWithTitle:(NSString *)title action:(VoidBlock)action
{
    [self.titleButton setTitle:title forState:UIControlStateNormal];
    self.titleAction = action;
    if (action) {
        self.titleButton.backgroundColor = [UIColor colorWithRed:0x6d/255.0 green:0xd0/255.0 blue:0x28/255.0 alpha:1.0];
    }else {
        self.titleButton.backgroundColor = [UIColor clearColor];
    }
}

- (void)setRightButtonWithTitle:(NSString *)title action:(VoidBlock)action
{
    [self.rightButton setTitle:title forState:UIControlStateNormal];
    self.rightAction = action;
}

#pragma mark - init views
- (void)initBackgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.7;
        [self addSubview:_backgroundView];
        
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_backgroundView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_backgroundView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundView)]];
    }
}

- (void)initLeftButton
{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftButton];
        
        _leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_leftButton(60)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftButton)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_leftButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_leftButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:15]];
    }
}

- (void)leftButtonPressed
{
    if (self.leftAction) {
        self.leftAction();
    }
}

- (void)initTitleButton
{
    if (!_titleButton) {
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _titleButton.layer.cornerRadius = 3;
        _titleButton.clipsToBounds = YES;
        [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleButton addTarget:self action:@selector(titleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleButton];
        
        _titleButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:75]];
    }
}

- (void)titleButtonPressed
{
    if (self.titleAction) {
        self.titleAction();
    }
}

- (void)initRightButton
{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightButton];
        
        _rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightButton(60)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_rightButton)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_rightButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_rightButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:15]];
    }
}

- (void)rightButtonPressed
{
    if (self.rightAction) {
        self.rightAction();
    }
}

- (void)initSwallowTap
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swallowTap)];
    [self addGestureRecognizer:tap];
}

- (void)swallowTap {}

@end
