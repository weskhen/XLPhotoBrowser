//
//  XLPhotoBrowserView.m
//  XLPhotoBrower
//
//  Created by wujian on 2017/12/20.
//  Copyright © 2017年 xiaolian.Inc. All rights reserved.
//

#import "XLPhotoBrowserView.h"
#import "XLWaitingView.h"
#import "UIImageView+WebCache.h"
#import "XLPhotoBrowserConfig.h"
#import "Masonry.h"


@interface XLPhotoBrowserView() <UIScrollViewDelegate>
@property (nonatomic, strong) XLWaitingView *waitingView;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UILongPressGestureRecognizer *longTap;

@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, strong) UIButton *reloadButton;

@property (nonatomic, assign) CGFloat lastContentOffsetY;//上次停留的位置 用来标记scrollView的滚动方向

@property (nonatomic, assign) BOOL doingDownPan;//正在👇拖拽
@property (nonatomic, assign) BOOL panDirectionDown;//拖拽是不是正在向下，如果是，退回页面，否则，弹回

@property (nonatomic, assign) CGFloat panBeginX;//向下拖拽手势开始时的X，在拖拽开始时赋值，拖拽结束且没有退回页面时置0
@property (nonatomic, assign) CGFloat panBeginY;//向下拖拽手势开始时的Y，在拖拽开始时赋值，拖拽结束且没有退回页面时置0
@property (nonatomic, assign) CGPoint imageOrignCenter;//向下拖拽开始时，图片的中心
@property (nonatomic, assign) CGSize imageOrignSize;

@property (nonatomic, assign) BOOL doingUpPan;//正在👆拖拽
@property (nonatomic, assign) BOOL hasLoadedImage;//图片是否加载完成
@end

@implementation XLPhotoBrowserView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (void)dealloc
{
    [self removeNoNeedToLoadConentView];
}

#pragma mark - publicMethod
- (void)starLoadingContentView
{
    [self addSubview:self.scrollView];
    [self addGestureRecognizer:self.doubleTap];
    [self addGestureRecognizer:self.singleTap];
    [self addGestureRecognizer:self.longTap];

    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
}

- (void)removeNoNeedToLoadConentView
{
    if (_singleTap) {
        [self removeGestureRecognizer:_singleTap];
        _singleTap = nil;
    }
    if (_doubleTap) {
        [self removeGestureRecognizer:_doubleTap];
        _doubleTap = nil;
    }
    if (_longTap) {
        [self removeGestureRecognizer:_longTap];
        _longTap = nil;
    }
    
    if (_imageview) {
        [_imageview removeFromSuperview];
        _imageview = nil;
    }
    if (_reloadButton) {
        [_reloadButton removeFromSuperview];
        _reloadButton = nil;
    }
    if (_scrollView) {
        _scrollView.delegate = nil;
        [_scrollView removeFromSuperview];
        _scrollView = nil;
    }
    _panBeginX = 0;
    _panBeginY = 0;
    _lastContentOffsetY = 0;
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    if (_reloadButton) {
        [_reloadButton removeFromSuperview];
        _reloadButton = nil;
    }
    _imageUrl = url;
    _placeHolderImage = placeholder;
    [self addSubview:self.waitingView];
    [_waitingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    XLWEAKSELF
    [_imageview sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        XLSTRONGSELF
        strongSelf.waitingView.progress = (CGFloat)receivedSize / expectedSize;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        XLSTRONGSELF
        [_waitingView removeFromSuperview];
        if (error) {
            [strongSelf addSubview:strongSelf.reloadButton];
        }
        else{
            strongSelf.hasLoadedImage = YES;
            //图片下载成功后需要重新调正实际大小
            [strongSelf adjustFrame];
        }
    }];
}

