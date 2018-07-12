//
//  AliyunVodPlayerView.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunVodPlayerView.h"
#import "AliyunPVBaseLayer.h"
#import "AliyunPVControlLayer.h"
#import "AliyunPVPopLayer.h"
#import "AliyunPVUtil.h"
#import "AliyunPVLoadingView.h"
#import "AliyunPVErrorView.h"
#import "AliyunPVPrivateDefine.h"
#import "AliyunPVSeekPopupView.h"
#import "AliyunPVReachability.h"
#import "AliyunPVDisplayLayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AliyunFirstStartGuideView.h"

#import "AliyunVodPlayer.h"

@interface AliyunVodPlayerView () <AliyunPVSeekPopupViewDelegate,AliyunVodPlayerDelegate,AliyunPVControlLayerDelegate,AliyunPVPopLayerDelegate,AliyunPVBaseLayerDelegate,AliyunPVPlaySpeedViewDelegate>
//sdk
@property (nonatomic, strong) AliyunVodPlayer *aliPlayer;               //点播播放器
@property (nonatomic, strong) AliyunPVReachability *reachability;       //网络监听

//接收sdk view，带有手势
@property (nonatomic, strong) AliyunPVDisplayLayer *displayLayer;       //播放器容器
@property (nonatomic, strong) AliyunPVControlLayer *controlLayer;       //播放器上层的展示界面，包括：标题、进度条、播放按钮、清晰度等
@property (nonatomic, strong) AliyunPVPopLayer *popLayer;               //弹出的提示界面
@property (nonatomic, assign) CGRect saveFrame;
@property (nonatomic, strong) AliyunPVLoadingView *loadingView;         //loading
@property (nonatomic, strong) AliyunPVSeekPopupView *seekView;          //前进、后退

//重试
@property (nonatomic ,assign) AliyunVodPlayerViewPlayMethod playMethod; //播放方式

//PLAY_AUTH
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *playAuth;

//URL
@property (nonatomic, copy) NSURL *tempUrl;

//MPS
@property (nonatomic, copy) NSString *mtsVideoId;
@property (nonatomic, copy) NSString *mtsAccessKey;
@property (nonatomic, copy) NSString *mtsAccessSecret;
@property (nonatomic, copy) NSString *mtsStsToken;
@property (nonatomic, copy) NSString *mtsAuthInfo;
@property (nonatomic, copy) NSString *mtsRegion;
@property (nonatomic, copy) NSString *mtsPlayDomain;
@property (nonatomic, copy) NSString *mtsHlsUriToken;

//STS
@property (nonatomic, copy) NSString *stsVideoId;
@property (nonatomic, copy) NSString *stsAccessKeyId;
@property (nonatomic, copy) NSString *stsAccessSecret;
@property (nonatomic, copy) NSString *stsStstoken;

@property (nonatomic, strong) NSTimer *timer;                               //计时器
@property (nonatomic, assign) NSTimeInterval currentDuration;               //记录播放时长
@property (nonatomic, strong) AliyunFirstStartGuideView *guideView;     //导航图，第一次使用时，手势介绍。
@property (nonatomic, strong) UIImageView *coverImageView;                   //封面
@property (nonatomic, assign) AliyunVodPlayerVideoQuality currentQuality;   //临时存储清晰度
@property (nonatomic, copy) NSString *currentMediaTitle;                    //设置标题，如果用户已经设置自己标题，不在启用请求获取到的视频标题信息。
@property (nonatomic, assign) BOOL isProtrait;                              //是否是竖屏

//重试时继续上一次的时间点播放
@property (nonatomic, assign) BOOL isRerty;                        //default：NO
@property (nonatomic, assign) float saveCurrentTime;               //保存重试之前的播放时间

@property (nonatomic, assign) BOOL mProgressCanUpdate;             //进度条是否更新，默认是NO

@property (nonatomic, strong) UIImageView *brightView;             //亮度提示图
@property (nonatomic, strong) UIProgressView *brightProgress;      //亮度提示al_fingerGesture_brightness

@end


@implementation AliyunVodPlayerView


