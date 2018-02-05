//
//  XLMutableDictionary.m
//  XLPhotoBrowser
//
//  Created by wujian on 2018/2/2.
//  Copyright © 2018年 wujian. All rights reserved.
//

#import "XLMutableDictionary.h"

@interface XLMutableDictionary ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@end

@implementation XLMutableDictionary

- (instancetype)init {
    if (self = [super init]) {
        _dictionary = [NSMutableDictionary new];
        _dispatchQueue = dispatch_queue_create("com.wesk.XLMutableDictionary", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (NSArray *)allKeys {
    __block NSArray *allKeys = nil;
    dispatch_sync(self.dispatchQueue, ^{
        allKeys = [self.dictionary allKeys];
    });
    return allKeys;
}

- (id)objectForKey:(id)aKey {
    __block id returnObject = nil;
    
    dispatch_sync(self.dispatchQueue, ^{
        returnObject = [self.dictionary objectForKey:aKey];
    });
    
    return returnObject;
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    dispatch_sync(self.dispatchQueue, ^{
        [self.dictionary setObject:anObject forKey:aKey];
    });
}

- (void)removeObjectForKey:(id)aKey {
    dispatch_sync(self.dispatchQueue, ^{
        [self.dictionary removeObjectForKey:aKey];
    });
}

@end
