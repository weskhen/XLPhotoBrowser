//
//  XLPhotoBrowserController.m
//  XLPhotoBrower
//
//  Created by wujian on 2018/1/31.
//  Copyright © 2018年 xiaolian.Inc. All rights reserved.
//

#import "XLPhotoBrowserController.h"
#import "UIImageView+WebCache.h"
#import "XLPhotoBrowserView.h"
#import "XLMutableDictionary.h"
#import "XLWindow.h"
#import "XLPhotoBrowserConfig.h"
#import "Masonry.h"

#import "XLNavigationController.h"

@interface XLPhotoBrowserController ()<XLPhotoBrowserViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *previewButton;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, assign) XLPageTypeMode currentTypeModel;

@property (nonatomic, strong) XLWindow *picWindow;
@property (nonatomic, strong) XLMutableDictionary *cacheViewDic;//缓存展示过的对象

@property (nonatomic, assign) BOOL isLandscape;//是否是横屏
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;//当前设备朝向

@property (nonatomic, assign) BOOL isInChangeOrientation;//是否正在转屏动画中
@end

@implementation XLPhotoBrowserController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldLandscape = YES;
        self.isLandscape = NO; //默认一进来时竖屏
        self.deviceOrientation = UIDeviceOrientationPortrait;
        self.cacheViewDic = [[XLMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.shouldLandscape) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didRemoveContentView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    _bgView.hidden = YES;
    [_bgView removeFromSuperview];
    _bgView = nil;
    _picWindow.hidden = YES;
    _picWindow = nil;
    
    if ([_delegate respondsToSelector:@selector(didHidePhotoBrowser:index:)]) {
        [_delegate didHidePhotoBrowser:self index:self.currentImageIndex];
    }
    
}

#pragma mark - privateMethod
/** 系统方法 父试图改变的时候调用 被addSubView时默认调用 **/
- (void)addContentSubViewsWithEditType:(XLPhotoBrowserControllerEditType)type
{
    //添加滚动盒子
    [self.view addSubview:self.scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(-XLPhotoBrowserImageViewMargin);
        make.trailing.equalTo(self.view).offset(XLPhotoBrowserImageViewMargin);
        make.top.bottom.equalTo(self.view);
    }];
    
    CGFloat scrollWidth = XLPhotoBrowserImageViewMargin * 2+SCREEN_WIDTH;
    for (int i = 0; i < self.imageCount; i++) {
        XLPhotoBrowserView *view = [[XLPhotoBrowserView alloc] init];
        view.viewTag = i;
        view.delegate = self;
        //添加每一张展示的图片 XLPhotoBrowserControllerView
        [_scrollView addSubview:view];
        CGFloat x = i * scrollWidth;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(SCREEN_HEIGHT);
            make.centerY.equalTo(_scrollView);
            make.centerX.equalTo(_scrollView).offset(x);
        }];
    }
    
    _scrollView.contentSize = CGSizeMake(self.imageCount * scrollWidth, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * scrollWidth, 0);
    
    if (self.imageCount > 1) {
        if (self.currentTypeModel == XLPageTypeModePageNum) {
            //数字提示
            [self.view addSubview:self.indexLabel];
            _indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
            [_indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.top.equalTo(self.view).offset(20);
                make.size.mas_equalTo(CGSizeMake(80, 30));
            }];
            
        }
        else if (self.currentTypeModel == XLPageTypeModePageController)
        {
            //pageController 滚动条提示
            [self.view addSubview:self.pageControl];
            _pageControl.numberOfPages = self.imageCount;
            [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.bottom.equalTo(self.view).offset(-30);
            }];
        }
    }
    
    if (type == XLPhotoBrowserControllerEditTypeDelete) {
        [self.view addSubview:self.deleteButton];
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(22);
            make.trailing.equalTo(self.view).offset(-22);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
    }
    else if (type == XLPhotoBrowserControllerEditTypePreview)
    {
        [self.view addSubview:self.previewButton];
        [_previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-30);
            make.trailing.equalTo(self.view).offset(-20);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
    }
    //展示当前的图片
    [self.view layoutIfNeeded];
    [self scrollViewDidScroll:self.scrollView];
    
    //    [self setupImageOfImageViewForIndex:self.currentImageIndex];
}