#pragma mark - 初始化
- (instancetype)init{
    _mProgressCanUpdate = YES;
    return [self initWithFrame:CGRectZero];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    //指记录竖屏时界面尺寸
    if ([AliyunPVUtil isInterfaceOrientationPortrait]){
        if (!self.fixedPortrait) {
            self.saveFrame = frame;
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    _mProgressCanUpdate = YES;
    return [self initWithFrame:frame andSkin:AliyunVodPlayerViewSkinBlue];
}

- (void)setViewSkin:(AliyunVodPlayerViewSkin)viewSkin{
    _viewSkin = viewSkin;
    [_controlLayer setSkin:viewSkin];
    [_popLayer setSkin:viewSkin];
    [_playSpeedView setSkin:viewSkin];
}

//初始化view
- (void)initView{
    //displayLayer 是 aliPlayer 容器
    _displayLayer  = [[AliyunPVDisplayLayer alloc] init];
    _displayLayer.backgroundColor = [UIColor clearColor];
    
    //播放器
    _aliPlayer = [[AliyunVodPlayer alloc] init];
    _aliPlayer.delegate = self;
    [self.displayLayer addSubview:_aliPlayer.playerView];
    _displayLayer.baseDelegate = self;
    [_displayLayer setEnableGesture:YES];
    [self addSubview:_displayLayer];
    
    //封面
    _coverImageView = [[UIImageView alloc] init];
    _coverImageView.backgroundColor = [UIColor clearColor];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_coverImageView];
    
    //controlLayer 包含title backbtn  playbtn progress qualitybtn fullscreenbtn
    _controlLayer = [[AliyunPVControlLayer alloc] init];
    _controlLayer.contrololLayerDelegate  = self;
    [self addSubview:_controlLayer];
    _controlLayer.baseDelegate = self;
    [_controlLayer setEnableGesture:YES];
    
    //跳转界面 errorview 等
    _popLayer = [[AliyunPVPopLayer alloc] init];
    _popLayer.popLayerDelegate = self;
    
    //倍速播放界面
    _playSpeedView = [[AliyunPVPlaySpeedView alloc] init];
    _playSpeedView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _playSpeedView.hidden = YES;
    _playSpeedView.playSpeedViewDelegate = self;
    [self addSubview:_playSpeedView];
    
    //手势使用导航，第一次使用横屏时有效。
    _guideView = [[AliyunFirstStartGuideView alloc] init];
    _guideView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    //parentView 承载界面，来替换临时需要转世的界面
    [_displayLayer setParentView:self];
    [_controlLayer setParentView:self];
    [_popLayer setParentView:self];
    
    //loading
    _loadingView = [[AliyunPVLoadingView alloc] init];
    [self addSubview:_loadingView];
    
    //前进、后退手势图片
    self.seekView = [[AliyunPVSeekPopupView alloc] init];
    [self.seekView setDelegate:self];
    
    //亮度
    UIImage *blightImage = [AliyunPVUtil imageWithNameInBundle:@"al_video_brightness_bg"];
    _brightView = [[UIImageView alloc] init];
    _brightView.image = blightImage;
    _brightView.alpha = 0.0;
    [self addSubview:_brightView];
    _brightProgress = [[UIProgressView alloc] init];
    _brightProgress.backgroundColor = [UIColor clearColor];
    _brightProgress.trackTintColor =[UIColor blackColor];
    _brightProgress.progressTintColor =[UIColor whiteColor];
    _brightProgress.progress =[UIScreen mainScreen].brightness;
    _brightProgress.transform = CGAffineTransformMakeScale(1.0f,2.0f);
    [_brightView addSubview:_brightProgress];
}

#pragma mark - 指定初始化方法
- (instancetype)initWithFrame:(CGRect)frame andSkin:(AliyunVodPlayerViewSkin)skin {
    self = [super initWithFrame:frame];
    if (self) {
        if ([AliyunPVUtil isInterfaceOrientationPortrait]){
            self.saveFrame = frame;
        }else{
            self.saveFrame = CGRectZero;
        }
        
        _mProgressCanUpdate = YES;
        
        //设置view
        [self initView];
        
        //加载控件皮肤
        self.viewSkin = skin;
        
        //屏幕旋转通知
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil
         ];
        
        //网络状态判定
        _reachability = [AliyunPVReachability reachabilityForInternetConnection];
        [_reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged)
                                                     name:AliyunPVReachabilityChangedNotification
                                                   object:nil];
        //存储第一次出发saas
        NSString *str =   [[NSUserDefaults standardUserDefaults] objectForKey:@"aliyunVodPlayerFirstOpen"];
        if (!str) {
            [[NSUserDefaults standardUserDefaults] setValue:@"aliyun_saas_first_open" forKey:@"aliyunVodPlayerFirstOpen"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return self;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    self.displayLayer.frame = CGRectMake(0, 0, width, height);
    self.displayLayer.center = CGPointMake(width/2, height/2);
    self.aliPlayer.playerView.frame = self.displayLayer.bounds;
    
    self.controlLayer.frame = self.bounds;
    self.popLayer.frame = self.bounds;
    self.popLayer.center = CGPointMake(width/2, height/2);
    
    self.coverImageView.frame= CGRectMake(0, 0, self.aliyun_width, self.aliyun_height);
    self.guideView.frame =  CGRectMake(0, 0, self.aliyun_width, self.aliyun_height);
    
    float loadingViewWidth = [AliyunPVUtil convertPixelToPoint:ALPV_PX_LOADING_VIEW_WIDTH];
    float loadingViewHeight =  [AliyunPVUtil convertPixelToPoint:ALPV_PX_LOADING_VIEW_HEIGHT];
    float x = (self.bounds.size.width -  loadingViewWidth)/2;
    float y = (self.bounds.size.height - loadingViewHeight)/2;
    self.loadingView.frame = CGRectMake(x, y, loadingViewWidth, loadingViewHeight);
    self.seekView.center = CGPointMake(width/2, height/2);
    self.brightView.frame = CGRectMake((SCREEN_HEIGHT-250)/2,(SCREEN_WIDTH-250)/2, 125, 125);
    self.brightView.center = CGPointMake(width/2, height/2);
    self.brightProgress.frame = CGRectMake(15,self.brightView.frame.size.height-10,self.brightView.frame.size.width-30,20);
    
    if ([AliyunPVUtil isInterfaceOrientationPortrait]){
        self.playSpeedView.frame = self.bounds;
    }else{
        self.playSpeedView.frame = CGRectMake(self.aliyun_width-310, 0, 310, self.aliyun_height);
    }
}


#pragma mark - 网络状态改变
- (void)reachabilityChanged{
    [self networkChangedToShowPopView];
}

//网络状态判定
- (BOOL)networkChangedToShowPopView{
    BOOL ret = NO;
    switch ([self.reachability currentReachabilityStatus]) {
        case AliyunPVNetworkNotReachable:
        {
//            [_loadingView dismiss];
        }
            break;
        case AliyunPVNetworkReachableViaWiFi:
            break;
        case AliyunPVNetworkReachableViaWWAN:
        {
            if (self.tempUrl&&self.tempUrl.fileURL) {
                return NO;
            }
            if (self.aliPlayer.autoPlay) {
                self.aliPlayer.autoPlay = NO;
            }
            if (self.aliPlayer.playerState == AliyunVodPlayerStatePlay) {
                [self.aliPlayer pause];
            }
            [self unlockScreen];
            [self.popLayer showPopViewWithCode:AliyunPVPlayerPopCodeUseMobileNetwork popMsg:nil];
            ret = YES;
        }
            break;
        default:
            break;
    }
    return ret;
}

#pragma mark - 屏幕旋转
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation{
    UIDevice *device = [UIDevice currentDevice] ;
    
    if (self.isScreenLocked) {
        [self.displayLayer setEnableGesture: NO];
        [self.controlLayer lockScreenWithIsScreenLocked:self.isScreenLocked fixedPortrait:self.fixedPortrait];
        return;
    }else{
        [self.displayLayer setEnableGesture: YES];
    }    
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"aliyunVodPlayerFirstOpen"];
            if ([str isEqualToString:@"aliyun_saas_first_open"]) {
                [[NSUserDefaults standardUserDefaults] setValue:@"aliyun_saas_no_first_open" forKey:@"aliyunVodPlayerFirstOpen"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self addSubview:self.guideView];
            }
            if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:fullScreen:)]) {
                [self.delegate aliyunVodPlayerView:self fullScreen:YES];
            }
        }
            break;
        case UIDeviceOrientationPortrait:
        {
            if (self.saveFrame.origin.x == 0 && self.saveFrame.origin.y==0 && self.saveFrame.size.width == 0 && self.saveFrame.size.height == 0) {
                //开始时全屏展示，self.saveFrame = CGRectZero, 旋转竖屏时做以下默认处理
                CGRect tempFrame = self.frame ;
                tempFrame.size.width = self.frame.size.height;
                tempFrame.size.height = self.frame.size.height* 9/16;
                self.frame = tempFrame;
            }else{
                self.frame = self.saveFrame;
            }
            [self.guideView removeFromSuperview];
            if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:fullScreen:)]) {
                [self.delegate aliyunVodPlayerView:self fullScreen:NO];
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark - dealloc
- (void)dealloc {
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AliyunPVReachabilityChangedNotification object:self.aliPlayer];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.aliPlayer) {
        [self.aliPlayer releasePlayer];
        self.aliPlayer = nil;
    }
}

#pragma mark - 封面设置
- (void)setCoverUrl:(NSURL *)coverUrl{
    _coverUrl = coverUrl;
    if (coverUrl) {
        if (self.coverImageView) {
            self.coverImageView.hidden = NO;
            self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:coverUrl];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.coverImageView.image = [UIImage imageWithData:data];
                });
            });
        }
    }
}

