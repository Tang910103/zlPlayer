//
//  zlPlayer.m
//  zlPlayer
//
//  Created by Tang杰 on 2018/4/14.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zlPlayer.h"
#import "NSDictionaryUtils.h"
#import "Masonry.h"
#import "PlayerManager.h"
#import "PlayerToolView.h"
#import "SBControlView.h"

typedef NS_ENUM(NSUInteger, ScreenOrientation) {
    ScreenOrientation_portrait_up = 1,               //竖屏时，屏幕在home键的上面
    ScreenOrientation_portrait_down,            //竖屏时，幕在home键的下面，部分手机不支持
    ScreenOrientation_landscape_left,            //横屏时，屏幕在home键的左边
    ScreenOrientation_landscape_right,            //横屏时，屏幕在home键的右边
    ScreenOrientation_auto,                   //屏幕根据重力感应在横竖屏间自动切换
    ScreenOrientation_auto_portrait,            //屏幕根据重力感应在竖屏间自动切换
    ScreenOrientation_auto_landscape,            //屏幕根据重力感应在横屏间自动切换
};

static NSInteger count = 0;

@interface zlPlayer()<PlayerManagerDelegate,PlayerToolViewDelegate>
{
    NSMutableDictionary *_cbIdDictionary;
    NSString *_fixedOn;
    BOOL _fixed;
    CGRect _rect;
    NSString *_orientation;
    NSString *_title;
}

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) CADisplayLink *timer;

@property (nonatomic, strong) PlayerToolView *playerToolView;


@property (nonatomic, strong, readonly) PlayerManager *manager;

@property (nonatomic, assign, readonly) CMTime  currentTime;
@property (nonatomic, assign, readonly) CMTime  totalDuration;

@end

@implementation zlPlayer

- (id)initWithUZWebView:(id)webView
{
    if (self = [super initWithUZWebView:webView]) {
//        [self setScreenOrientation:@{@"orientation":@"auto"}];
        _cbIdDictionary = @{}.mutableCopy;
        _orientation = [self screenOrientation:ScreenOrientation_landscape_right];
    }
    return self;
}
- (void)dispose
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
#pragma mark - public

/** 初始化视频播放器 */
- (void)init:(NSDictionary *)paramDict   {
    [self addCbIDByParamDict:paramDict SEL:@selector(init:)];
    
    NSDictionary *rect = [paramDict dictValueForKey:@"rect" defaultValue:nil];
    _rect = CGRectZero;
    if (rect) {
        _rect = CGRectMake([[rect objectForKey:@"x"] floatValue], [[rect objectForKey:@"y"] floatValue], [[rect objectForKey:@"w"] floatValue], [[rect objectForKey:@"h"] floatValue]);
    }
    _fixedOn = [paramDict stringValueForKey:@"fixedOn" defaultValue:@""];
    _fixed = [paramDict boolValueForKey:@"fixed" defaultValue:NO];
    
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(player) name:UIApplicationWillEnterForegroundNotification object:nil];
}

/** 开始播放url */
- (void)play:(NSDictionary *)paramDict  {
    [self addCbIDByParamDict:paramDict SEL:@selector(play:)];
    NSString *url = [paramDict stringValueForKey:@"url" defaultValue:nil];
    _title = [paramDict stringValueForKey:@"title" defaultValue:url];
    _orientation = [paramDict stringValueForKey:@"direction" defaultValue:_orientation];
    self.playerToolView.title = _title;
    BOOL status = [self.manager playWithURL:[NSURL URLWithString:url]];
    [self callback:status msg:status ? @"":@"播放失败"  SEL:@selector(play:)];
}
/** 获取播放器当前播放进度 */
- (void)getCurrentPosition:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(getCurrentPosition:)];
    [self callbackByDic:@{@"status":@(YES),@"currentPosition":@(self.currentTime.value/self.currentTime.timescale)} msg:@"" SEL:@selector(getCurrentPosition:)];
}
/** 停止播放 */
- (void)stop:(NSDictionary *)paramDict {
    [self.manager stop];
    [self addCbIDByParamDict:paramDict SEL:@selector(stop:)];
    [self callback:YES msg:@"" SEL:@selector(stop:)];
}

#pragma mark - SBControlViewDelegate
-(void)controlView:(SBControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value{
    count = 0;
    CMTime pointTime = CMTimeMake(value * self.currentTime.timescale, self.currentTime.timescale);
    [self.manager seekTo:pointTime];
}
- (void)controlView:(SBControlView *)controlView sliderWillSliding:(UISlider *)slider
{
    [self removeTimer];
}
- (void)controlView:(SBControlView *)controlView sliderEndSliding:(UISlider *)slider
{
    [self addTimer];
}
-(void)controlView:(SBControlView *)controlView draggedPositionWithSlider:(UISlider *)slider{
    count = 0;
    CMTime pointTime = CMTimeMake(controlView.value * self.manager.currentTime.timescale, self.manager.currentTime.timescale);

    [self.manager seekTo:pointTime];
}
- (void)controlView:(SBControlView *)controlView withPlayButton:(UIButton *)button
{
    if (!button.selected) {
        [self.manager pause];
    } else {
         [self.manager resume];
    }
}
-(void)controlView:(SBControlView *)controlView withLargeButton:(UIButton *)button{
    count = 0;
    [self setOrientation:button.selected];
}
#pragma mark - PlayerManagerDelegate
- (void)playerStatusDidChange:(PlayerStatus)state
{
    if (state <= PlayerStatusCaching) {
        [self.activityIndicatorView startAnimating];
    } else {
        [self.activityIndicatorView stopAnimating];
    }
    
    if (state == PlayerStatusPlaying) {
        [self.playerToolView setIsPlaying:YES];
        [self.playerToolView updateTotalTime:self.totalDuration];
        [self addTimer];
    } else {
        [self removeTimer];
    }
    if (state == PlayerStatusCompleted) {
        [self.playerToolView setIsPlaying:NO];
    }
    
}
- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    [self.activityIndicatorView stopAnimating];
}
#pragma mark - PlayerToolViewDelegate

