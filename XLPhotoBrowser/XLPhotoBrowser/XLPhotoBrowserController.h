//
//  XLPhotoBrowserController.h
//  XLPhotoBrower
//
//  Created by wujian on 2018/1/31.
//  Copyright © 2018年 xiaolian.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLController.h"

@class XLPhotoBrowserController;

@protocol XLPhotoBrowserControllerDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(XLPhotoBrowserController *)browser placeholderImageForIndex:(NSInteger)index;

- (void)didHidePhotoBrowser:(XLPhotoBrowserController *)photoBrowser index:(NSInteger)index;

@optional

- (CGRect)smallPicRectForIndex:(NSInteger)index;

- (NSURL *)photoBrowser:(XLPhotoBrowserController *)browser highQualityImageURLForIndex:(NSInteger)index;

- (void)photoBrowser:(XLPhotoBrowserController *)browser doubleTap:(NSInteger)index;

- (void)photoBrowser:(XLPhotoBrowserController *)browser longTap:(NSInteger)index;

- (void)photoBrowser:(XLPhotoBrowserController *)browser deleteItemForIndex:(NSInteger)index;

- (void)photoBrowser:(XLPhotoBrowserController *)browser previewItemForIndex:(NSInteger)index;

@end

typedef enum : NSUInteger {
    /** 无特殊图标 **/
    XLPhotoBrowserControllerEditTypeNone = 0,
    /** 删除当前图片模式 **/
    XLPhotoBrowserControllerEditTypeDelete,
    /** 预览模式 **/
    XLPhotoBrowserControllerEditTypePreview,
} XLPhotoBrowserControllerEditType;

@interface XLPhotoBrowserController : XLController <UIScrollViewDelegate>

/** 是否支持横屏 默认支持**/
@property (nonatomic, assign) BOOL shouldLandscape;

@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) int currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;

@property (nonatomic, weak) id<XLPhotoBrowserControllerDelegate> delegate;

/** show 大图 **/
- (void)showWithOrignPicRect:(CGRect)rect editType:(XLPhotoBrowserControllerEditType)type;

/** 动画结束 **/
- (void)removePhotoBrower;

/** 定位到指定位置页面 **/
- (void)reloadCurrentViewWithIndex:(int)index;

@end