#pragma mark - 清晰度
- (void)setQuality:(AliyunVodPlayerVideoQuality)quality{
    self.aliPlayer.quality = quality;
}
- (AliyunVodPlayerVideoQuality)quality{
    return self.aliPlayer.quality;
}
#pragma mark - MTS清晰度
- (void)setVideoDefinition:(NSString *)videoDefinition{
    self.aliPlayer.videoDefinition = videoDefinition;
}
- (NSString*)videoDefinition{
    return self.aliPlayer.videoDefinition;
}
#pragma mark - 缓冲的时长，毫秒
- (NSTimeInterval)bufferPercentage{
    return self.aliPlayer.bufferPercentage;
}
#pragma mark - 自动播放
- (void)setAutoPlay:(BOOL)autoPlay {
    [self.aliPlayer setAutoPlay:autoPlay];
}
#pragma mark - 循环播放
- (void)setCirclePlay:(BOOL)circlePlay{
    [self.aliPlayer setCirclePlay:circlePlay];
}
- (BOOL)circlePlay{
    return self.aliPlayer.circlePlay;
}
#pragma mark - 截图
- (UIImage *)snapshot{
    return  [self.aliPlayer snapshot];
}
#pragma mark - 浏览方式
- (void)setDisplayMode:(AliyunVodPlayerDisplayMode)displayMode{
    [self.aliPlayer setDisplayMode:displayMode];
}
- (void)setMuteMode:(BOOL)muteMode{
    [self.aliPlayer setMuteMode: muteMode];
}
#pragma mark - 是否正在播放中
- (BOOL)isPlaying{
    return [self.aliPlayer isPlaying];
}
#pragma mark - 播放总时长
- (NSTimeInterval)duration{
    return  [self.aliPlayer duration];
}
#pragma mark - 当前播放时长
- (NSTimeInterval)currentTime{
    return  [self.aliPlayer currentTime];
}
#pragma mark - 缓冲的时长，秒
- (NSTimeInterval)loadedTime{
    return  [self.aliPlayer loadedTime];
}
#pragma mark - 播放器宽度
- (int)videoWidth{
    return [self.aliPlayer videoWidth];
}
#pragma mark - 播放器高度
- (int)videoHeight{
    return [self.aliPlayer videoHeight];
}
#pragma mark - 设置绝对竖屏
- (void)setFixedPortrait:(BOOL)isLockPortrait{
    _fixedPortrait = isLockPortrait;
    if(isLockPortrait){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    }else{
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil
         ];
    }
}

#pragma mark - timeout
- (void)setTimeout:(int)timeout{
    [self.aliPlayer setTimeout:timeout];
}
- (int)timeout{
    return  self.aliPlayer.timeout;
}

#pragma mark - 打印日志
- (void)setPrintLog:(BOOL)printLog{
    [self.aliPlayer setPrintLog:printLog];
}
- (BOOL)isPrintLog{
    return self.aliPlayer.printLog;
}

/****************推荐播放方式*******************/
#pragma mark - vid+playauth
- (void)playViewPrepareWithVid:(NSString *)vid playAuth : (NSString *)playAuth{
    self.playAuth = playAuth;
    self.videoId = vid;
    self.playMethod = AliyunVodPlayerViewPlayMethodPlayAuth;
    if ([self networkChangedToShowPopView]) {
        return;
    }
    
    [_loadingView show];
    [self.aliPlayer prepareWithVid:vid playAuth:playAuth];
}

#pragma mark - 临时ak
- (void)playViewPrepareWithVid:(NSString *)vid
                   accessKeyId:(NSString *)accessKeyId
               accessKeySecret:(NSString *)accessKeySecret
                 securityToken:(NSString *)securityToken {
    
    self.stsVideoId = vid;
    self.stsAccessKeyId = accessKeyId;
    self.stsAccessSecret = accessKeySecret;
    self.stsStstoken = securityToken;
    self.playMethod = AliyunVodPlayerViewPlayMethodSTS;
    
    if ([self networkChangedToShowPopView]) {
        return;
    }
    
    [_loadingView show];
    [self.aliPlayer prepareWithVid:vid accessKeyId:accessKeyId accessKeySecret:accessKeySecret securityToken:securityToken];
}
#pragma mark - url
- (void)playViewPrepareWithURL:(NSURL *)url{
    self.tempUrl = url;
    self.playMethod = AliyunVodPlayerViewPlayMethodUrl;
    if ([self networkChangedToShowPopView]) {
        return;
    }
    
    [_loadingView show];
    [self.aliPlayer prepareWithURL:url];
}
#pragma mark - 媒体处理
-(void)playViewPrepareWithVid:(NSString *)vid
                    accessId : (NSString *)accessId
                accessSecret : (NSString *)accessSecret
                    stsToken : (NSString *)stsToken
                    autoInfo : (NSString *)autoInfo
                      region : (NSString *)region
                  playDomain : (NSString *)playDomain
               mtsHlsUriToken:(NSString *)mtsHlsUriToken{
    
    self.playMethod = AliyunVodPlayerViewPlayMethodMPS;
    self.mtsVideoId = vid;
    self.mtsAccessKey = accessId;
    self.mtsAccessSecret = accessSecret;
    self.mtsStsToken = stsToken;
    self.mtsAuthInfo = autoInfo;
    self.mtsRegion = region;
    self.mtsPlayDomain = playDomain;
    self.mtsHlsUriToken = mtsHlsUriToken;
    if ([self networkChangedToShowPopView]) {
        return;
    }
    
    [_loadingView show];
    [self.aliPlayer prepareWithVid:vid accId:accessId accSecret:accessSecret stsToken:stsToken authInfo:autoInfo region:region playDomain:playDomain mtsHlsUriToken:mtsHlsUriToken ];
}
/*******************************************/
#pragma mark - playManagerAction
- (void)start {
    [self.aliPlayer start];
}
- (void)pause{
    [self.aliPlayer pause];
}
- (void)resume{
    [self.aliPlayer resume];
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:onResume:)]) {
        NSTimeInterval time = self.aliPlayer.currentTime;//[ALPVCurrentInfo currentPlayTime];
        [self.delegate aliyunVodPlayerView:self onResume:time];
    }
}
- (void)stop {
    [self.aliPlayer stop];
}
- (void)replay{
    [self.aliPlayer replay];
}
- (void)reset{
    [self.aliPlayer reset];
}

- (void)releasePlayer {
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AliyunPVReachabilityChangedNotification object:self.aliPlayer];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.aliPlayer) {
        [self.aliPlayer releasePlayer];
        self.aliPlayer = nil;
    }
    //开启休眠
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}
#pragma mark - 播放器当前状态
- (AliyunVodPlayerState)playerViewState {
    return (AliyunVodPlayerState)[self.aliPlayer playerState];
}
#pragma mark - 媒体信息
- (AliyunVodPlayerVideo *)getAliyunMediaInfo{
    return  [self.aliPlayer getAliyunMediaInfo];
}
#pragma mark - 边播边下判定
- (void) setPlayingCache:(BOOL)bEnabled saveDir:(NSString*)saveDir maxSize:(int64_t)maxSize maxDuration:(int)maxDuration{
    [self.aliPlayer setPlayingCache:bEnabled saveDir:saveDir maxSize:maxSize maxDuration:maxDuration];
}

#pragma mark - playManagerDelegate
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    
    //根据播放器状态处理seek时thumb是否可以拖动
    [self.controlLayer updateViewWithPlayerState:vodPlayer.playerState];
    
    //不同播放器状态下 ，进度条和进度按钮 是否可用
    AliyunVodPlayerState state = vodPlayer.playerState;
    if (self.printLog) {
        NSLog(@"----onEventCallback----%lu--%lu",(unsigned long)event,(unsigned long)state);
    }
    
    //接收onEventCallback回调时，根据当前播放器事件更新UI播放器UI数据
    [self updateVodPlayViewDataWithEvent:event vodPlayer:vodPlayer];
}

-(void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(AliyunPlayerVideoErrorModel *)errorModel{
    //取消屏幕锁定旋转状态
    [self unlockScreen];
    //关闭loading动画
    [_loadingView dismiss];
    
    //根据播放器状态处理seek时thumb是否可以拖动
    [self.controlLayer updateViewWithPlayerState:vodPlayer.playerState];
    
    //根据错误信息，展示popLayer界面
    [self showPopLayerWithErrorModel:errorModel];
    
    if(self.printLog) {
        NSLog(@" errorCode:%d errorMessage:%@",errorModel.errorCode,errorModel.errorMsg);
    }
}

- (void)onCircleStartWithVodPlayer:(AliyunVodPlayer *)vodPlayer{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(onCircleStartWithVodPlayerView:)]) {
        [self.delegate onCircleStartWithVodPlayerView:self];
    }
}

