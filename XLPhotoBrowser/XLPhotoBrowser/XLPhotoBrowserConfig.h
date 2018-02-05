//
//  XLPhotoBrowserConfig.h
//  XLPhotoBrower
//
//  Created by wujian on 2018/1/31.
//  Copyright © 2018年 xiaolian.Inc. All rights reserved.
//

#ifndef XLPhotoBrowserConfig_h
#define XLPhotoBrowserConfig_h

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
//weakSelf 宏定义
#define XLWEAKSELF    __weak __typeof(&*self)weakSelf = self;
#define XLSTRONGSELF  __strong __typeof(weakSelf) strongSelf = weakSelf;
#define XLLog(...) NSLog(__VA_ARGS__)
#define XLDefaultImage [UIImage imageNamed:@"icon_defaultImage"]

typedef enum : NSUInteger {
    /** 直接消失 **/
    XLPhotoDisMissAnimationNone = 0,
    /** 回到原图位置 **/
    XLPhotoDisMissAnimationToOrign,
    /** 淡化消失 **/
    XLPhotoDisMissAnimationFades,
    /** 向上飞 **/
    XLPhotoDisMissAnimationUpFly,
} XLPhotoDismissAnimation;
typedef enum : NSUInteger {
    /** 原型空心 **/
    XLWaitingViewModeLoopDiagram,
    /** 原型实心 **/
    XLWaitingViewModePieDiagram,
} XLWaitingViewMode;

typedef enum : NSUInteger {
    /** 默认 分页条UIPageControl **/
    XLPageTypeModePageController = 0,
    /** 数字展示图片数量 **/
    XLPageTypeModePageNum,
} XLPageTypeMode;

#define XLFullWidthForLandScape NO //是否在横屏的时候直接满宽度，而不是满高度，一般是在有长图需求的时候设置为YES     Whether directly when landscape full width, rather than the full height, usually with long figure demand when set to YES

#define XLPhotoMaxCount 9 //能展示最大多少张图片（如果实际图片数量大于此数量，默认显示前面的图片）


//小图界面下 个张小图之间的间距    The distance between the interface of a small map of Zhang map
#define XLPhotoGroupImageMargin 4
//小图界面下 整个展示图片的控件的四周内边距  Around the small map interface display of the entire picture controls padding
#define XLPhotoEdgeInsets 0

#define XLMinZoomScale 0.6f
#define XLMaxZoomScale 2.0f

/** 大图展示最小尺寸 **/
#define XLBigImageDefaultSize 100.f

// 照片浏览器中 屏幕旋转时 使用这个时间 来做动画修改图片的展示
#define XLAnimationDuration 0.35f

#define XLPanResetAnimationDuration 0.35f

//最多移动多少时，页面完全透明，图片达到最小状态
#define XLPhotoPanMaxLimit 150

/** 图片向上拖动多大距离 触发飞走的逻辑 **/
#define XLPhotoUpPanMaxLimit 90

/** 图片缩小的占比 **/
#define XLPhotoMinZoom 0.6f

//小图模式下 背景颜色  Background color in thumbnail mode
#define XLSmallPhotoBackgrounColor [UIColor whiteColor]

// 照片浏览器的背景颜色  Background color for photo browser
#define XLPhotoBrowserBackgrounColor [UIColor blackColor]

// 照片浏览器中 图片之间的margin
#define XLPhotoBrowserImageViewMargin 10

// 照片浏览器中 图片显示从小图到大图时长
#define XLPhotoBrowserShowImageAnimationDuration 0.35f

// 照片浏览器中 隐藏 图片显示从大图到小图时长
#define XLPhotoBrowserHideImageAnimationDuration 0.35f


// 图片下载进度指示器背景色
#define XLWaitingViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

// 图片下载进度指示器内部控件间的间距
#define XLWaitingViewItemMargin 10

#endif /* XLPhotoBrowserConfig_h */