- (void)exitFullScreen
{
    [self setOrientation:NO];
}
#pragma mark - event response

- (void)updatePlayTime {
    [self.playerToolView updatePlayTime:self.currentTime];
}
#pragma mark - private
/** 设置屏幕取向 */
- (void)setOrientation:(BOOL)isFullScreen {
    [self setScreenOrientation:@{@"orientation":isFullScreen ? _orientation : [self screenOrientation:ScreenOrientation_portrait_up]}];
    self.playerToolView.isFullScreen = isFullScreen;
    [self.manager.playerView removeFromSuperview];
    BOOL fixed = _fixed;
    if (isFullScreen) {
        self.manager.playerView.frame = [UIScreen mainScreen].bounds;
        fixed = YES;
    } else {
        self.manager.playerView.frame = _rect;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:isFullScreen withAnimation:UIStatusBarAnimationNone];
    [self addSubview:self.manager.playerView fixedOn:_fixedOn fixed:fixed];
}

/** 回调JS */
- (void)callback:(BOOL)status msg:(NSString *)msg SEL:(SEL)sel {
    
    if (!msg) msg = @"";
    [self callbackByDic:@{@"status":@(status)} msg:msg SEL:sel];
}
- (void)callbackByDic:(NSDictionary *)dic msg:(NSString *)msg SEL:(SEL)sel  {
    NSInteger cbID = [_cbIdDictionary intValueForKey:NSStringFromSelector(sel) defaultValue:0];
    [self sendResultEventWithCallbackId:cbID dataDict:dic errDict:@{@"msg":msg} doDelete:YES];
    [_cbIdDictionary removeObjectForKey:NSStringFromSelector(sel)];
}

- (void)addCbIDByParamDict:(NSDictionary *)paramDict SEL:(SEL)sel {
    NSInteger cbId = [paramDict integerValueForKey:@"cbId" defaultValue:0];
    [_cbIdDictionary setValue:@(cbId) forKey:NSStringFromSelector(sel)];
}
- (void)sendResultEventWithError:(NSString *)msg {
    [self sendResultEventWithCallbackId:0 dataDict:nil errDict:nil doDelete:YES];
}

- (void)player {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.manager resume];
}

- (void)addTimer {
    [self removeTimer];
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePlayTime)];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)removeTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (NSString *)screenOrientation:(ScreenOrientation)orientation {
    switch (orientation) {
        case ScreenOrientation_portrait_up:
            return @"portrait_up";
            break;
        case ScreenOrientation_portrait_down:
            return @"portrait_down";
            break;
        case ScreenOrientation_landscape_left:
            return @"landscape_left";
            break;
        case ScreenOrientation_landscape_right:
            return @"landscape_right";
            break;
        case ScreenOrientation_auto:
            return @"auto";
            break;
        case ScreenOrientation_auto_portrait:
            return @"auto_portrait";
            break;
        case ScreenOrientation_auto_landscape:
            return @"auto_landscape";
            break;
        default:
            return @"landscape_right";
            break;
    }
}

#pragma mark - getter/setter
- (PlayerManager *)manager
{
    PlayerManager *manager = [PlayerManager defaultManager];
    manager.delegate = self;
    return manager;
}
- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _activityIndicatorView;
}
- (PlayerToolView *)playerToolView
{
    if (!_playerToolView) {
        _playerToolView = [[PlayerToolView alloc] init];
        _playerToolView.delegate = self;
    }
    return _playerToolView;
}
- (CMTime)currentTime
{
    return self.manager.currentTime;
}
- (CMTime)totalDuration
{
    return self.manager.totalDuration;
}

//添加视图
-(void)setupView{
    UIView *playerView = self.manager.playerView;

    playerView.backgroundColor = [UIColor blackColor];
    playerView.contentMode = UIViewContentModeScaleAspectFit;
    playerView.frame = _rect;
    //        playerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    //        | UIViewAutoresizingFlexibleTopMargin
    //        | UIViewAutoresizingFlexibleLeftMargin
    //        | UIViewAutoresizingFlexibleRightMargin
    //        | UIViewAutoresizingFlexibleWidth
    //        | UIViewAutoresizingFlexibleHeight;
    [playerView addSubview:self.playerToolView];
    [playerView addSubview:self.activityIndicatorView];
    
    [self.playerToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(playerView);
    }];
    [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(playerView);
    }];
    
    BOOL status = [self addSubview:playerView fixedOn:_fixedOn fixed:_fixed];
    [self callback:status msg:status ? @"":@"播放初始化失败"  SEL:@selector(init:)];
}
@end
