//
//  PlayerManager.h
//  zlPlayer
//
//  Created by Tang杰 on 2018/4/21.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLPlayerKit.h"

typedef NS_ENUM(NSUInteger, PlayerStatus) {
    /**
     PLPlayer 正在准备播放所需组件，在调用 -play 方法时出现。
     */
    PlayerStatusPreparing = PLPlayerStatusPreparing,
    
    /**
     PLPlayer 播放组件准备完成，准备开始播放，在调用 -play 方法时出现。
     */
    PlayerStatusReady = PLPlayerStatusReady,
    /**
     @abstract PLPlayer 缓存数据为空状态。
     
     @discussion 特别需要注意的是当推流端停止推流之后，PLPlayer 将出现 caching 状态直到 timeout 后抛出 timeout 的 error 而不是出现 PlayerStatusStopped 状态，因此在直播场景中，当流停止之后一般做法是使用 IM 服务告知播放器停止播放，以达到即时响应主播断流的目的。
     */
    PlayerStatusCaching = PLPlayerStatusCaching,
    
    /**
     PLPlayer 正在播放状态。
     */
    PlayerStatusPlaying = PLPlayerStatusPlaying,
    
    /**
     PLPlayer 暂停状态。
     */
    PlayerStatusPaused = PLPlayerStatusPaused,
    
    /**
     @abstract PLPlayer 停止状态
     @discussion 该状态仅会在回放时播放结束出现，RTMP 直播结束并不会出现此状态
     */
    PlayerStatusStopped = PLPlayerStatusStopped,
    
    /**
     PLPlayer 错误状态，播放出现错误时会出现此状态。
     */
    PlayerStatusError = PLPlayerStatusError,
    /**
     *  PLPlayer 播放完成（该状态只针对点播有效）
     */
    PlayerStatusCompleted = PLPlayerStatusCompleted,
    
    /**
     @abstract PLPlayer seek 状态中。
     
     @discussion 该状态会在调用 seekTo 后触发，seekTo 操作完成后会转至 PlayerStatusPlaying 状态。
     */
    PlayerStatusSeeking = PLPlayerStatusSeeking,
    
    /**
     @abstract PLPlayer seek 完成状态。
     
     @discussion 该状态会在调用 seekTo 失败后触发。
     */
    PlayerStatusSeekFailed = PLPlayerStatusSeekFailed,
};

@protocol PlayerManagerDelegate <NSObject>
- (void) playerStatusDidChange:(PlayerStatus)state;
@end

@interface PlayerManager : NSObject

+ (PlayerManager *)defaultManager;

@property (nonatomic, weak) id<PlayerManagerDelegate> delegate;

/**
 PLPlayer 的画面输出到该 UIView 对象
 */
@property (nonatomic, strong, readonly) UIView *playerView;

/**
 开始播放新的 url
 
 @param URL 需要播放的 url ，目前支持 http(s) (url 以 http:// https:// 开头) 与 rtmp (url 以 rtmp:// 开头) 协议。
 
 @return 是否成功播放
*/
- (BOOL)playWithURL:(NSURL *)URL;
/**
 开始播放
 @return 是否成功播放
  */
- (BOOL)play;

/**
 当播放器处于暂停状态时调用该方法可以使播放器继续播放
  */
- (void)resume;

/**
 当播放器处于 playing 或 caching 状态时调用该方法可以暂停播放器
  */
- (void)pause;

/**
 停止播放器
 
 @since v1.0.0
 */
- (void)stop;

/**
 快速定位到指定播放时间点，该方法仅在回放时起作用，直播场景下该方法直接返回
 
 @param time 需要
  */
- (void)seekTo:(CMTime)time;

/**
 *  设置音量，范围是0-3.0，默认是1.0
 *
 *  @param volume 音量
 */
- (void)setVolume:(float)volume;

/**
 *  获取音量
 *
 *  @return 音量
 */
- (float)getVolume;
/**
 PLPlayer 的当前播放时间，仅回放状态下有效，只播放状态下将返回 CMTime(0,30)
 */
@property (nonatomic, assign, readonly) CMTime  currentTime;

/**
 PLPlayer 的总播放时间，仅回放状态下有效，只播放状态下将返回 CMTime(0,30)
 */
@property (nonatomic, assign, readonly) CMTime  totalDuration;


@end
