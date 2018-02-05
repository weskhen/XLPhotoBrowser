//
//  XLMutableDictionary.h
//  XLPhotoBrowser
//
//  Created by wujian on 2018/2/2.
//  Copyright © 2018年 wujian. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 线程安全的字典
 */
@interface XLMutableDictionary : NSObject

- (id)objectForKey:(id)aKey;
- (NSArray *)allKeys;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (void)removeObjectForKey:(id)aKey;

@end