- (void)stopUpPan
{
    self.doingUpPan = NO;
    if (self.lastContentOffsetY > XLPhotoUpPanMaxLimit && self.panDirectionDown == NO) {
        //像上滑 飞走
        if ([self.delegate respondsToSelector:@selector(handleUpPanGestureEnd:)]) {
            [self.delegate handleUpPanGestureEnd:self];
        }
        
        if (self.upPanEndBlock) {
            self.upPanEndBlock(self);
        }
    }
}
- (void)stopDownPan
{
    if (self.panDirectionDown) {
        //消失
        self.doingDownPan = NO;
        if ([self.delegate respondsToSelector:@selector(handleDownPanGestureEnd:isDissmiss:)]) {
            [self.delegate handleDownPanGestureEnd:self isDissmiss:YES];
        }

        if (self.panEndBlock) {
            self.panEndBlock(self,YES);
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(handleDownPanGestureEnd:isDissmiss:)]) {
            [self.delegate handleDownPanGestureEnd:self isDissmiss:NO];
        }

        if (self.panEndBlock) {
            self.panEndBlock(self,NO);
        }
        
        //复原
        [UIView animateWithDuration:XLPanResetAnimationDuration animations:^{
            CGRect frame = self.imageview.frame;
            frame.size = self.imageOrignSize;
            self.imageview.frame = frame;
            self.imageview.center = [self centerOfScrollViewContent:self.scrollView];
            
            if ([self.delegate respondsToSelector:@selector(handleDownPanGestureMove:)]) {
                [self.delegate handleDownPanGestureMove:0.0];
            }
            if (self.panMoveBlock) {
                self.panMoveBlock(0.0);
            }
        } completion:^(BOOL finished) {
            self.doingDownPan = NO;
            self.panBeginX = 0.0;
            self.panBeginY = 0.0;
        }];
    }

}

#pragma mark - singleTap
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(handleSingleTap:)]) {
        [self.delegate handleSingleTap:self];
    }
    if (self.singleTapBlock) {
        self.singleTapBlock(self);
    }
}

#pragma mark - doubleTap
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    //图片没有加载完成或正在拖动 不执行双击
    if (!self.hasLoadedImage || self.doingDownPan || self.doingUpPan) {
        return;
    }
    CGPoint touchPoint = [recognizer locationInView:self];
    if (self.scrollView.zoomScale <= 1.0) {
        CGFloat scaleX = touchPoint.x + self.scrollView.contentOffset.x;
        CGFloat sacleY = touchPoint.y + self.scrollView.contentOffset.y;
        [self.scrollView zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
    if ([self.delegate respondsToSelector:@selector(handleDoubleTap:)]) {
        [self.delegate handleDoubleTap:self];
    }
    if (self.doubleTapBlock) {
        self.doubleTapBlock(self);
    }
}

#pragma mark - longTap
-(void)handleLongTap:(UILongPressGestureRecognizer *)recognizer {
    //图片没有加载完成或正在拖动或图片在缩放过程中 不执行长按
    if (!self.hasLoadedImage || self.doingDownPan || self.scrollView.zoomScale != 1.0f || self.doingUpPan) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(handleLongTap:)]) {
        [self.delegate handleLongTap:self];
    }
    if (self.longTabBlock) {
        self.longTabBlock(self);
    }
}