/** 刷新页面数量标识 **/
- (void)reloadPageNum
{
    if (self.imageCount > 0) {
        _pageControl.numberOfPages = self.imageCount;
    }
}

- (void)starAnimationWithSmallPicRect:(CGRect)rect
{
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.frame = rect;
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    
    [self.view addSubview:tempView];
    tempView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat placeImageSizeW = tempView.image.size.width;
    CGFloat placeImageSizeH = tempView.image.size.height;
    CGRect targetTemp;
    
    if (self.isLandscape) {
        //横屏 宽比长大
        CGFloat placeHolderW = (placeImageSizeH * SCREEN_HEIGHT)/placeImageSizeW;
        if (placeHolderW <= SCREEN_WIDTH) {
            targetTemp = CGRectMake((SCREEN_WIDTH - placeHolderW) * 0.5,  0, placeHolderW, SCREEN_HEIGHT);
        } else {
            targetTemp = CGRectMake(0, 0, placeHolderW, SCREEN_HEIGHT);
        }
    }
    else{
        //横屏 长比宽大
        CGFloat placeHolderH = (placeImageSizeH * SCREEN_WIDTH)/placeImageSizeW;
        if (placeHolderH <= SCREEN_HEIGHT) {
            targetTemp = CGRectMake(0, (SCREEN_HEIGHT - placeHolderH) * 0.5 , SCREEN_WIDTH, placeHolderH);
        } else {
            targetTemp = CGRectMake(0, 0, SCREEN_WIDTH, placeHolderH);
        }
    }
    
    
    [UIView animateWithDuration:XLPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
    } completion:^(BOOL finished) {
        tempView.hidden = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
        _indexLabel.hidden = NO;
        _pageControl.hidden = NO;
        _deleteButton.hidden = NO;
    }];
    
    [self.picWindow addSubview:self.view];
    
}

/** 只缓存当前view的左右视图 **/
- (void)checkLoadPhotoBrowserView:(NSArray *)list
{
    NSMutableArray *unAddList = [[NSMutableArray alloc] init];
    //被释放的view列表
    for (NSNumber *lastIndex in self.cacheViewDic.allKeys) {
        BOOL addAgain = NO; //是否在新的列表中
        for (NSNumber *newIndex in list) {
            if (lastIndex.integerValue == newIndex.integerValue) {
                addAgain = YES;
                break;
            }
        }
        if (addAgain == NO) {
            //不在新的列表中
            [unAddList addObject:lastIndex];
        }
    }
    
    for (NSNumber *index in unAddList) {
        XLPhotoBrowserView *view = [self.cacheViewDic objectForKey:index];
        if (view == nil) {//不应该进入这里,如果进入了需要看一下原因
            XLLog(@"有BUG 了!!!!!!!!");
            continue;
        }
        [view removeNoNeedToLoadConentView];
        view.beginLoadingImage = NO;
        [self.cacheViewDic removeObjectForKey:index];
    }
}

- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    XLPhotoBrowserView *view = _scrollView.subviews[index];
    if (view.beginLoadingImage) return;
    [view starLoadingContentView];
    NSURL *highQualityImageURL = [self highQualityImageURLForIndex:index];
    if (highQualityImageURL) {
        [view setImageWithURL:highQualityImageURL placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        view.imageview.image = [self placeholderImageForIndex:index];
    }
    view.beginLoadingImage = YES;
    
    [self.cacheViewDic setObject:view forKey:@(index)];
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}


