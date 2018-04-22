//
//  PlayerManager.m
//  zlPlayer
//
//  Created by Tang杰 on 2018/4/21.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import "PlayerManager.h"

@interface PlayerManager()<PLPlayerDelegate>
@property (nonatomic, strong) PLPlayer *player;
@end

@implementation PlayerManager

+ (PlayerManager *)defaultManager
{
    static PlayerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
    });
    return manager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [PlayerManager defaultManager];
}
-(id)copyWithZone:(NSZone *)zone
{
    return [PlayerManager defaultManager];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    return [PlayerManager defaultManager];
}

#pragma mark - <PLPlayerDelegate>

- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    
    if ([self.delegate respondsToSelector:@selector(playerStatusDidChange:)]) {
        [self.delegate playerStatusDidChange:(PlayerStatus)state];
    }
}
#pragma mark - public
- (BOOL)playWithURL:(NSURL *)URL
{
    return [self.player playWithURL:URL sameSource:NO];
}
- (BOOL)play
{
    return [self.player play];
}
- (void)pause
{
    [self.player pause];
}
- (void)resume
{
    [self.player resume];
}
- (void)stop
{
    [self.player stop];
}
- (void)seekTo:(CMTime)time
{
    [self.player seekTo:time];
}
- (void)setVolume:(float)volume
{
    [self.player setVolume:volume];
}
- (float)getVolume
{
    return self.player.getVolume;
}
#pragma mark - private


#pragma mark - getter/setter
- (CMTime)currentTime
{
    return self.player.currentTime;
}
- (CMTime)totalDuration
{
    return self.player.totalDuration;
}

- (UIView *)playerView
{
    return self.player.playerView;
}

- (PLPlayer *)player
{
    if (!_player) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        PLPlayerOption *option = [PLPlayerOption defaultOption];
        [option setOptionValue:@10 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
        
        _player = [PLPlayer playerWithURL:nil option:option];
        _player.delegate = self;
        _player.delegateQueue = dispatch_get_main_queue();
        _player.backgroundPlayEnable = YES;        
    }
    return _player;
}
@end