- (void)onTimeExpiredErrorWithVodPlayer:(AliyunVodPlayer *)vodPlayer {
    //取消屏幕锁定旋转状态
    [self unlockScreen];
    //关闭loading动画
    [_loadingView dismiss];
    
    //根据播放器状态处理seek时thumb是否可以拖动
    [self.controlLayer updateViewWithPlayerState:vodPlayer.playerState];
    
    //根据错误信息，展示popLayer界面
    NSBundle *resourceBundle = [AliyunPVUtil languageBundle];
    AliyunPlayerVideoErrorModel* errorModel = [[AliyunPlayerVideoErrorModel alloc] init];
    errorModel.errorCode = ALIVC_ERR_AUTH_EXPIRED;
    errorModel.errorMsg = NSLocalizedStringFromTableInBundle(@"ALIVC_ERR_AUTH_EXPIRED", nil, resourceBundle, nil);
    [self showPopLayerWithErrorModel:errorModel];
    
    if(self.printLog) {
        NSLog(@" errorCode:%d errorMessage:%@",errorModel.errorCode,errorModel.errorMsg);
    }
}


- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer didSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    //controlLayer 清晰度列表
    NSLog(@"vodPlayer---%lu",(unsigned long)vodPlayer.playerState);
    [self.controlLayer hideQualityListView:YES];
    self.mProgressCanUpdate = YES;
}

- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer failSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    NSLog(@"vodPlayer---%lu",(unsigned long)vodPlayer.playerState);
    [self.popLayer showPopViewWithCode:AliyunPVPlayerPopCodeLoadDataError popMsg:nil];
    [self unlockScreen];
}

- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer willSwitchToQuality:(AliyunVodPlayerVideoQuality)quality videoDefinition:(NSString *)videoDefinition {
    self.mProgressCanUpdate = NO;
    //根据状态设置 controllayer 清晰度按钮 可用？
    [self.controlLayer updateViewWithPlayerState:vodPlayer.playerState];
}

#pragma mark - AliyunPVBaseLayerDelegate
- (void)baseLayer:(AliyunPVDisplayLayer *)baseLayer tapClieckedNumbers:(AliyunPVTapClickedEvent)event{
    switch (event) {
        case AliyunPVTapClickedEventSingle:
        {
            [self hiddenPlaySpeedView:self.playSpeedView completion:nil];

            if ([[self.controlLayer subviews] containsObject:self.controlLayer.qualityListView]) {
                [self.controlLayer hideQualityListView:YES];
            }
//            //loading动画
//            [self loadAnimation];
            if ([self.controlLayer isHidden]) {
                self.controlLayer.hidden = NO;
            }else{
                self.controlLayer.hidden = YES;
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHideControlLayer) object:nil];
            [self performSelector:@selector(delayHideControlLayer) withObject:nil afterDelay:5];
        }
            break;
        case AliyunPVTapClickedEventDouble:
        {
            AliyunVodPlayerState state = [self playerViewState];
            if (state == AliyunVodPlayerStatePlay) {
                [self pause];
            } else if (state == AliyunVodPlayerStatePause) {
                [self resume];
            }
        }
            break;
        case AliyunPVTapClickedEventNone:
            break;
        default:
            break;
    }
}
- (void)baseLayer:(AliyunPVBaseLayer *)baseLayer gestureState:(UIGestureRecognizerState)gestureState onPanBegin:(float)beginFloat onPanMoving:(float)movingFloat onPanEnd:(float)endFloat direction:(AliyunPVDirection)direction{
    
    if (self.isScreenLocked) {
        [self.displayLayer setEnableGesture: NO];
        [self.controlLayer lockScreenWithIsScreenLocked:self.isScreenLocked fixedPortrait:self.fixedPortrait];
        return;
    }else{
        [self.displayLayer setEnableGesture: YES];
    }
    
    switch (gestureState) {
        case UIGestureRecognizerStateBegan:
            [self.controlLayer.progressView moveBegin:AliyunPVOrientationHorizontal];
            break;
        case UIGestureRecognizerStateChanged:
            {
                self.mProgressCanUpdate = NO;
                //            [self.timer invalidate];
                //            self.timer = nil;
                if (direction== AliyunPVDirectionLeft||direction == AliyunPVDirectionRight) {
                    [self showSeekViewWithOffset:movingFloat];
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
        {
            AliyunPVOrientation o = -1;
            switch (direction) {
                case AliyunPVDirectionUp:
                case AliyunPVDirectionDown:
                {
                    o = AliyunPVOrientationHorizontal;
                    [UIView animateWithDuration:0.5f animations:^{
                        self.brightView.alpha =0.0f;
                    }];
                }
                    break;
                case AliyunPVDirectionLeft:
                case AliyunPVDirectionRight:
                {
                    o = AliyunPVOrientationHorizontal;
                    [_seekView onPanFinished];
                    double currentVideoDuration = self.aliPlayer.duration;
                    double seekTime = 0;
                    float width = self.controlLayer.bounds.size.width;
                    seekTime = endFloat / width * currentVideoDuration + self.aliPlayer.currentTime;
                    [self.aliPlayer seekToTime:seekTime];
                    [self resume];
                    
                    self.mProgressCanUpdate = YES;
//                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
//                    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
                    
                    [self.controlLayer.progressView moveEnd:o];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
}
- (void)baseLayer:(AliyunPVBaseLayer *)baseLayer chanageBrightnessValue:(float)seekValue direction:(AliyunPVDirection)direction{
    self.brightView.alpha =1.0f;
    self.brightProgress.progress =seekValue;
}
#pragma mark - AliyunPVControlLayerDelegate
- (void)AliyunPVControlLayer:(AliyunPVControlLayer *)controlLayer onClickButton:(UIButton *)clickButton{
    int tag = (int) clickButton.tag;
    switch (tag) {
        case ALPV_CLICK_BACK:
        {
            // 只要切换屏幕 分辨率列表就隐藏
            [controlLayer.qualityListView removeFromSuperview];
            if (![AliyunPVUtil isInterfaceOrientationPortrait]) {
                [AliyunPVUtil setFullOrHalfScreen];
            } else {
                if(self.delegate && [self.delegate respondsToSelector:@selector(onBackViewClickWithAliyunVodPlayerView:)])
                    [self.delegate onBackViewClickWithAliyunVodPlayerView:self];
                else {
                    [self stop];
                }
            }
        }
            break;
        case ALPV_CLICK_LOCK:
        {
            controlLayer.lockBtn.selected = !controlLayer.lockBtn.selected;
            self.isScreenLocked =controlLayer.lockBtn.selected;
            //锁屏判定
            [controlLayer lockScreenWithIsScreenLocked:self.isScreenLocked fixedPortrait:self.fixedPortrait];
            if (!self.isScreenLocked) {
                [self.displayLayer setEnableGesture: YES];
            }else{
                [self.displayLayer setEnableGesture: NO];
            }
            
            //消除滑动中的界面
            if ([_seekView isShowing]) {
                [_seekView onPanFinished];
            }
            self.brightView.alpha =0.0f;
            
            
            if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:lockScreen:)]) {
                BOOL lScreen = self.isScreenLocked;
                if (self.isProtrait) {
                    lScreen = YES;
                }
                [self.delegate aliyunVodPlayerView:self lockScreen:lScreen];
            }
        }
            break;
        case ALPV_CLICK_PLAY: {
            AliyunVodPlayerState state = [self playerViewState];
            if (state == AliyunVodPlayerStatePlay)
                [self pause];
            else if (state == AliyunVodPlayerStatePrepared)
                [self.aliPlayer start];
            else if(state == AliyunVodPlayerStatePause)
                [self resume];
        }
            break;
        case ALPV_CLICK_FULL_SCREEN:
        {
            // 只要切换屏幕 分辨率列表就隐藏
            [controlLayer.qualityListView removeFromSuperview];
            
            if(self.isScreenLocked){
                break;
            }
            
            if(self.fixedPortrait){
            if(!self.isProtrait){
                    controlLayer.lockBtn.hidden = NO;
                    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                    self.isProtrait = YES;
                    if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:fullScreen:)]) {
                        [self.delegate aliyunVodPlayerView:self fullScreen:YES];
                    }
                }else{
                    self.frame = self.saveFrame;
                    self.isProtrait = NO;
                    controlLayer.lockBtn.hidden = YES;
                    if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:fullScreen:)]) {
                        [self.delegate aliyunVodPlayerView:self fullScreen:NO];
                    }
                }
            }else{
                
                [AliyunPVUtil setFullOrHalfScreen];
            }
            controlLayer.isProtrait = self.isProtrait;
            [self setNeedsLayout];
        }
            break;
        case ALPV_CLICK_DOWNLOAD: {
        }
            break;
        case ALPV_CLICK_CHANGE_QUALITY:
        {
            if (self.isScreenLocked&&!self.fixedPortrait) {
                break;
            }
            controlLayer.qualityBtn.selected = !controlLayer.qualityBtn.isSelected;
            if (controlLayer.qualityBtn.selected) {
                [controlLayer addSubview:controlLayer.qualityListView];
            } else {
                [controlLayer.qualityListView removeFromSuperview];
            }
        }
            break;
        case ALPV_CLICK_PLAYSPEED:
        {
            if (![self.controlLayer isHidden]) {
                self.controlLayer.hidden = YES;
            }
            //倍速播放入场动画
            [self showSpeedViewMoveInAnimateWithPlaySpeedView:self.playSpeedView];
        }
            break;
        default:
            break;
    }
}
#pragma mark AliyunPVPlaySpeedViewDelegate
- (void)AliyunPVPlaySpeedView:(AliyunPVPlaySpeedView *)playSpeedView displayMode:(AliyunVodPlayerDisplayMode)displayMode
{
    [self setDisplayMode:displayMode];
    [self hiddenPlaySpeedView:playSpeedView completion:^(BOOL finished) {
        [self showToast:[NSString stringWithFormat:@"当前屏幕模式切换为：%@",displayMode == AliyunVodPlayerDisplayModeFit ? @"适应大小" : @"裁剪铺满"]];
        if ([self.delegate respondsToSelector:@selector(AliyunPVPlaySpeedView:displayMode:)]) {
            [self.delegate aliyunVodPlayerView:self displayMode:displayMode];
        }
    }];
}
- (void)AliyunPVPlaySpeedView:(AliyunPVPlaySpeedView *)playSpeedView isAutomaticFlow:(BOOL)isAutomaticFlow
{
    [self hiddenPlaySpeedView:playSpeedView completion:^(BOOL finished) {
        [self showToast:[NSString stringWithFormat:@"当前播放方式切换为：%@",isAutomaticFlow ? @"自动连播" : @"播完暂停"]];
        if ([self.delegate respondsToSelector:@selector(AliyunPVPlaySpeedView:isAutomaticFlow:)]) {
            [self.delegate aliyunVodPlayerView:self isAutomaticFlow:isAutomaticFlow];
        }
    }];
}
- (void)AliyunPVPlaySpeedView:(AliyunPVPlaySpeedView *)playSpeedView playSpeed:(AliyunVodPlayerViewPlaySpeed)playSpeed{
    
    float speed = [self floatValueSpeedViewWithPlaySpeed:playSpeed];
    self.aliPlayer.playSpeed = speed;
    //倍速播放选中后退场动画
    [self showSpeedViewSelectedPushInAnimateWithPlaySpeedView:self.playSpeedView playSpeed:playSpeed];
}

