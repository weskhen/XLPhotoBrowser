//
//  XLNavigationController.m
//  XLPhotoBrowser
//
//  Created by wujian on 2018/2/2.
//  Copyright © 2018年 wujian. All rights reserved.
//

#import "XLNavigationController.h"

@interface XLNavigationController ()

@end

@implementation XLNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 控制屏幕旋转方法
- (BOOL)shouldAutorotate{
    return [[self.viewControllers lastObject]shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [[self.viewControllers lastObject]supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
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
