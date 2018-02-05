//
//  XLPhotoModel.h
//  XLPhotoBrower
//
//  Created by wujian on 2017/12/20.
//  Copyright © 2017年 xiaolian.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLPhotoModel : NSObject
/** 缩略图的图片url **/
@property (nonatomic, copy) NSString *smallImageURL;

/** 大图的图片url **/
@property (nonatomic, copy) NSString *bigImageURL;

-(instancetype)initWithsmallImageURL:(NSString *)smallImageURL bigImageURL:(NSString *)bigImageURL;
@end
