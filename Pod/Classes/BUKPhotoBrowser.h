//
//  BUKPhotoBrowser.h
//  Pods
//
//  Created by hyice on 15/8/11.
//
//

#import <UIKit/UIKit.h>
#import "BUKPhoto.h"

@class BUKPhotoBrowser;

@protocol BUKPhotoBrowserDataSource <NSObject>

@required
- (NSInteger)buk_numberOfPhotosForBrowser:(BUKPhotoBrowser *)browser;
- (BUKPhoto *)buk_photoBrowser:(BUKPhotoBrowser *)browser photoAtIndex:(NSUInteger)index;

@end


@protocol BUKPhotoBrowserDelegate <NSObject>

@optional
- (void)buk_photoBrowser:(BUKPhotoBrowser *)browser didScrollToIndex:(NSInteger)index;
- (void)buk_photoBrowserWillDismiss:(BUKPhotoBrowser *)browser;
- (void)buk_photoBrowser:(BUKPhotoBrowser *)browser didLongPressAtIndex:(NSInteger)index;

@end


@interface BUKPhotoBrowser : UIViewController

/**
 *  Get the index of the displaying BUKPhoto.
 */
@property (nonatomic, assign, readonly) NSInteger currentIndex;

/**
 *  Default is nil. If you want an actionBar to do more with the displaying photo, you can 
 *  set your own actionBar to this property. BUKPhotoBrowser will add the actionBar to self.view
 *  and keep the actionBar on the top of other view. 
 *
 *  @warning Be sure to setup the frame by yourself, or the actionBar will be put to the bottom
 *  with default height 60.
 */
@property (nonatomic, strong) UIView *actionBar;

/**
 *  If you still ned navigation bar in photo browser, set this flag to YES. Default is NO.
 */
@property (nonatomic, assign) BOOL showNavigationBar;

/**
 *  If you still ned status bar in photo browser, set this flag to YES. Default is NO.
 */
@property (nonatomic, assign) BOOL showStatusBar;

/**
 *  User can tap photo to dismiss/pop photo browser by default.
 *  If you don't want this feature, you can set this flag to YES.
 */
@property (nonatomic, assign) BOOL disableTapToDismiss;

@property (nonatomic, weak) id<BUKPhotoBrowserDelegate> delegate;

- (instancetype)initWithDataSource:(id<BUKPhotoBrowserDataSource>)dataSource
                     defaultIndex:(NSInteger)index;

/**
 *  Reload the view when dataSource changed, you can specify the index to show
 *  on the center.
 */
- (void)reloadBrowserWithDefaultIndex:(NSInteger)index;

@end
