//
//  XLDeviceOrientationInstance.h
//  XLPhotoBrower
//
//  Created by wujian on 2017/11/22.
//  Copyright © 2017年 wujian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    /** 默认只支持竖屏 **/
    XLDeviceOrientationPortrait = 0,
    XLDeviceOrientationLandscape,
    XLDeviceOrientationAll,
} XLDeviceOrientation;

/** 设备方向变换通知  object:NSString (XLDevicePortrait/XLDeviceLandscape)**/
extern NSString *const XLDeviceOrientationChangeNotification;
/** 设备竖屏 **/
extern NSString *const XLDevicePortrait;
/** 设备横屏 **/
extern NSString *const XLDeviceLandscape;


/** app当前页面方向变换通知  object:NSString (XLAppPortrait/XLAppLandscape)**/
extern NSString *const XLAppOrientationChangeNotification;
/** app当前页面竖屏 **/
extern NSString *const XLAppPortrait;
/** app当前页面横屏 **/
extern NSString *const XLAppLandscape;

@interface XLDeviceOrientationInstance : NSObject

+ (XLDeviceOrientationInstance *)sharedInstance;

/** 开始检测 app启动时调用 **/
- (void)startDetect;

/** 当前手机方向朝向 是否横排 **/
- (BOOL)currentDeviceLandscape;

/** 当前界面(状态栏)方向朝向是否横排 不是设备方向！！！！ **/
- (BOOL)currentAppLandscape;

@end