//倍速 int->float
- (float)floatValueSpeedViewWithPlaySpeed:(AliyunVodPlayerViewPlaySpeed)playSpeed{
    float speedFloatValue = 0.0;
    switch (playSpeed) {
        case AliyunVodPlayerViewPlaySpeedNomal:
            speedFloatValue = 1;
            break;
        case AliyunVodPlayerViewPlaySpeedOnePointTwoFive:
            speedFloatValue = 1.25;
            break;
        case AliyunVodPlayerViewPlaySpeedOnePointFive:
            speedFloatValue = 1.5;
            break;
        case AliyunVodPlayerViewPlaySpeedTwo:
            speedFloatValue = 2;
            break;
            
        default:
            speedFloatValue = 0.8;
            break;
    }
    
    return speedFloatValue;
}

//AliyunVodPlayerViewPlaySpeedNomal = 0,
//AliyunVodPlayerViewPlaySpeedOnePointTwoFive,
//AliyunVodPlayerViewPlaySpeedOnePointFive,
//AliyunVodPlayerViewPlaySpeedTwo
- (NSString *)playSpeedGetString:(AliyunVodPlayerViewPlaySpeed)playSpeed{
    NSString *playSpeedString = @"";
    switch (playSpeed) {
        case AliyunVodPlayerViewPlaySpeedNomal:
            playSpeedString = @"Nomal";
            break;
        case AliyunVodPlayerViewPlaySpeedOnePointTwoFive:
            playSpeedString = @"1.25X";
            break;
        case AliyunVodPlayerViewPlaySpeedOnePointFive:
            playSpeedString = @"1.5X";
            break;
        case AliyunVodPlayerViewPlaySpeedTwo:
            playSpeedString = @"2X";
            break;
        default:
            playSpeedString = @"0.8X";
            break;
    }
    return playSpeedString;
}

- (void)AliyunPVControlLayer:(AliyunPVControlLayer *)controlLayer progressViewValueChanged:(float)value {
    
    [controlLayer.qualityBtn setEnabled:NO];
    
    double currentVideoDuration = self.aliPlayer.duration;
    double seekTime = 0;
    seekTime = value * currentVideoDuration;
    
    if (seekTime < 0) {
        seekTime = 0;
    }
    if (seekTime > currentVideoDuration) {
        seekTime = currentVideoDuration;
    }
    
    [self.seekView onPanFinished];
    [self.aliPlayer seekToTime:seekTime];
}

- (void)AliyunPVControlLayer:(AliyunPVControlLayer *)controlLayer qualityListViewOnItemClick:(int)index{
    //暂停状态切换清晰度
    if(self.aliPlayer.playerState == AliyunVodPlayerStatePause){
        [self.aliPlayer resume];;
    }
    //切换清晰度
    [self.aliPlayer setQuality:index];
    
    NSArray *ary = [AliyunPVUtil allQualitys];
    [controlLayer.qualityBtn setTitle:ary[index] forState:UIControlStateNormal];
    
    //选中切换
    [controlLayer.qualityListView setCurrentQuality:index];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:onVideoQualityChanged:)]) {
        [self.delegate aliyunVodPlayerView:self onVideoQualityChanged:index];
    }
}

