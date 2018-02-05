//
//  XLWaitingVie.m
//  XLPhotoBrower
//
//  Created by wujian on 2017/12/20.
//  Copyright © 2017年 xiaolian.Inc. All rights reserved.
//

#import "XLWaitingView.h"
#import "XLPhotoBrowserConfig.h"

@implementation XLWaitingView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = XLWaitingViewBackgroundColor;
        self.clipsToBounds = YES;
        self.mode = XLWaitingViewModeLoopDiagram;//默认用空心的 之后会覆盖用户选择的样式
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (progress >= 1) {
        XLWEAKSELF
        dispatch_async(dispatch_get_main_queue(), ^{
            XLSTRONGSELF
            [strongSelf removeFromSuperview];
        });
    }
    else{
        [self setNeedsDisplay];
    }
}

- (void)setFrame:(CGRect)frame
{
    //设置背景图为圆
    frame.size.width = 50;
    frame.size.height = 50;
    self.layer.cornerRadius = 25;
    [super setFrame:frame];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    [[UIColor whiteColor] set];
    
    switch (self.mode) {
        case XLWaitingViewModePieDiagram:
            {
                CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - XLWaitingViewItemMargin;
                
                CGFloat w = radius * 2 + XLWaitingViewItemMargin;
                CGFloat h = w;
                CGFloat x = (rect.size.width - w) * 0.5;
                CGFloat y = (rect.size.height - h) * 0.5;
                CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
                CGContextFillPath(ctx);
                
                [XLWaitingViewBackgroundColor set];
                CGContextMoveToPoint(ctx, xCenter, yCenter);
                CGContextAddLineToPoint(ctx, xCenter, 0);
                CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001; // 初始值
                CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 1);
                CGContextClosePath(ctx);
                
                CGContextFillPath(ctx);
            }
            break;
            
        default:
            {
                CGContextSetLineWidth(ctx, 4);
                CGContextSetLineCap(ctx, kCGLineCapRound);
                CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05; // 初始值0.05
                CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - XLWaitingViewItemMargin;
                CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 0);
                CGContextStrokePath(ctx);
            }
            break;
    }
}

@end
