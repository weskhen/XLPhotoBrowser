//
//  XLPhotoCollectionView.m
//  XLPhotoBrower
//
//  Created by wujian on 2017/12/20.
//  Copyright © 2017年 xiaolian.Inc. All rights reserved.
//

#import "XLPhotoCollectionView.h"
#import "XLPhotoModel.h"
#import "XLPhotoBrowserConfig.h"
//展示
#import "XLPhotoCollectionViewCell.h"
#import "XLPhotoBrowserController.h"
//图片模型
//第三方
#import <SDWebImage/SDImageCache.h>

@interface XLPhotoCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, XLPhotoBrowserControllerDelegate>

@property (nonatomic, strong)   UICollectionViewFlowLayout *layout;
@property (nonatomic, strong)   XLPhotoBrowserController *photoBrowser;

@property (nonatomic, strong)   NSArray <XLPhotoModel *>*photoModelArray;
@property (nonatomic, assign)   CGSize cellItemSize;

@end

@implementation XLPhotoCollectionView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame collectionViewLayout:self.layout];
    if (self) {
        self.groupImageMargin = XLPhotoGroupImageMargin;
        self.photoMaxCount = XLPhotoMaxCount;
        self.defaultCellImage = XLDefaultImage;

        [self registerClass:[XLPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"XLPhotoCollectionViewCell"];
        [self registerClass:[XLPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"normalCell"];
        self.dataSource = self;
        self.delegate = self;
        self.backgroundColor = XLSmallPhotoBackgrounColor;
        self.scrollEnabled = NO;
    }
    return self;
}

#pragma mark - privateMethod

- (UICollectionViewCell *)getCollectionViewCellWithIndex:(NSUInteger)index
{
    UICollectionViewCell * cell;
    if (self.photoModelArray.count == 4 && index > 1) {
        cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index + 1 inSection:0]];
    } else {
        cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    }
    return cell;
}

- (void)reloadCollectionCell
{
    long imageCount = self.photoModelArray.count;
    
    imageCount = imageCount > self.photoMaxCount ? self.photoMaxCount : imageCount;
    int perRowImageCount = ((imageCount == 4) ? 2 : 3);
    int totalRowCount = ((int)(imageCount + perRowImageCount - 1) / perRowImageCount);
    
    if (totalRowCount > 1) {
        self.layout.minimumLineSpacing = XLPhotoGroupImageMargin;
        self.layout.minimumInteritemSpacing = XLPhotoGroupImageMargin;
    }
    else{
        self.layout.minimumLineSpacing = 0;
        self.layout.minimumInteritemSpacing = 0;
    }
    self.layout.itemSize = self.cellItemSize;
    
    //动态计算出控件的实际高度
    CGFloat height = 0;
    if (totalRowCount < 3) {
        height = XLPhotoEdgeInsets*2 + self.layout.itemSize.height;
    }
    else{
        height = XLPhotoEdgeInsets*2 + totalRowCount * (XLPhotoGroupImageMargin + self.layout.itemSize.height);
    }
    
    //更新控件的高度
    CGRect frame = self.frame;
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    [self reloadData];
    
}

#pragma mark - 布局 小图时展示图片控件的大小
-(void)reloadLayoutSizeWithWidth:(CGFloat)width
{
    long imageCount = self.photoModelArray.count;
    
    imageCount = imageCount > self.photoMaxCount ? self.photoMaxCount : imageCount;
    int perRowImageCount = ((imageCount == 4) ? 2 : 3);
    int totalRowCount = ((int)(imageCount + perRowImageCount - 1) / perRowImageCount);
    CGFloat contentWidth = width;
    int w;
    int h;
    if (imageCount == 0) {
        w = h = 0;
    } else if (imageCount == 1) {
        w = h = (contentWidth - XLPhotoGroupImageMargin * 2)/3.0;
    } else if (imageCount == 2) {
        w = h = (contentWidth - XLPhotoGroupImageMargin * 3)/2.0;
    } else {
        w = h = (contentWidth - XLPhotoGroupImageMargin * 4) /3;
    }
    
    if (totalRowCount > 1) {
        self.layout.minimumLineSpacing = XLPhotoGroupImageMargin;
        self.layout.minimumInteritemSpacing = XLPhotoGroupImageMargin;
    }
    else{
        self.layout.minimumLineSpacing = 0;
        self.layout.minimumInteritemSpacing = 0;
    }
    self.layout.itemSize = CGSizeMake(w, h);
    
    //动态计算出控件的实际高度
    CGFloat height = 0;
    if (totalRowCount < 3) {
        height = XLPhotoEdgeInsets*2 + self.layout.itemSize.height;
    }
    else{
        height = XLPhotoEdgeInsets*2 + totalRowCount * (XLPhotoGroupImageMargin + self.layout.itemSize.height);
    }
    //更新控件的高度
    CGRect frame = self.frame;
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, width, height);
    [self reloadData];
}

