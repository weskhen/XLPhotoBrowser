//
//  XLPhotoCollectionViewCell.h
//  XLPhotoBrower
//
//  Created by wujian on 2017/12/20.
//  Copyright © 2017年 xiaolian.Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XLPhotoModel;

@interface XLPhotoCollectionViewCell : UICollectionViewCell
@property(nonatomic,assign) NSUInteger index;

- (void)loadCellData:(XLPhotoModel *)photoModel;

@end
