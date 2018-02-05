//
//  XLPhotoModel.m
//  XLPhotoBrower
//
//  Created by wujian on 2017/12/20.
//  Copyright © 2017年 xiaolian.Inc. All rights reserved.
//

#import "XLPhotoModel.h"

@implementation XLPhotoModel
-(instancetype)initWithsmallImageURL:(NSString *)smallImageURL bigImageURL:(NSString *)bigImageURL {
    if (self = [super init]) {
        self.smallImageURL = smallImageURL;
        self.bigImageURL = bigImageURL;
    }
    return self;
}
@end
