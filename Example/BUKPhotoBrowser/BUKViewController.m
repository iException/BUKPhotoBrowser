//
//  BUKViewController.m
//  BUKPhotoBrowser
//
//  Created by hyice on 08/11/2015.
//  Copyright (c) 2015 hyice. All rights reserved.
//

#import "BUKViewController.h"
#import <BUKPhotoBrowser/BUKPhotoBrowser.h>
#import "BUKDemoActionBar.h"

@interface BUKViewController () <BUKPhotoBrowserDataSource, BUKPhotoBrowserDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, assign) NSInteger coverIndex;
@property (nonatomic, weak) BUKPhotoBrowser *browser;

@end

@implementation BUKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"DEMO";

    UIButton *browserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [browserBtn setTitle:@"browser" forState:UIControlStateNormal];
    [browserBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    browserBtn.backgroundColor = [UIColor orangeColor];
    browserBtn.layer.cornerRadius = 5;
    browserBtn.clipsToBounds = YES;
    [browserBtn addTarget:self action:@selector(browserBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:browserBtn];
    
    browserBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:browserBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:browserBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:browserBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:browserBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50]];
}

- (void)browserBtnPressed:(id)sender
{
    self.photos = nil;
    self.coverIndex = 0;
    
    BUKPhotoBrowser *browser = [[BUKPhotoBrowser alloc] initWithDataSource:self defaultIndex:0];
    browser.actionBar = [self actionBar];
    browser.delegate = self;

    [self.navigationController pushViewController:browser animated:YES];
    
    self.browser = browser;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // save
        BUKPhoto *photo = [self.photos objectAtIndex:self.browser.currentIndex];
        [photo getPhoto:^(UIImage *image, CGFloat progress) {
            if (progress == 1.0) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            }
        }];
    }
}

#pragma mark - BUKPhotoBrowserDataSource
- (NSInteger)buk_numberOfPhotosForBrowser:(BUKPhotoBrowser *)browser
{
    return self.photos.count;
}

- (BUKPhoto *)buk_photoBrowser:(BUKPhotoBrowser *)browser photoAtIndex:(NSUInteger)index
{
    return [self.photos objectAtIndex:index];
}

#pragma mark - BUKPhotoBrowserDelegate
- (void)buk_photoBrowser:(BUKPhotoBrowser *)browser didLongPressAtIndex:(NSInteger)index
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"保存到相册" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: nil];
    [sheet addButtonWithTitle:@"保存"];
    [sheet showInView:self.view];
}

- (void)buk_photoBrowser:(BUKPhotoBrowser *)browser didScrollToIndex:(NSInteger)index
{
    BUKDemoActionBar *actionBar = (BUKDemoActionBar *)browser.actionBar;
    [self updateActionBar:actionBar withIndex:index];
    
}

#pragma mark - private
- (void)updateActionBar:(BUKDemoActionBar *)actionBar withIndex:(NSInteger)index
{
    if (index != self.coverIndex) {
        __weak typeof(self) weakSelf = self;
        __weak typeof(actionBar) weakActionBar = actionBar;
        [actionBar setCenterButtonWithTitle:@"Set Cover" action:^{
            NSLog(@"Set to Cover!");
            weakSelf.coverIndex = index;
            [weakActionBar setCenterButtonWithTitle:@"Cover" action:nil];
        }];
    } else {
        [actionBar setCenterButtonWithTitle:@"Cover" action:nil];
    }
}

#pragma mark - getters
- (NSArray *)photos
{
    if (!_photos) {
        
        NSArray *testData = @[
                              [[BUKPhoto alloc] initWithUrl:[NSURL URLWithString:@"http://e.hiphotos.baidu.com/image/pic/item/4610b912c8fcc3cedf3350329045d688d43f203b.jpg"]],
                              [[BUKPhoto alloc] initWithUrl:[NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/9213b07eca806538774f7a5295dda144ac3482ce.jpg"]],
                              [[BUKPhoto alloc] initWithUrl:[NSURL URLWithString:@"http://a.hiphotos.baidu.com/image/pic/item/d833c895d143ad4ba1fb09c180025aafa50f06dd.jpg"]],
                              [[BUKPhoto alloc] initWithUrl:[NSURL URLWithString:@"http://a.hiphotos.baidu.com/image/pic/item/6a600c338744ebf8e26c003fdbf9d72a6059a795.jpg"]],
                              [[BUKPhoto alloc] initWithUrl:[NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/pic/item/cb8065380cd791231ac87a75af345982b2b78083.jpg"]],
                              [[BUKPhoto alloc] initWithUrl:[NSURL URLWithString:@"http://e.hiphotos.baidu.com/image/pic/item/faf2b2119313b07e16c1ed1b0ed7912397dd8ca1.jpg"]]
                              ];
        _photos = [[NSMutableArray alloc] initWithArray:testData];
    }
    
    return _photos;
}

- (BUKDemoActionBar *)actionBar
{
    BUKDemoActionBar *actionBar = [[BUKDemoActionBar alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [actionBar setLeftButtonWithTitle:@"Back" action:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    [actionBar setRightButtonWithTitle:@"Delete" action:^{
        NSInteger currentIndex= weakSelf.browser.currentIndex;
        [weakSelf.photos removeObjectAtIndex:currentIndex];
        NSInteger count = weakSelf.photos.count;
        if (count == 0) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else if (currentIndex < count) {
            [weakSelf.browser reloadBrowserWithDefaultIndex:currentIndex];
        } else {
            [weakSelf.browser reloadBrowserWithDefaultIndex:count - 1];
        }

    }];
    
    [actionBar setCenterButtonWithTitle:@"Cover" action:nil];
    
    return actionBar;
}

@end