- (void)AliyunPVControlLayer:(AliyunPVControlLayer *)controlLayer qualityListViewOnDefinitionClick:(NSString*)videoDefinition {
    //暂停状态切换清晰度
    if(self.aliPlayer.playerState == AliyunVodPlayerStatePause){
        [self.aliPlayer resume];;
    }
    
    [self.aliPlayer setVideoDefinition:videoDefinition];
    
    [controlLayer.qualityBtn setTitle:videoDefinition forState:UIControlStateNormal];
    //选中切换
    [controlLayer.qualityListView setCurrentDefinition:videoDefinition];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:onVideoDefinitionChanged:)]) {
        [self.delegate aliyunVodPlayerView:self onVideoDefinitionChanged:videoDefinition];
    }
}

#pragma mark - popdelegate
- (void)onErrorViewClickWithType:(NSString *)typeString{
    self.popLayer.hidden = YES;
    if ([typeString isEqualToString:ALPV_TYPE_PLAY_REPLAY]) {
        //重播
        [self.aliPlayer replay];
    }else if ([typeString isEqualToString:ALPV_TYPE_PLAY_RETRY]){
        [self stop];
        if (self.aliPlayer.autoPlay == NO) {
            self.aliPlayer.autoPlay = YES;
        }
        //重试播放
        [self vodPlayerViewRetryPlayWithPlayMethod:self.playMethod];
        //记录事件和时间
        self.isRerty = YES;
        self.saveCurrentTime = self.aliPlayer.currentTime;
    }else if ([typeString isEqualToString:ALPV_TYPE_PLAYER_PAUSE]){
        if (self.aliPlayer.playerState == AliyunVodPlayerStatePause){
            [self.aliPlayer resume];
        } else {
            if (self.aliPlayer.autoPlay == NO) {
                self.aliPlayer.autoPlay = YES;
            }
            //播放完成、超时、断网 ，重新使用参数重新播放。
            [self updatePlayDataReplayWithPlayMethod:self.playMethod];
        }
    }
}

/*
 * 功能 ：播放器重试播放
 * 参数 ：playMethod 播放方式
 */
- (void)vodPlayerViewRetryPlayWithPlayMethod:(AliyunVodPlayerViewPlayMethod) playMethod{
    switch (playMethod) {
        case AliyunVodPlayerViewPlayMethodUrl:
        {
            [self playViewPrepareWithURL:self.tempUrl];
        }
            break;
        case AliyunVodPlayerViewPlayMethodMPS:
        {
            [self playViewPrepareWithVid:self.mtsVideoId
                                accessId:self.mtsAccessKey
                            accessSecret:self.mtsAccessSecret
                                stsToken:self.mtsStsToken
                                autoInfo:self.mtsAuthInfo
                                  region:self.mtsRegion
                              playDomain:self.mtsPlayDomain
                          mtsHlsUriToken:self.mtsHlsUriToken];
            
        }
            break;
        case AliyunVodPlayerViewPlayMethodPlayAuth:
        {
            [self playViewPrepareWithVid:self.videoId
                                playAuth:self.playAuth];
        }
            break;
        case AliyunVodPlayerViewPlayMethodSTS :
        {
            [self playViewPrepareWithVid:self.stsVideoId
                             accessKeyId:self.stsAccessKeyId
                         accessKeySecret:self.stsAccessSecret
                           securityToken:self.stsStstoken];
        }
            break;
        default:
            break;
    }
}

/*
 * 功能 ：播放器
 * 参数 ：playMethod 播放方式
 */
- (void)updatePlayDataReplayWithPlayMethod:(AliyunVodPlayerViewPlayMethod) playMethod{
    switch (playMethod) {
        case AliyunVodPlayerViewPlayMethodUrl:
        {
            [self.aliPlayer prepareWithURL:self.tempUrl];
        }
            break;
        case AliyunVodPlayerViewPlayMethodMPS:
        {
            [self.aliPlayer prepareWithVid:self.mtsVideoId
                                     accId:self.mtsAccessKey
                                 accSecret:self.mtsAccessSecret
                                  stsToken:self.mtsStsToken
                                  authInfo:self.mtsAuthInfo
                                    region:self.mtsRegion
                                playDomain:self.mtsPlayDomain
                            mtsHlsUriToken:self.mtsHlsUriToken ];
        }
            break;
        case AliyunVodPlayerViewPlayMethodPlayAuth:
        {
            [self.aliPlayer prepareWithVid:self.videoId playAuth:self.playAuth];
        }
            break;
        case AliyunVodPlayerViewPlayMethodSTS:
        {
            [self.aliPlayer prepareWithVid:self.stsVideoId
                               accessKeyId:self.stsAccessKeyId
                           accessKeySecret:self.stsAccessSecret
                             securityToken:self.stsStstoken];
        }
            break;
        default:
            break;
    }
}



- (void)onBackClickedWithAlPVPopLayer:(AliyunPVPopLayer *)popLayer{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onBackViewClickWithAliyunVodPlayerView:)])
        [self.delegate onBackViewClickWithAliyunVodPlayerView:self];
    else {
        [self stop];
    }
}


#pragma mark - timerRun
- (void)timerRun{
    if (self.aliPlayer) {
        double loadedTime = [self.aliPlayer loadedTime];
        float changeLoadTime = (self.currentDuration == 0)?0:(loadedTime / self.currentDuration);
        if (self.mProgressCanUpdate){
            [self.controlLayer.progressView setSecondaryProgress:changeLoadTime];
        }
        
        AliyunVodPlayerState state = (AliyunVodPlayerState)self.aliPlayer.playerState;
        if (state == AliyunVodPlayerStatePlay || state == AliyunVodPlayerStatePause) {
            
            double curTime = self.aliPlayer.currentTime;
            if(self.isRerty){
                [self.aliPlayer seekToTime:self.saveCurrentTime];
                self.isRerty = NO;
                return;
            }
            
            [self.controlLayer updateTimeView:curTime duration:self.aliPlayer.duration state:state];
            if (self.mProgressCanUpdate){
                [self.controlLayer.progressView setProgress:curTime /self.aliPlayer.duration];
            }
        }
    }
}

#pragma mark - 暂不开放该接口
- (void)setBackViewHidden:(BOOL)hidden {
    [self.controlLayer setHidden: hidden];
}
- (void)setTitle:(NSString *)title {
    self.currentMediaTitle = title;
    self.controlLayer.titleView.text = title;
}
#pragma mark - 延时操作
- (void)delayHideControlLayer {
    [self loadAnimation];
    [_controlLayer setHidden:YES];
}
#pragma mark - loading动画
- (void)loadAnimation {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [self.layer addAnimation:animation forKey:nil];
}
- (void)showSeekViewWithOffset:(float)offset {
    AliyunVodPlayerState state = [self playerViewState];
    switch (state) {
        case AliyunVodPlayerStateIdle:
        case AliyunVodPlayerStatePrepared:
        case AliyunVodPlayerStateError:
        case AliyunVodPlayerStateStop:
            return;
        default:
            break;
    }
    if (self.printLog) {
        NSLog(@"AliyunVodPlayerView seekPopView input offset = %f", offset);
    }
    BOOL right = NO;
    if (offset >= 0) {
        right = YES;
    }
    float x =  offset;
    double duration = self.aliPlayer.duration;
    float width = self.controlLayer.bounds.size.width;
    double seekTime = self.aliPlayer.currentTime;
    if (self.printLog) {
        NSLog(@"curtime time = %f total time = %f", seekTime, duration);
    }
    if (duration > 3600) {
        seekTime += x / width * duration * 0.1;
    } else if (1800 < duration && duration <= 3600) {
        seekTime += x / width * duration * 0.2;
    } else if (600 < duration && duration <= 1800) {
        seekTime += x / width * duration * 0.34;
    } else if (240 < duration && duration <= 600) {
        seekTime += x / width * duration * 0.5;
    } else {
        seekTime += x / width * duration;
    }
    if (seekTime < 0) {
        seekTime = 0;
    } else if (seekTime > duration) {
        seekTime = duration;
    }
    if (self.printLog) {
        NSLog(@"AliyunVodPlayerView seekPopView seekTime = %f, format time = %@", seekTime, [AliyunPVUtil timeformatFromSeconds:seekTime]);
    }
    if (![self.seekView isShowing]) {
        [self.seekView showWithParentView:self];
    }
    [self.seekView setTime:seekTime direction:right];
    
    [self.controlLayer.progressView movingTo:seekTime/duration ];
}
- (void)seekPopupViewValueChanged:(float)value {
//    self.mProgressCanUpdate = NO;
    if ([_controlLayer isHidden]) {
        [self.aliPlayer seekToTime:value];
    }
}

