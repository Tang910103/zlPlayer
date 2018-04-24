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
#import "AliyunVodPlayerViewSDK.h"

typedef NS_ENUM(NSUInteger, ScreenOrientation) {
    /** 竖屏时，屏幕在home键的上面 */
    ScreenOrientation_portrait_up = 1,
    /** 竖屏时，幕在home键的下面，部分手机不支持 */
    ScreenOrientation_portrait_down,
    /** //横屏时，屏幕在home键的左边 */
    ScreenOrientation_landscape_left,
    /** //横屏时，屏幕在home键的右边 */
    ScreenOrientation_landscape_right,
    /**  //屏幕根据重力感应在横竖屏间自动切换 */
    ScreenOrientation_auto,
    /** //屏幕根据重力感应在竖屏间自动切换 */
    ScreenOrientation_auto_portrait,
    /** //屏幕根据重力感应在横屏间自动切换 */
    ScreenOrientation_auto_landscape,
};

static NSInteger count = 0;

@interface zlPlayer()<AliyunVodPlayerViewDelegate>
{
    NSMutableDictionary *_cbIdDictionary;
    NSString *_fixedOn;
    NSString *_referer;
    BOOL _fixed;
    CGRect _rect;
    NSString *_orientation;
    NSString *_title;
}
@property (nonatomic, strong) AliyunVodPlayerView *playerView;
@property (nonatomic, strong) NSURL *URL;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
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
    _referer = [paramDict stringValueForKey:@"referer" defaultValue:@""];
    _fixed = [paramDict boolValueForKey:@"fixed" defaultValue:NO];
    
    [self initPlayerView];
    
    /**************************************/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

/** 开始播放url */
- (void)play:(NSDictionary *)paramDict  {
    [self addCbIDByParamDict:paramDict SEL:@selector(play:)];
    NSString *url = [paramDict stringValueForKey:@"url" defaultValue:nil];
    _title = [paramDict stringValueForKey:@"title" defaultValue:url];
    _orientation = [paramDict stringValueForKey:@"direction" defaultValue:_orientation];
    
    [self.playerView setTitle:_title];
    [self.playerView playViewPrepareWithURL:[NSURL URLWithString:url]];
    
    BOOL status = self.playerView.playerViewState == AliyunVodPlayerStateError;
    [self callback:status msg:status ? @"":@"播放失败"  SEL:@selector(play:)];
}
/** 获取播放器当前播放进度 */
- (void)getCurrentPosition:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(getCurrentPosition:)];
    [self callbackByDic:@{@"status":@(YES),@"currentPosition":@(self.playerView.currentTime)} msg:@"" SEL:@selector(getCurrentPosition:)];
}
/** 停止播放 */
- (void)stop:(NSDictionary *)paramDict {
    [self.playerView stop];
    [self addCbIDByParamDict:paramDict SEL:@selector(stop:)];
    [self callback:YES msg:@"" SEL:@selector(stop:)];
}

#pragma mark - private
/** 设置屏幕取向 */
- (void)setOrientation:(BOOL)isFullScreen {
    [self setScreenOrientation:@{@"orientation":isFullScreen ? _orientation : [self screenOrientation:ScreenOrientation_portrait_up]}];
//    [self.playerView removeFromSuperview];
    BOOL fixed = _fixed;
    if (isFullScreen) {
//        self.playerView.frame = [UIScreen mainScreen].bounds;
        fixed = YES;
    } else {
        self.playerView.frame = _rect;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:isFullScreen withAnimation:UIStatusBarAnimationNone];
    [self addSubview:self.playerView fixedOn:_fixedOn fixed:fixed];
}

/** 回调JS */
- (void)callback:(BOOL)status msg:(NSString *)msg SEL:(SEL)sel {
    
    if (!msg) msg = @"";
    [self callbackByDic:@{@"status":@(status)} msg:msg SEL:sel];
}
- (void)callbackByDic:(NSDictionary *)dic msg:(NSString *)msg SEL:(SEL)sel  {
    if ([_cbIdDictionary.allKeys containsObject:NSStringFromSelector(sel)]) {
        NSInteger cbID = [_cbIdDictionary intValueForKey:NSStringFromSelector(sel) defaultValue:0];
        [self sendResultEventWithCallbackId:cbID dataDict:dic errDict:@{@"msg":msg} doDelete:YES];
        [_cbIdDictionary removeObjectForKey:NSStringFromSelector(sel)];
    }
}

- (void)addCbIDByParamDict:(NSDictionary *)paramDict SEL:(SEL)sel {
    NSInteger cbId = [paramDict integerValueForKey:@"cbId" defaultValue:0];
    [_cbIdDictionary setValue:@(cbId) forKey:NSStringFromSelector(sel)];
}
- (void)sendResultEventWithError:(NSString *)msg {
    [self sendResultEventWithCallbackId:0 dataDict:nil errDict:nil doDelete:YES];
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
#pragma mark - AliyunVodPlayerViewDelegate
- (void)onBackViewClickWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView{
//    if (self.playerView != nil) {
//        [self.playerView stop];
//        [self.playerView releasePlayer];
//        [self.playerView removeFromSuperview];
//        self.playerView = nil;
//    }
    
//    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onPause:(NSTimeInterval)currentPlayTime{
    
    NSLog(@"onPause");
}
- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onResume:(NSTimeInterval)currentPlayTime{
    NSLog(@"onResume");
}
- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onStop:(NSTimeInterval)currentPlayTime{
    NSLog(@"onStop");
}
- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onSeekDone:(NSTimeInterval)seekDoneTime{
    NSLog(@"onSeekDone");
}
-(void)onFinishWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView{
    NSLog(@"onFinish");
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView lockScreen:(BOOL)isLockScreen{

}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onVideoQualityChanged:(AliyunVodPlayerVideoQuality)quality{
    
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView fullScreen:(BOOL)isFullScreen{
    NSLog(@"isfullScreen --%d",isFullScreen);
    [self setOrientation:isFullScreen];
}
#pragma mark - getter/setter

//添加视图
-(void)initPlayerView{
   
    self.playerView = [[AliyunVodPlayerView alloc] initWithFrame:_rect andSkin:AliyunVodPlayerViewSkinRed];
//    self.playerView.circlePlay = YES;
    [self.playerView setDelegate:self];
    [self.playerView setAutoPlay:YES];
    self.playerView.isScreenLocked = NO;
    self.playerView.fixedPortrait = NO;
    
    //边下边播缓存沙箱位置
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [pathArray objectAtIndex:0];
    //maxsize:单位 mb    maxDuration:单位秒 ,在prepare之前调用。
    [self.playerView setPlayingCache:NO saveDir:docDir maxSize:300 maxDuration:10000];
    
    //播放本地视频
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"set.mp4" ofType:nil];
    //    [self.playerView playViewPrepareWithURL:[NSURL URLWithString:@"http://shenji.zlketang.com/public/test.mp4"]];
    //播放器播放方式
    AliyunVodPlayer *aliPlayer = [self.playerView valueForKey:@"_aliPlayer"];
    aliPlayer.referer = _referer;
    BOOL status = [self addSubview:self.playerView fixedOn:_fixedOn fixed:_fixed];
    [self callback:status msg:status ? @"":@"播放初始化失败"  SEL:@selector(init:)];
}

- (void)becomeActive{
    [self.playerView resume];
}

- (void)resignActive{
    if (self.playerView && self.playerView.playerViewState == AliyunVodPlayerStatePlay){
        [self.playerView pause];
    }
}

@end