/** 退出大图模式 **/
- (void)hidePhotoBrowser:(XLPhotoBrowserView *)view animationType:(XLPhotoDismissAnimation)animationType
{
    _indexLabel.hidden = YES;
    _scrollView.hidden = YES;
    _pageControl.hidden = YES;
    _indexLabel = nil;
    _pageControl = nil;
    
    switch (animationType) {
        case XLPhotoDisMissAnimationNone:
            //直接消失
            [self didRemoveContentView];
            break;
        case XLPhotoDisMissAnimationToOrign:
        {
            CGRect rect = CGRectZero;
            if ([_delegate respondsToSelector:@selector(smallPicRectForIndex:)]) {
                rect = [_delegate smallPicRectForIndex:self.currentImageIndex];
            }
            if (view && rect.size.width != 0 && rect.size.height != 0) {
                
                //cell frame 隐藏图片
                UIImageView *tempImageView = [[UIImageView alloc] initWithImage:view.imageview.image];
                tempImageView.frame = view.imageview.frame;
                tempImageView.contentMode = UIViewContentModeScaleAspectFill;
                [self.view addSubview:tempImageView];
                
                XLWEAKSELF
                [UIView animateWithDuration:XLPhotoBrowserHideImageAnimationDuration animations:^{
                    tempImageView.clipsToBounds = YES;
                    tempImageView.frame = rect;
                    _picWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                } completion:^(BOOL finished) {
                    tempImageView.hidden = YES;
                    [tempImageView removeFromSuperview];
                    XLSTRONGSELF
                    [strongSelf didRemoveContentView];
                }];
            }
            else{
                //直接消失
                [self didRemoveContentView];
            }
        }
            break;
        case XLPhotoDisMissAnimationFades:
        {
            //横屏消失动画 淡出
            XLWEAKSELF
            [UIView animateWithDuration:XLPhotoBrowserHideImageAnimationDuration animations:^{
                view.alpha = 0;
                _picWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
            } completion:^(BOOL finished) {
                XLSTRONGSELF
                [strongSelf didRemoveContentView];
            }];
        }
            break;
        case XLPhotoDisMissAnimationUpFly:
        {
            //cell frame 隐藏图片
            UIImageView *tempImageView = [[UIImageView alloc] initWithImage:view.imageview.image];
            CGRect rect = view.imageview.frame;
            rect.origin.y -= view.scrollView.contentOffset.y;
            tempImageView.frame = rect;
            tempImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.view addSubview:tempImageView];
            rect.origin.y = -rect.size.height;
            XLWEAKSELF
            [UIView animateWithDuration:XLPhotoBrowserHideImageAnimationDuration animations:^{
                tempImageView.clipsToBounds = YES;
                tempImageView.frame = rect;
                _picWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
            } completion:^(BOOL finished) {
                tempImageView.hidden = YES;
                [tempImageView removeFromSuperview];
                XLSTRONGSELF
                [strongSelf didRemoveContentView];
            }];

        }
            break;
        default:
            break;
    }
    [_scrollView removeFromSuperview];
    _scrollView = nil;

}