//取消屏幕锁定旋转状态
- (void)unlockScreen{
    //弹出错误窗口时 取消锁屏。
    if (self.delegate &&[self.delegate respondsToSelector:@selector(aliyunVodPlayerView:lockScreen:)]) {
        if (self.isScreenLocked == YES||self.fixedPortrait) {
            
            //弹出错误窗口时 取消锁屏。
            [self.controlLayer cancelLockScreenWithIsScreenLocked:self.isScreenLocked fixedPortrait:self.fixedPortrait];
            //代理方法
            [self.delegate aliyunVodPlayerView:self lockScreen:NO];
            self.controlLayer.lockBtn.selected = NO;
            self.isScreenLocked = NO;
            [self.displayLayer setEnableGesture: YES];
        }
    }
}

/**
 * 功能：声音调节,调用系统MPVolumeView类实现，并非视频声音;volume(0~1.0)
 */
- (void)setVolume:(float)volume{
    [self.aliPlayer setVolume:volume];
}

/**
 * 功能：亮度,调用brightness系统属性，brightness(0~1.0)
 */
- (void)setBrightness :(float)brightness{
    [self.aliPlayer setBrightness:brightness];
}

#pragma mark - 版本号
- (NSString*) getSDKVersion{
    return [AliyunPVUtil getSDKVersion];
}

/**
 * 功能：
 * 参数：设置渲染视图角度
 */
-(void) setRenderRotate:(RenderRotate)rotate{
    [self.aliPlayer setRenderRotate:rotate];
}

/**
 * 功能：
 * 参数：设置渲染镜像
 */
-(void) setRenderMirrorMode:(RenderMirrorMode)mirrorMode{
    [self.aliPlayer setRenderMirrorMode:mirrorMode];
}

/**
 * 功能：
 * 参数：block:音频数据回调
 *
 */
-(void) getAudioData:(void (^)(NSData *data))block{
    [self.aliPlayer getAudioData:block];
}

#pragma mark - 设置提示语
-(void)setPlayFinishDescribe:(NSString *)des{
    [AliyunPVUtil setPlayFinishTips:des];
}
-(void)setNetTimeOutDescribe:(NSString *)des{
    [AliyunPVUtil setNetworkTimeoutTips:des];
}
-(void)setNoNetDescribe:(NSString *)des{
    [AliyunPVUtil setNetworkUnreachableTips:des];
}
-(void)setLoaddataErrorDescribe:(NSString *)des{
    [AliyunPVUtil setLoadingDataErrorTips:des];
}
-(void)setUseWanNetDescribe:(NSString *)des{
    [AliyunPVUtil setSwitchToMobileNetworkTips:des];
}

#pragma mark - public method
/*
 * 功能 ： 接收onEventCallback回调时，根据当前播放器事件更新UI播放器UI数据
 * 参数：
 */
- (void)updateVodPlayViewDataWithEvent:(AliyunVodPlayerEvent)event vodPlayer:(AliyunVodPlayer *)vodPlayer{
    switch (event) {
        case AliyunVodPlayerEventPrepareDone:
        {
            //关闭loading动画
            [_loadingView dismiss];
            
            //保存获取的的播放器信息 ，需要优化。
            self.currentDuration = vodPlayer.duration;
            if(self.isRerty ){
                self.controlLayer.currentTime = self.saveCurrentTime;
            }else{
                self.controlLayer.currentTime = vodPlayer.currentTime;
            }
            
            //更新controlLayer界面ui数据
            [self updateControlLayerDataWithMediaInfo:[self.aliPlayer getAliyunMediaInfo]];
            
            //sdk内部无计时器，需要时时获取currenttime；后期测试 需要注意 nsrunloopMode
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
            break;
        case  AliyunVodPlayerEventFirstFrame:
        {
            //5秒后窗口隐藏
            if (![self.controlLayer isHidden]) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHideControlLayer) object:nil];
                [self performSelector:@selector(delayHideControlLayer) withObject:nil afterDelay:4];
            }
            self.controlLayer.playMethod = self.playMethod;
            if((int)self.aliPlayer.quality >= 0){
                [self.controlLayer.qualityListView setCurrentQuality:self.aliPlayer.quality];
            }else{
                [self.controlLayer.qualityListView setCurrentDefinition:self.aliPlayer.videoDefinition];
            }
            
            //隐藏封面
            if (self.coverImageView) {
                self.coverImageView.hidden = YES;
            }
            //开启常亮状态
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        }
            break;
        case AliyunVodPlayerEventPlay:
            break;
        case AliyunVodPlayerEventPause:
        {
            //播放器暂停回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:onPause:)]) {
                NSTimeInterval time = vodPlayer.currentTime;
                [self.delegate aliyunVodPlayerView:self onPause:time];
            }
        }
            break;
        case AliyunVodPlayerEventFinish:{
            //播放完成回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(onFinishWithAliyunVodPlayerView:)]) {
                [self.delegate onFinishWithAliyunVodPlayerView:self];
            }
            //播放完成
            [self.popLayer showPopViewWithCode:AliyunPVPlayerPopCodePlayFinish popMsg:nil];
            [self unlockScreen];
        }
            break;
        case AliyunVodPlayerEventStop: {
            //stop 回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:onStop:)]) {
                NSTimeInterval time = vodPlayer.currentTime;
                [self.delegate aliyunVodPlayerView:self onStop:time];
            }
            //取消常亮状态
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
            break;
        case AliyunVodPlayerEventSeekDone :{
            [self.controlLayer.qualityBtn setEnabled:YES];
            self.mProgressCanUpdate = YES;
            //seekDone结束时，设置thumb状态
            [self.controlLayer.progressView setUserInteractionEnabled:YES];
            [self.controlLayer.progressView setTrackThumbState:AliyunPVTrackThumbStateIdle];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:onSeekDone:)]) {
                [self.delegate aliyunVodPlayerView:self onSeekDone:vodPlayer.currentTime];
            }
        }
            break;
        case AliyunVodPlayerEventBeginLoading: {
            //展示loading动画
            [_loadingView show];
        }
            break;
        case AliyunVodPlayerEventEndLoading: {
            //关闭loading动画
            [_loadingView dismiss];
        }
            break;
        default:
            {
                [self.controlLayer.qualityBtn setEnabled:YES];
            }
            break;
    }
}