#pragma mark - panGesture
- (void)panImageView:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = recognizer.state;
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStatePossible)
    {
        //拖动结束
        self.panBeginX = 0.0;
        self.panBeginY = 0.0;
        self.doingDownPan = NO;
        self.doingUpPan = NO;
        return;
    }

    CGPoint translation = [recognizer locationInView:self];
    if (self.panBeginX == 0.0 && self.panBeginY == 0.0)
    {
        //拖动第一次执行
        self.panBeginX = translation.x;//赋值初始X
        self.panBeginY = translation.y;//赋值初始Y
        self.imageOrignCenter = self.imageview.center;//记录图片拖动前的初始center
        self.imageOrignSize = self.imageview.frame.size;//记录图片拖动前的初始size
        self.doingDownPan = YES;
        
        if ([self.delegate respondsToSelector:@selector(handleDownPanGestureBegin:)]) {
            [self.delegate handleDownPanGestureBegin:self];
        }
        if (self.panBeginBlock) {
            self.panBeginBlock(self);
        }
    }
    else if (state == UIGestureRecognizerStateChanged) {
        
        self.doingDownPan = YES;
        CGFloat panCurrentX = translation.x;//当前触摸点的X
        CGFloat panCurrentY = translation.y;//当前触摸点的Y
        //拖拽进度
        CGFloat comProgress = (panCurrentY - self.panBeginY) / XLPhotoPanMaxLimit;
        comProgress = comProgress > 1.0 ? 1.0 : comProgress;
        
        /** 重置frame **/
        CGRect frame = self.imageview.frame;
        if (panCurrentY > self.panBeginY) {
            //在初始拖动的位置下方 图片按比例缩小
            frame.size = CGSizeMake(self.imageOrignSize.width*(1-XLPhotoMinZoom*comProgress), self.imageOrignSize.height*(1-XLPhotoMinZoom*comProgress));
        }
        else
        {
            //在初始拖动的位置上方 图片大小保持原先的尺寸
            frame.size = self.imageOrignSize;
        }
        self.imageview.frame = frame;

        /** 重置Center **/
        [self.imageview setCenter:CGPointMake(panCurrentX-self.panBeginX+self.imageOrignCenter.x, panCurrentY-self.panBeginY+self.imageOrignCenter.y)];
        
//        XLLog(@"self.imageview::Frame:%@",NSStringFromCGRect(self.imageview.frame));
        
        if ([self.delegate respondsToSelector:@selector(handleDownPanGestureMove:)]) {
            [self.delegate handleDownPanGestureMove:comProgress];
        }
        if (self.panMoveBlock) {
            self.panMoveBlock(comProgress);
        }
    }
}

#pragma mark - buttonEvent
- (void)reloadButtonClicked
{
    [self setImageWithURL:_imageUrl placeholderImage:_placeHolderImage];
}

#pragma mark - privateMethod
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    _waitingView.progress = progress;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    if (self.doingDownPan || self.doingUpPan) {
        return;
    }
    [self adjustFrame];
}

- (void)adjustFrame
{
    CGRect frame = self.scrollView.frame;
    if (self.imageview.image) {
        CGSize imageSize = self.imageview.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        if (XLFullWidthForLandScape) {
            CGFloat ratio = frame.size.width/imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height*ratio;
            imageFrame.size.width = frame.size.width;
        } else{
            if (frame.size.width<=frame.size.height) {
                CGFloat ratio = frame.size.width/imageFrame.size.width;
                imageFrame.size.height = imageFrame.size.height*ratio;
                imageFrame.size.width = frame.size.width;
            }else{
                CGFloat ratio = frame.size.height/imageFrame.size.height;
                imageFrame.size.width = imageFrame.size.width*ratio;
                imageFrame.size.height = frame.size.height;
            }
        }
        
        self.imageview.frame = imageFrame;
        self.scrollView.contentSize = self.imageview.frame.size;
        self.imageview.center = [self centerOfScrollViewContent:self.scrollView];
        
        CGFloat maxScale = frame.size.height/imageFrame.size.height;
        maxScale = frame.size.width/imageFrame.size.width>maxScale?frame.size.width/imageFrame.size.width:maxScale;
        maxScale = maxScale>XLMaxZoomScale?maxScale:XLMaxZoomScale;
        self.scrollView.minimumZoomScale = XLMinZoomScale;
        self.scrollView.maximumZoomScale = maxScale;
        self.scrollView.zoomScale = 1.0f;
    }else{
        self.imageview.frame = CGRectMake((CGRectGetWidth(frame)-XLBigImageDefaultSize)/2.0, (CGRectGetHeight(frame)-XLBigImageDefaultSize)/2.0, XLBigImageDefaultSize, XLBigImageDefaultSize);
        self.scrollView.contentSize = self.imageview.frame.size;
    }
    self.scrollView.contentOffset = CGPointZero;
    
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageview;
}

