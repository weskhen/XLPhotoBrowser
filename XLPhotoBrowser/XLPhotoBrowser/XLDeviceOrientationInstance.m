//
//  XLDeviceOrientationInstance.m
//  XLPhotoBrower
//
//  Created by wujian on 2017/11/22.
//  Copyright © 2017年 wujian. All rights reserved.
//

#import "XLDeviceOrientationInstance.h"
#import <UIKit/UIKit.h>


/** 设备方向变换通知 **/
NSString *const XLDeviceOrientationChangeNotification = @"XLDeviceOrientationChangeNotification";
/** 设备竖屏 **/
NSString *const XLDevicePortrait = @"XLDevicePortrait";

/** 设备横屏 **/
NSString *const XLDeviceLandscape = @"XLDeviceLandscape";

/** app当前页面方向变换通知 **/
NSString *const XLAppOrientationChangeNotification = @"XLAppOrientationChangeNotification";
/** app当前页面竖屏 **/
NSString *const XLAppPortrait = @"XLAppPortrait";

/** app当前页面横屏 **/
NSString *const XLAppLandscape = @"XLAppLandscape";

@interface XLDeviceOrientationInstance ()

/** 设备是否横屏 **/
@property (nonatomic, assign) BOOL isDeviceLandscape;

/** app页面状态栏是否横屏 **/
@property (nonatomic, assign) BOOL isAppLandscape;
@end
@implementation XLDeviceOrientationInstance

+ (XLDeviceOrientationInstance *)sharedInstance
{
    static XLDeviceOrientationInstance *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [XLDeviceOrientationInstance new];
    });
    return instance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - publicMethod
- (void)startDetect
{
    //开启和监听 设备旋转的通知（不开启的话，设备方向一直是UIInterfaceOrientationUnknown）
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    
    //第一次不区分平躺情况 默认竖屏
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    self.isDeviceLandscape = UIDeviceOrientationIsLandscape(orientation);
    
//    //监听设备状态栏frame变化 可用来监控设备位置变化 但在app(info.plist)强制横屏或竖屏后 此方法不会触发
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    //监听设备朝向 设备frame变化不及时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];

    //监测手机状态栏变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (BOOL)currentDeviceLandscape
{
    return self.isDeviceLandscape;
}

- (BOOL)currentAppLandscape
{
    return self.isAppLandscape;
}

#pragma mark - NSNotification
-(void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationUnknown ||
        orientation == UIDeviceOrientationFaceUp ||
        orientation == UIDeviceOrientationFaceDown) {
        //不明确的朝向 不改变
        return ;
    }
    BOOL currentDeviceLandscape = UIDeviceOrientationIsLandscape(orientation);
    if (self.isDeviceLandscape != currentDeviceLandscape) {
        self.isDeviceLandscape = currentDeviceLandscape;
    }
    if (currentDeviceLandscape) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XLDeviceOrientationChangeNotification object:XLDeviceLandscape];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:XLDeviceOrientationChangeNotification object:XLDevicePortrait];
    }
}

/**
 *  当手机屏幕发生变化时，会回调下面方法
 */
- (void)statusBarOrientationChange:(NSNotification *)notification{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    BOOL currenLandscape = NO;
    if (orientation == UIInterfaceOrientationLandscapeRight)//home键向右
    {
        NSLog(@"home键向右");
        currenLandscape = YES;
    }
    if (
        orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左
    {
        NSLog(@"home键向左");
        currenLandscape = YES;
    }
    
    if (orientation == UIInterfaceOrientationPortrait)// home键靠下
    {
        NSLog(@"home键靠下");
        currenLandscape = NO;
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)// home键颠倒
    {
        NSLog(@"home键靠颠倒");
        currenLandscape = NO;
    }
    //当前设备方向
    if (self.isAppLandscape != currenLandscape) {
        self.isAppLandscape = currenLandscape;
    }
    if (currenLandscape) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XLAppOrientationChangeNotification object:XLAppLandscape];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:XLAppOrientationChangeNotification object:XLAppPortrait];
    }

}
#pragma mark - setter/getter
@end
