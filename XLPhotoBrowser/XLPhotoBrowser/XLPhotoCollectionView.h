//
//  XLPhotoCollectionView.h
//  XLPhotoBrower
//
//  Created by wujian on 2017/12/20.
//  Copyright © 2017年 xiaolian.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XLPhotoModel;
@interface XLPhotoCollectionView : UICollectionView

/** 图片之间的间距 默认 4**/
@property (nonatomic, assign)   CGFloat groupImageMargin;

/** 图片上限数量  默认9 **/
@property (nonatomic, assign)   int photoMaxCount;

/** 加载的默认图 **/
@property (nonatomic, strong)   UIImage *defaultCellImage;

/** 是否打开图片预览模式 默认false **/
@property (nonatomic, assign)   BOOL openPreview;


/** frame 高度会被重新计算 **/
-(instancetype)initWithFrame:(CGRect)frame;

/** itemSize 固定collectionViewCell尺寸 不会改变collectionView的宽度 **/
- (void)loadCollectionWithPhotoModelArray:(NSArray<XLPhotoModel *> *)photoModelArray cellItemSize:(CGSize)itemSize;

/** width 固定collectionView宽度 **/
- (void)loadCollectionWithPhotoModelArray:(NSArray<XLPhotoModel *> *)photoModelArray viewWidth:(CGFloat)width;

//- (void)setCurrentViewEdgeInsets:(CGFloat)edgeInsets;
@end
