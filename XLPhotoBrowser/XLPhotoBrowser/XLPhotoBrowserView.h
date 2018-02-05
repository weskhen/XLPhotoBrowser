//
//  XLPhotoBrowserView.h
//  XLPhotoBrower
//
//  Created by wujian on 2017/12/20.
//  Copyright © 2017年 xiaolian.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XLPhotoBrowserView;
@protocol XLPhotoBrowserViewDelegate <NSObject>

- (void)handleSingleTap:(XLPhotoBrowserView *)photoBrowserView;

@optional
- (void)handleDoubleTap:(XLPhotoBrowserView *)photoBrowserView;

-(void)handleLongTap:(XLPhotoBrowserView *)photoBrowserView;

- (void)handleDownPanGestureBegin:(XLPhotoBrowserView *)photoBrowserView;

- (void)handleDownPanGestureEnd:(XLPhotoBrowserView *)photoBrowserView isDissmiss:(BOOL)isDissmiss;

- (void)handleDownPanGestureMove:(CGFloat)comProgress;


- (void)handleUpPanGestureEnd:(XLPhotoBrowserView *)photoBrowserView;

@end
@interface XLPhotoBrowserView : UIView
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) NSUInteger viewTag;
@property (nonatomic, assign) BOOL beginLoadingImage; //是否正在loading

@property (nonatomic, weak) id <XLPhotoBrowserViewDelegate> delegate;

@property (nonatomic, copy) void (^singleTapBlock)(XLPhotoBrowserView *photoBrowserView);
@property (nonatomic, copy) void (^doubleTapBlock)(XLPhotoBrowserView *photoBrowserView);
@property (nonatomic, copy) void (^longTabBlock)(XLPhotoBrowserView *photoBrowserView);
/** 图片拖动进度 dragProgress 0代表开始 end 是否结束 **/
@property (nonatomic, copy) void (^panBeginBlock)(XLPhotoBrowserView *photoBrowserView);
@property (nonatomic, copy) void (^panEndBlock)(XLPhotoBrowserView *photoBrowserView, BOOL isDissmiss);
@property (nonatomic, copy) void (^panMoveBlock)(CGFloat dragProgress);

@property (nonatomic, copy) void (^upPanEndBlock)(XLPhotoBrowserView *photoBrowserView);

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)starLoadingContentView;

- (void)removeNoNeedToLoadConentView;

@end