- (void)changeScrollViewSubFrame:(XLPhotoBrowserView *)currentView
{
    XLWEAKSELF
    [UIView animateWithDuration:0.3 animations:^{
        switch (self.deviceOrientation) {
            case UIDeviceOrientationLandscapeLeft:
            {
                self.view.transform = CGAffineTransformMakeRotation(M_PI*0.5);//翻转角度
                //先计算横屏下图片的长宽
                [currentView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(SCREEN_HEIGHT);
                    make.height.mas_equalTo(SCREEN_WIDTH);
                }];
                [_scrollView layoutIfNeeded];
            }
                break;
            case UIDeviceOrientationLandscapeRight:
            {
                self.view.transform = CGAffineTransformMakeRotation(-M_PI*0.5);//翻转角度
                //先计算横屏下图片的长宽
                [currentView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(SCREEN_HEIGHT);
                    make.height.mas_equalTo(SCREEN_WIDTH);
                }];
                [_scrollView layoutIfNeeded];
            }
                break;
            case UIDeviceOrientationPortrait:
            {
                self.view.transform = CGAffineTransformMakeRotation(M_PI*0);//翻转角度
                //先计算横屏下图片的长宽
                [currentView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(SCREEN_WIDTH);
                    make.height.mas_equalTo(SCREEN_HEIGHT);
                }];
                [_scrollView layoutIfNeeded];
            }
                break;
            default:
                break;
        }
    } completion:^(BOOL finished) {
        XLSTRONGSELF
        if (self.deviceOrientation == UIDeviceOrientationLandscapeLeft || self.deviceOrientation == UIDeviceOrientationLandscapeRight) {
            self.view.bounds = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
            
            CGFloat scrollWidth = XLPhotoBrowserImageViewMargin * 2+SCREEN_HEIGHT;
            for (XLPhotoBrowserView *view in _scrollView.subviews) {
                if (![view isKindOfClass:[XLPhotoBrowserView class]]) {
                    continue;
                }
                CGFloat x = view.viewTag * scrollWidth;
                [view mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(_scrollView).offset(x);
                    make.width.mas_equalTo(SCREEN_HEIGHT);
                    make.height.mas_equalTo(SCREEN_WIDTH);
                }];
            }
            [_scrollView layoutIfNeeded];
            _scrollView.contentSize = CGSizeMake(self.imageCount * scrollWidth, 0);
            _scrollView.contentOffset = CGPointMake(self.currentImageIndex * scrollWidth, 0);
        }
        else{
            self.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            
            CGFloat scrollWidth = XLPhotoBrowserImageViewMargin * 2+SCREEN_WIDTH;
            for (XLPhotoBrowserView *view in _scrollView.subviews) {
                if (![view isKindOfClass:[XLPhotoBrowserView class]]) {
                    continue;
                }
                CGFloat x = view.viewTag * scrollWidth;
                [view mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(_scrollView).offset(x);
                    make.width.mas_equalTo(SCREEN_WIDTH);
                    make.height.mas_equalTo(SCREEN_HEIGHT);
                }];
            }
            [_scrollView layoutIfNeeded];
            _scrollView.contentSize = CGSizeMake(self.imageCount * scrollWidth, 0);
            _scrollView.contentOffset = CGPointMake(self.currentImageIndex * scrollWidth, 0);
        }
        
        currentView.delegate = strongSelf;
        _pageControl.hidden = NO;
        _indexLabel.hidden = NO;
        _deleteButton.hidden = NO;
        _previewButton.hidden = NO;
        [strongSelf showCurrentPanPhotoBrowserViewHidden:NO currentPhotoView:currentView];
        _isInChangeOrientation = NO;
    }];
}

- (void)showCurrentPanPhotoBrowserViewHidden:(BOOL)hidden currentPhotoView:(UIView *)subScrollView
{
    for (UIView *subView in _scrollView.subviews)
    {
        if ([subView isKindOfClass:[XLPhotoBrowserView class]])
        {
            if ([subView isEqual:subScrollView])
            {
                continue;
            }
            subView.hidden = hidden;
        }
    }
}

#pragma mark - publicMethod
- (void)showWithOrignPicRect:(CGRect)rect editType:(XLPhotoBrowserControllerEditType)type
{
    [self addContentSubViewsWithEditType:type];
    [self starAnimationWithSmallPicRect:rect];
}

- (void)removePhotoBrower
{
    [self hidePhotoBrowser:nil animationType:XLPhotoDisMissAnimationNone];
}

/** 定位到指定位置页面 **/
- (void)reloadCurrentViewWithIndex:(int)index
{
    CGFloat scrollWidth = XLPhotoBrowserImageViewMargin * 2+SCREEN_WIDTH;
    _scrollView.contentSize = CGSizeMake(self.imageCount * scrollWidth, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * scrollWidth, 0);
    [self reloadPageNum];
    [self scrollViewDidScroll:_scrollView];
}