/** 缩放完成的回调 */
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageview.center = [self centerOfScrollViewContent:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.lastContentOffsetY = scrollView.contentOffset.y+scrollView.contentInset.top;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y+scrollView.contentInset.top;
    CGFloat comparisonOffsetY = self.lastContentOffsetY;
    self.lastContentOffsetY = offsetY;
    //计算滑动方向
    if (offsetY > comparisonOffsetY) {
        //上滑
        self.panDirectionDown = NO;
        XLLog(@"正在往上滑");
    }else if (offsetY < comparisonOffsetY){
        //下滑
        self.panDirectionDown = YES;
        XLLog(@"正在往下滑");
    }

    if (self.scrollView.zoomScale != 1.0f || !self.hasLoadedImage || scrollView.panGestureRecognizer.numberOfTouches != 1) {
        //双击或处于缩放状态下或图片没有加载完成或多个手指在动 不产生拖动效果.
        return;
    }

    if (self.scrollView.bounds.size.height < self.imageview.bounds.size.height) {
        //长图的情况
        if (offsetY < 0) {
            //触发向下拖动效果
            XLLog(@"正在往下滑 触发拖动效果!");
            [self panImageView:self.scrollView.panGestureRecognizer];
        }
        else if (offsetY > (self.imageview.bounds.size.height - self.scrollView.bounds.size.height))
        {
            //上滑 飞走
            if (self.panDirectionDown == NO) {
                self.doingUpPan = YES;
            }
        }
        else{
            //正常滑动
        }
    }
    else{
        if (((offsetY < comparisonOffsetY) || self.doingDownPan) && self.doingUpPan == NO)
        {
            XLLog(@"正在往下滑 触发拖动效果!");
            //向下拖动或正在拖动中
            [self panImageView:self.scrollView.panGestureRecognizer];
        }
        else
        {
            //上滑 飞走
            if (self.panDirectionDown == NO) {
                self.doingUpPan = YES;
            }
        }
    }
}

//结束拖拽
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.doingDownPan) {
        //若是正在拖动 结束
        [self stopDownPan];
    }
    
    if (self.doingUpPan) {
        [self stopUpPan];
    }
}

#pragma mark - setter/getter
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView addSubview:self.imageview];
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.directionalLockEnabled = YES;
//        _scrollView.alwaysBounceHorizontal = YES;//这是为了左右滑时能够及时回调scrollViewDidScroll代理
    }
    return _scrollView;
}

- (UIImageView *)imageview
{
    if (!_imageview) {
        _imageview = [[UIImageView alloc] init];
        _imageview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _imageview.userInteractionEnabled = YES;
        _imageview.contentMode = UIViewContentModeScaleAspectFill;
        _imageview.layer.masksToBounds = YES;
    }
    return _imageview;
}

- (UITapGestureRecognizer *)doubleTap
{
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired  =1;
    }
    return _doubleTap;
}

- (UITapGestureRecognizer *)singleTap
{
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
        _singleTap.delaysTouchesBegan = YES;
    }
    return _singleTap;
}

- (UILongPressGestureRecognizer *)longTap {
    if (!_longTap) {
        _longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
    }
    return _longTap;
}

- (UIButton *)reloadButton
{
    if (!_reloadButton) {
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadButton.layer.cornerRadius = 2;
        _reloadButton.clipsToBounds = YES;
        _reloadButton.bounds = CGRectMake(0, 0, 200, 60);
        _reloadButton.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5);
        _reloadButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _reloadButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [_reloadButton setTitle:@"加载失败，点击重新加载" forState:UIControlStateNormal];
        [_reloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reloadButton addTarget:self action:@selector(reloadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadButton;
}

- (XLWaitingView *)waitingView
{
    if (!_waitingView) {
        _waitingView = [[XLWaitingView alloc] init];
    }
    return _waitingView;
}
@end
