//
//  XLPhotoCollectionViewCell.m
//  XLPhotoBrower
//
//  Created by wujian on 2017/12/20.
//  Copyright © 2017年 xiaolian.Inc. All rights reserved.
//

#import "XLPhotoCollectionViewCell.h"
#import "XLPhotoBrowerHeader.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"

@interface XLPhotoCollectionViewCell ()

@property(nonatomic, strong)    UIImageView *imageView;
@property(nonatomic, strong)    UILabel *gifLable;

@property(nonatomic, strong)    XLPhotoModel *photoModel;
@end

@implementation XLPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self addSubview:self.gifLable];
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.bottom.mas_equalTo(0);
        }];

        [_gifLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.bottom.mas_equalTo(0);
        }];

    }
    return self;
}
#pragma mark - publicMethod
- (void)loadCellData:(XLPhotoModel *)photoModel
{    _photoModel = photoModel;
    if ([photoModel.bigImageURL rangeOfString:@".gif"].location != NSNotFound) {
        self.gifLable.hidden = NO;
    } else {
        self.gifLable.hidden = YES;
    }
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:photoModel.smallImageURL] placeholderImage:XLDefaultImage];
}

#pragma mark - setter/getter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)gifLable {
    if (_gifLable == nil) {
        _gifLable = [[UILabel alloc] init];
        _gifLable.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _gifLable.text = @"GIF";
        _gifLable.textColor = [UIColor whiteColor];
        _gifLable.font = [UIFont systemFontOfSize:14.0];
    }
    return _gifLable;
}

@end