#pragma mark - NSNotification
-(void)onDeviceOrientationChange
{
    if (!self.shouldLandscape) {
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationUnknown ||
        orientation == UIDeviceOrientationFaceUp ||
        orientation == UIDeviceOrientationFaceDown ||
        orientation == UIDeviceOrientationPortraitUpsideDown) {
        //设备以上朝向 忽略 不改变
        return ;
    }
    if (self.deviceOrientation == orientation) {
        //方向没有改变过 不需要重新布局!!
        return;
    }
    
    self.isInChangeOrientation = YES;
    self.deviceOrientation = orientation;
    
    XLPhotoBrowserView *currentView = _scrollView.subviews[self.currentImageIndex];
    //转屏先重置当前view的参数
    [currentView.scrollView setZoomScale:1.0 animated:YES];
    currentView.delegate = nil;
    _pageControl.hidden = YES;
    _indexLabel.hidden = YES;
    _deleteButton.hidden = YES;
    _previewButton.hidden = YES;
    
    //隐藏其他view(防止抢镜头)
    [self showCurrentPanPhotoBrowserViewHidden:YES currentPhotoView:currentView];
    [self changeScrollViewSubFrame:currentView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    if (self.currentTypeModel == XLPageTypeModePageNum) {
        _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    }
    else if (self.currentTypeModel == XLPageTypeModePageController)
    {
        _pageControl.currentPage = index;
    }
    
    long left = index - 1;
    long right = index + 1;
    left = MAX(0, left);
    right = MIN(self.imageCount-1, right);
    NSMutableArray *indexList = [[NSMutableArray alloc] init];
    for (long i = left; i <= right; i++) {
        [self setupImageOfImageViewForIndex:i];
        [indexList addObject:@(i)];
    }
    /** 校验释放没有被使用的View **/
    [self checkLoadPhotoBrowserView:indexList];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int autualIndex = scrollView.contentOffset.x  / _scrollView.bounds.size.width;
    self.currentImageIndex = autualIndex;
    for (XLPhotoBrowserView *view in _scrollView.subviews) {
        if (view.viewTag != autualIndex) {
            view.scrollView.zoomScale = 1.0;
        }
    }
}


#pragma mark - XLPhotoBrowserViewDelegate
- (void)handleSingleTap:(XLPhotoBrowserView *)photoBrowserView
{
    [photoBrowserView.scrollView setZoomScale:1.0 animated:YES];
    
    if (self.shouldLandscape && self.deviceOrientation != UIDeviceOrientationPortrait)
    {
        [self hidePhotoBrowser:photoBrowserView animationType:XLPhotoDisMissAnimationFades];
    }
    else{
        [self hidePhotoBrowser:photoBrowserView animationType:XLPhotoDisMissAnimationToOrign];
    }
}

- (void)handleDoubleTap:(XLPhotoBrowserView *)photoBrowserView
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:doubleTap:)]) {
        [self.delegate photoBrowser:self doubleTap:self.currentImageIndex];
    }
}

-(void)handleLongTap:(XLPhotoBrowserView *)photoBrowserView
{
    XLLog(@"图片长按!");
    if ([self.delegate respondsToSelector:@selector(photoBrowser:longTap:)]) {
        [self.delegate photoBrowser:self longTap:self.currentImageIndex];
    }
}

- (void)handleDownPanGestureBegin:(XLPhotoBrowserView *)photoBrowserView
{
    [self showCurrentPanPhotoBrowserViewHidden:YES currentPhotoView:photoBrowserView];
}

- (void)handleDownPanGestureEnd:(XLPhotoBrowserView *)photoBrowserView isDissmiss:(BOOL)isDissmiss
{
    [self showCurrentPanPhotoBrowserViewHidden:NO currentPhotoView:photoBrowserView];
    if (isDissmiss) {
        //返回消失
        [self handleSingleTap:nil];
    }
}

