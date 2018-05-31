//
//  AliyunVodPlayerView+category.m
//  zlPlayer
//
//  Created by Tang杰 on 2018/5/31.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import "AliyunVodPlayerView+category.h"
#import "NSObject+exchangeMethod.h"

@implementation AliyunVodPlayerView (category)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeInstanceMethod:@[NSStringFromSelector(@selector(vodPlayer:playBackErrorModel:))] prefix:nil];
    });
}

- (void)new_vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(AliyunPlayerVideoErrorModel *)errorModel
{
    [self new_vodPlayer:vodPlayer playBackErrorModel:errorModel];
    if ([self.delegate respondsToSelector:@selector(vodPlayer:playBackErrorModel:)]) {
        [self.delegate performSelector:@selector(vodPlayer:playBackErrorModel:) withObject:vodPlayer withObject:errorModel];
    }
}
@end
