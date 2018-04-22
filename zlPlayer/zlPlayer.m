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
#import "SBControlView.h"
#import "Masonry.h"
#import "PlayerManager.h"

static NSInteger count = 0;

@interface zlPlayer()<SBControlViewDelegate>
{
    NSInteger _cbId;
    NSString *_fixedOn;
    BOOL _fixed;
    CGRect _rect;
    NSString *_orientation;
}

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) CADisplayLink *timer;
//底部控制视图
@property (nonatomic,strong) SBControlView *controlView;

@property (nonatomic, strong, readonly) PlayerManager *manager;

@property (nonatomic, assign, readonly) CMTime  currentTime;
@property (nonatomic, assign, readonly) CMTime  totalDuration;

@end

@implementation zlPlayer

- (id)initWithUZWebView:(id)webView
{
    if (self = [super initWithUZWebView:webView]) {
//        [self setScreenOrientation:@{@"orientation":@"auto"}];
    }
    return self;
}

#pragma mark - public
/** 初始化视频播放器 */
- (void)init:(NSDictionary *)paramDict   {
    _cbId = [paramDict integerValueForKey:@"cbId" defaultValue:0];
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

/** 显示播放视图 */
- (void)play:(NSDictionary *)paramDict  {
    NSString *url = [paramDict stringValueForKey:@"url" defaultValue:nil];
    [self.manager playWithURL:[NSURL URLWithString:url]];
}

/** 回调JS */
- (void)callback:(BOOL)status msg:(NSString *)msg {
    
    if (!msg) msg = @"";
    
    [self sendResultEventWithCallbackId:_cbId dataDict:@{@"status":@(status)} errDict:@{@"msg":msg} doDelete:YES];
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
    if (button.selected) {
        [self.manager pause];
    } else {
         [self.manager resume];
    }
}
-(void)controlView:(SBControlView *)controlView withLargeButton:(UIButton *)button{
    count = 0;
//    if (kScreenWidth<kScreenHeight) {
//        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
//    }else{
//        [self interfaceOrientation:UIInterfaceOrientationPortrait];
//    }
    [[UIApplication sharedApplication] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"statusBarOrientation"];
}

- (void)fullScreen:(BOOL)fullScreen
{
    
    UIView *playerView = self.manager.playerView;
    [playerView removeFromSuperview];
//    if (fullScreen) {
//        playerView.frame = CGRectMake(0, 0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
//        [self addSubview:playerView fixedOn:nil fixed:YES];
//    } else {
//        if (_rect) {
//            playerView.frame = CGRectFromString(_rect);
//        }
//        [self addSubview:playerView fixedOn:_fixedOn fixed:_fixed];
//    }
    [self setScreenOrientation:@{@"orientation":fullScreen ? _orientation : @"portrait_up"}];
//    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(playerView.bounds) - CGRectGetHeight(self.bottomView.bounds), CGRectGetWidth(playerView.bounds), CGRectGetHeight(self.bottomView.bounds));
}
#pragma mark - event response

- (void)updatePlayTime {
    CGFloat second = self.currentTime.value/self.currentTime.timescale;
    self.controlView.currentTime = [PlayerTool convertTime:second];
    self.controlView.value = second;
    NSLog(@"8888");
}
#pragma mark - private
- (void)player {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.manager play];
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

#pragma mark - getter/setter
- (PlayerManager *)manager
{
    return [PlayerManager defaultManager];
}
- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _activityIndicatorView;
}
- (CMTime)currentTime
{
    return self.manager.currentTime;
}
- (CMTime)totalDuration
{
    return self.manager.totalDuration;
}
//懒加载控制视图
-(SBControlView *)controlView{
    if (!_controlView) {
        _controlView = [[SBControlView alloc]init];
        _controlView.delegate = self;
        _controlView.backgroundColor = [UIColor clearColor];
//        [_controlView.tapGesture requireGestureRecognizerToFail:self.pauseOrPlayView.imageBtn.gestureRecognizers.firstObject];
    }
    return _controlView;
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

    [playerView addSubview:self.activityIndicatorView];
    
    [playerView addSubview:self.controlView];
    
    [self addSubview:playerView fixedOn:_fixedOn fixed:_fixed];

    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(playerView);
        make.height.mas_equalTo(@44);
    }];
}
@end