//更新封面图片
- (void)updateCoverWithCoverUrl:(NSString *)coverUrl{
    //以用户设置的为先，标题和封面,用户在控制台设置coverurl地址
    if (coverUrl) {
        if (self.coverImageView) {
            if (!self.coverImageView.hidden) {
                self.coverImageView.hidden = NO;
            }
            self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.coverImageView.image = [UIImage imageWithData:data];
                });
            });
        }
    }
}

//更新controlLayer界面ui数据
- (void)updateControlLayerDataWithMediaInfo:(AliyunVodPlayerVideo *)mediaInfo{
    
    AliyunPVVideo *videoInfo = [[AliyunPVVideo alloc] initWithPlayerVideo:mediaInfo];
    self.controlLayer.controlLayerVideo = videoInfo;
    
    //清晰度列表UI，清晰度列表数据
    self.controlLayer.playMethod = self.playMethod;
    [self.controlLayer.qualityListView setAllSupportQualitys:mediaInfo.allSupportQualitys];
    
    //以用户设置的为先，标题和封面,用户在控制台设置coverurl地址
    if (!self.coverUrl) {
        [self updateCoverWithCoverUrl:mediaInfo.coverUrl];
    }
    
    //标题, 未播放URL 做备用判定
    if (!self.currentMediaTitle) {
        if (mediaInfo.title && ![mediaInfo.title isEqualToString:@""]) {
            [self setTitle:mediaInfo.title];
        }else if(self.tempUrl){
            NSArray *ary = [[self.tempUrl absoluteString] componentsSeparatedByString:@"/"];
            [self setTitle:ary.lastObject];
        }
    }else{
        self.controlLayer.titleView.text = self.currentMediaTitle;
    }
    
    //清晰度列表
    NSArray *ary = [AliyunPVUtil allQualitys];
    if (mediaInfo) {
        if ((int)mediaInfo.videoQuality < 0) {
            [self.controlLayer.qualityBtn setTitle:mediaInfo.videoDefinition forState:UIControlStateNormal];
        }else{
            [self.controlLayer.qualityBtn setTitle:ary[mediaInfo.videoQuality] forState:UIControlStateNormal];
        }
        self.controlLayer.qualityBtn.hidden = NO;
    }
}

//根据错误信息，展示popLayer界面
- (void)showPopLayerWithErrorModel:(AliyunPlayerVideoErrorModel*)errorModel{
    //4.16 #14836944 ，错误后 seek，禁止了 runtime更新进度和清晰度按钮 行为。
    self.mProgressCanUpdate = YES;
    [self.controlLayer.qualityBtn setEnabled:YES];
    [self.seekView dismiss];
    
    
    switch (errorModel.errorCode) {
        case ALIVC_SUCCESS:
            break;
        case ALIVC_ERR_LOADING_TIMEOUT:
        {
            [self.popLayer showPopViewWithCode:    AliyunPVPlayerPopCodeNetworkTimeOutError popMsg:nil];
            [self unlockScreen];
        }
            break;
        case ALIVC_ERR_DOWNLOAD_SERVER_INVALID_PARAM:
        case ALIVC_ERR_REQUEST_DATA_ERROR:
        case ALIVC_ERR_INVALID_INPUTFILE:
        case ALIVC_ERR_INVALID_PARAM:
        case ALIVC_ERR_AUTH_EXPIRED:
        case ALIVC_ERR_NO_INPUTFILE:
        case ALIVC_ERR_VIDEO_FORMAT_UNSUPORTED:
        case ALIVC_ERR_PLAYAUTH_PARSE_FAILED:
        case ALIVC_ERR_DECODE_FAILED:
        case ALIVC_ERR_NO_SUPPORT_CODEC:
        case ALIVC_ERR_REQUEST_ERROR:
        case ALIVC_ERR_QEQUEST_SAAS_SERVER_ERROR:
        case ALIVC_ERR_QEQUEST_MTS_SERVER_ERROR:
        case ALIVC_ERR_SERVER_INVALID_PARAM:
        case ALIVC_ERR_NO_VIEW:
        case ALIVC_ERR_NO_MEMORY:
        case ALIVC_ERR_ILLEGALSTATUS:
        {
            [self.popLayer showPopViewWithCode:AliyunPVPlayerPopCodeServerError popMsg:errorModel.errorMsg];
            [self unlockScreen];
        }
            break;
        case ALIVC_ERR_READ_DATA_FAILED:
        {
            [self.popLayer showPopViewWithCode:AliyunPVPlayerPopCodeLoadDataError popMsg:nil];
            [self unlockScreen];
        }
            break;
        default:
            break;
    }
    
}

//倍速播放界面入场、退场动画
//倍速播放界面 入场动画
- (void)showSpeedViewMoveInAnimateWithPlaySpeedView:(AliyunPVPlaySpeedView *)playSpeedView{
    CGRect frame = playSpeedView.frame;
    frame.origin.x = self.aliyun_width;
    playSpeedView.frame = frame;
    playSpeedView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        if ([AliyunPVUtil isInterfaceOrientationPortrait]) {
            CGRect frame = playSpeedView.frame;
            frame.origin.x = 0;
            playSpeedView.frame = frame;
        }else{
            CGRect frame = playSpeedView.frame;
            frame.origin.x = self.aliyun_width-310;
            playSpeedView.frame = frame;
        }
    } completion:^(BOOL finished) {
    }];
}

//倍速播放界面  退场动画
//隐藏右侧菜单栏
- (void)hiddenPlaySpeedView:(AliyunPVPlaySpeedView *)playSpeedView completion:(void(^)(BOOL finished))completiton {
    [UIView animateWithDuration:0.3 animations:^{
        if ([AliyunPVUtil isInterfaceOrientationPortrait]) {
            CGRect frame = playSpeedView.frame;
            frame.origin.x = playSpeedView.aliyun_width;
            playSpeedView.frame = frame;
        }else{
            CGRect frame = playSpeedView.frame;
            frame.origin.x = SCREEN_WIDTH;
            playSpeedView.frame = frame;
        }
    } completion:^(BOOL finished) {
        if (completiton) {
            completiton(finished);
        }
        playSpeedView.hidden = YES;
    }];
}

//倍速播放界面 选中选择倍速值后退出
- (void)showSpeedViewSelectedPushInAnimateWithPlaySpeedView:(AliyunPVPlaySpeedView *)playSpeedView playSpeed:(AliyunVodPlayerViewPlaySpeed)playSpeed{
    NSBundle *resourceBundle = [AliyunPVUtil languageBundle];
    [self hiddenPlaySpeedView:playSpeedView completion:^(BOOL finished) {
        NSString *title = [NSString stringWithFormat:@"%@ %@ %@",
                           NSLocalizedStringFromTableInBundle(@"the current video has swiched to", nil, resourceBundle, nil),
                           NSLocalizedStringFromTableInBundle([self playSpeedGetString:playSpeed], nil, resourceBundle, nil),
                           NSLocalizedStringFromTableInBundle(@"speed rate", nil, resourceBundle, nil)];
        [self showToast:title];
    }];
}
- (void)showToast:(NSString *)msg {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14.0f];
    label.text = msg;
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],};
    CGSize textSize = [msg boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;;
    label.frame = CGRectMake((self.aliyun_width-textSize.width-10)/2, self.aliyun_height-75, textSize.width+10, 40);
    [self addSubview:label];
    [self bringSubviewToFront:label];
    [UIView animateWithDuration:2 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}


@end
