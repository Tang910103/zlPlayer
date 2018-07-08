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
        [self exchangeInstanceMethod:@[NSStringFromSelector(@selector(vodPlayer:onEventCallback:))] prefix:nil];
    });
}

- (void)new_vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(AliyunPlayerVideoErrorModel *)errorModel
{
    [self new_vodPlayer:vodPlayer playBackErrorModel:errorModel];
    if ([self.delegate respondsToSelector:@selector(vodPlayer:playBackErrorModel:)]) {
        [self.delegate performSelector:@selector(vodPlayer:playBackErrorModel:) withObject:vodPlayer withObject:errorModel];
    }
}
/**
 * 功能：播放事件协议方法,主要内容 AliyunVodPlayerEventPrepareDone状态下，此时获取到播放视频数据（时长、当前播放数据、视频宽高等）
 * 参数：event 视频事件
 */
- (void)new_vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event
{
    [self new_vodPlayer:vodPlayer onEventCallback:event];
    if ([self.delegate respondsToSelector:@selector(vodPlayer:onEventCallback:)]) {
        [self.delegate performSelector:@selector(vodPlayer:onEventCallback:) withObject:vodPlayer withObject:@(event)];
    }
}
@end