- (void)handleDownPanGestureMove:(CGFloat)comProgress
{
    _picWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:(1-comProgress)];
}

- (void)handleUpPanGestureEnd:(XLPhotoBrowserView *)photoBrowserView
{
    [self hidePhotoBrowser:photoBrowserView animationType:XLPhotoDisMissAnimationUpFly];
}

#pragma mark - buttonEvent
- (void)deleteButtonClicked:(id)sender
{
    if (self.isInChangeOrientation) {
        //转屏过程中 不执行事件
        return;
    }
    for (NSNumber *index in self.cacheViewDic.allKeys) {
        if (index.integerValue  >= self.currentImageIndex) {
            XLPhotoBrowserView *view = [self.cacheViewDic objectForKey:index];
            if (view == nil) {//不应该进入这里,如果进入了需要看一下原因
                XLLog(@"有BUG 了!!!!!!!!");
                continue;
            }
            [view removeNoNeedToLoadConentView];
            view.beginLoadingImage = NO;
            [self.cacheViewDic removeObjectForKey:index];
        }
    }
    XLLog(@"删除按钮点击!");
    if ([self.delegate respondsToSelector:@selector(photoBrowser:deleteItemForIndex:)]) {
        [self.delegate photoBrowser:self deleteItemForIndex:self.currentImageIndex];
    }
    
    if (self.imageCount == 0) {
        //没有数据了 直接隐藏
        [self removePhotoBrower];
    }
    else
    {
        //自动滚向下一页
        if (self.imageCount - 1 < self.currentImageIndex) {
            //删除的是最后一页 重新停在最后一页
            self.currentImageIndex = self.currentImageIndex - 1;
        }
        [self reloadCurrentViewWithIndex:self.currentImageIndex];
    }

}

- (void)previewButtonClicked:(id)sender
{
    if (self.isInChangeOrientation) {
        //转屏过程中 不执行事件
        return;
    }
    if ([self.delegate respondsToSelector:@selector(photoBrowser:previewItemForIndex:)]) {
        [self.delegate photoBrowser:self previewItemForIndex:self.currentImageIndex];
    }
//    self.picWindow.holderNav.navigationBarHidden = NO;
    XLLog(@"预览按钮点击!");
}


#pragma mark - setter/getter
- (XLWindow *)picWindow
{
    if (!_picWindow) {
        _picWindow = [[XLWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _picWindow.windowLevel = UIWindowLevelStatusBar+1;
        _picWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        _picWindow.hidden= NO;
        XLNavigationController *holderNav = [[XLNavigationController alloc] initWithRootViewController:self];
        holderNav.navigationBarHidden = true;
        _picWindow.rootViewController = holderNav;
    }
    return _picWindow;
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgView.backgroundColor = XLPhotoBrowserBackgrounColor;
    }
    return _bgView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.hidden = YES;
        _scrollView.layer.masksToBounds = NO;
    }
    return _scrollView;
}

- (UILabel *)indexLabel
{
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        _indexLabel.bounds = CGRectMake(0, 0, 80, 30);
        _indexLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, 30);
        _indexLabel.layer.cornerRadius = 15;
        _indexLabel.clipsToBounds = YES;
        _indexLabel.hidden = YES;
    }
    return _indexLabel;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.hidden = YES;
    }
    return _pageControl;
}

- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [UIButton new];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [[_deleteButton titleLabel] setFont:[UIFont systemFontOfSize:15]];
        [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _deleteButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _deleteButton.layer.cornerRadius = 25.0f;
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hidden = YES;
    }
    return _deleteButton;
}

- (UIButton *)previewButton
{
    if (!_previewButton) {
        _previewButton = [UIButton new];
        [_previewButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        _previewButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [_previewButton addTarget:self action:@selector(previewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewButton;
}
@end
