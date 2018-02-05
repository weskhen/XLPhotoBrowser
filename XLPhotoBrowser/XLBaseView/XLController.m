//
//  XLController.m
//  XLPhotoBrowser
//
//  Created by wujian on 2018/2/2.
//  Copyright © 2018年 wujian. All rights reserved.
//

#import "XLController.h"

@interface XLController ()

@end

@implementation XLController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //很重要!
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

/** 状态栏字体白色 UIStatusBarStyleDefault黑色 **/
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

//是否支持多方向旋转屏，如果返回NO则后面的两个方法都不会再被调用，而且只会支持默认
- (BOOL)shouldAutorotate
{
    return NO;
}

//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