#pragma mark - publicMethod
- (void)loadCollectionWithPhotoModelArray:(NSArray<XLPhotoModel *> *)photoModelArray cellItemSize:(CGSize)itemSize
{
    self.photoModelArray = photoModelArray;
    self.cellItemSize = itemSize;
    [self reloadCollectionCell];
}

- (void)loadCollectionWithPhotoModelArray:(NSArray<XLPhotoModel *> *)photoModelArray viewWidth:(CGFloat)width
{
    self.photoModelArray = photoModelArray;
    [self reloadLayoutSizeWithWidth:width];
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.photoModelArray.count == 4) {
        return 5;
    } else {
        return self.photoModelArray.count > self.photoMaxCount ? self.photoMaxCount : self.photoModelArray.count;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XLPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XLPhotoCollectionViewCell" forIndexPath:indexPath];
    if (self.photoModelArray.count == 4 && indexPath.row == 2) {
        XLPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"normalCell" forIndexPath:indexPath];
        return cell;
    }
    XLPhotoModel *model = nil;
    if (self.photoModelArray.count == 4 && indexPath.row > 2) {
        //4宫格
        cell.index = indexPath.item - 1;
        model = self.photoModelArray[indexPath.item - 1];
    } else {
        //9宫格
        cell.index = indexPath.item;
        model = self.photoModelArray[indexPath.item];
    }
    [cell loadCellData:model];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.photoModelArray.count == 4 && indexPath.row == 2) {
        return;
    }
    [self buttonClick:indexPath];
}

- (void)buttonClick:(NSIndexPath *)indexPath {
    self.photoBrowser.imageCount = self.photoModelArray.count > self.photoMaxCount ? self.photoMaxCount : self.photoModelArray.count;
    if (self.photoModelArray.count == 4 && indexPath.row > 2) {
        self.photoBrowser.currentImageIndex = (int)indexPath.item - 1;
    } else  {
        self.photoBrowser.currentImageIndex = (int)indexPath.item;
    }
    
    UICollectionViewCell *cell = [self getCollectionViewCellWithIndex:indexPath.row];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [self convertRect:cell.frame toView:window];
    if (self.openPreview) {
        [self.photoBrowser showWithOrignPicRect:rect editType:XLPhotoBrowserControllerEditTypePreview];
    }
    else{
        [self.photoBrowser showWithOrignPicRect:rect editType:XLPhotoBrowserControllerEditTypeNone];
    }
}

#pragma mark - XLPhotoBrowserControllerDelegate
- (UIImage *)photoBrowser:(XLPhotoBrowserController *)browser placeholderImageForIndex:(NSInteger)index {
    NSString *smallImageURL = [self.photoModelArray[index] smallImageURL];
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:smallImageURL];
    if (cacheImage == nil) {
        return XLDefaultImage;
    } else {
        return cacheImage;
    }
}

- (void)didHidePhotoBrowser:(XLPhotoBrowserController *)photoBrowser index:(NSInteger)index
{
    _photoBrowser = nil;
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}

- (CGRect)smallPicRectForIndex:(NSInteger)index
{
    UICollectionViewCell *cell = [self getCollectionViewCellWithIndex:index];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [self convertRect:cell.frame toView:window];
    return rect;
}

- (NSURL *)photoBrowser:(XLPhotoBrowserController *)browser highQualityImageURLForIndex:(NSInteger)index {
    NSString *urlStr = [self.photoModelArray[index] bigImageURL];
    
    return [NSURL URLWithString:urlStr];
}

#pragma mark - setter/getter

-(UICollectionViewFlowLayout *)layout {
    if (_layout == nil) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _layout;
}

- (XLPhotoBrowserController *)photoBrowser
{
    if (!_photoBrowser) {
        _photoBrowser = [[XLPhotoBrowserController alloc] init];
        _photoBrowser.sourceImagesContainerView = self;
        _photoBrowser.delegate = self;
    }
    return _photoBrowser;
}

@end
