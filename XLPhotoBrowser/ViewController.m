//
//  ViewController.m
//  XLPhotoBrowser
//
//  Created by wujian on 2018/2/2.
//  Copyright © 2018年 wujian. All rights reserved.
//

#import "ViewController.h"
#import "XLPhotoCollectionView.h"
#import "XLPhotoBrowerHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    XLPhotoCollectionView *photoView = [[XLPhotoCollectionView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 300)];
    
    NSMutableArray *photoModelArr = [[NSMutableArray alloc] init];
    
    XLPhotoModel *photoModel1 = [[XLPhotoModel alloc] initWithsmallImageURL:@"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg" bigImageURL:@"http://ww2.sinaimg.cn/bmiddle/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg"];
    XLPhotoModel *photoModel2 = [[XLPhotoModel alloc] init];
    photoModel2.smallImageURL = @"http://ww4.sinaimg.cn/thumbnail/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg";
    photoModel2.bigImageURL = @"http://ww4.sinaimg.cn/bmiddle/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg";

    XLPhotoModel *photoModel3 = [[XLPhotoModel alloc] initWithsmallImageURL:@"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif" bigImageURL:@"http://ww2.sinaimg.cn/bmiddle/642beb18gw1ep3629gfm0g206o050b2a.gif"];
    XLPhotoModel *photoModel4 = [[XLPhotoModel alloc] init];
    photoModel4.smallImageURL = @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg";
    photoModel4.bigImageURL = @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg";
    XLPhotoModel *photoModel5 = [[XLPhotoModel alloc] initWithsmallImageURL:@"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg" bigImageURL:@"http://ww2.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg"];
    XLPhotoModel *photoModel6 = [[XLPhotoModel alloc] initWithsmallImageURL:@"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg" bigImageURL:@"http://ww4.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg"];
    XLPhotoModel *photoModel7 = [[XLPhotoModel alloc] initWithsmallImageURL:@"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg" bigImageURL:@"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"];
    XLPhotoModel *photoModel8 = [[XLPhotoModel alloc] initWithsmallImageURL:@"http://ww2.sinaimg.cn/thumbnail/677febf5gw1erma104rhyj20k03dz16y.jpg" bigImageURL:@"http://ww2.sinaimg.cn/bmiddle/677febf5gw1erma104rhyj20k03dz16y.jpg"];
    XLPhotoModel *photoModel9 = [[XLPhotoModel alloc] initWithsmallImageURL:@"http://ww4.sinaimg.cn/thumbnail/677febf5gw1erma1g5xd0j20k0esa7wj.jpg" bigImageURL:@"http://ww4.sinaimg.cn/bmiddle/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"];

    [photoModelArr addObject:photoModel1];
    [photoModelArr addObject:photoModel2];
    [photoModelArr addObject:photoModel3];
    [photoModelArr addObject:photoModel4];
    [photoModelArr addObject:photoModel5];
    [photoModelArr addObject:photoModel6];
    [photoModelArr addObject:photoModel7];
    [photoModelArr addObject:photoModel8];
    [photoModelArr addObject:photoModel9];
    
    [photoView loadCollectionWithPhotoModelArray:photoModelArr viewWidth:SCREEN_WIDTH];
    [self.view addSubview:photoView];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
