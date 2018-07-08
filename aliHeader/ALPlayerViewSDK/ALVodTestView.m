//
//  ALVodTestView.m
//  AliyunVodPlayerViewSDK
//
//  Created by 王凯 on 2017/9/13.
//  Copyright © 2017年 SMY. All rights reserved.
//

#import "ALVodTestView.h"

#import "ALPVUtil.h"
#import "ALPVPixelUtil.h"

#import "ALPVErrorView.h"
#import "ALPVPrivateDefine.h"
#import "ALPVLoadingView.h"
#import "ALPVVideo.h"
#import "ALPVReachability.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AliyunVodPlayerSDK/AliyunVodPlayer.h>
#import "ALPVSeekPopupView.h"

#import "AliyunVodTopView.h"
#import "AliyunVodBottomView.h"




@interface ALVodTestView()<UIGestureRecognizerDelegate,AliyunVodTopViewDelegate,ALPVSeekPopupViewDelegate,AliyunVodBottomViewDelegate,ALVodTestViewDelegate>{
    
    CGPoint _currentPoint;
    float _systemVolume;
    float _lastTranslation;
    float _saveCurrentTime;
    BOOL _isChangeValue;
    UITapGestureRecognizer *_tapGesture;
    UITapGestureRecognizer *_doubleTapGesture;
    
    
    
    UIImageView *blightView;// 明暗提示图
    UIImageView *voiceView; // 音量提示图
    UIProgressView *blightPtogress; // 明暗提示al_fingerGesture_brightness
    UIProgressView *volumeProgress; // 音量提示
    
    
    
    
}
//sdk
@property (nonatomic, strong) AliyunVodPlayer *playerManager;
@property (nonatomic, strong) ALPVReachability *reachability;

//重试
@property (nonatomic, assign)AliyunVodPlayerUserMethod userMethod;
@property (nonatomic, copy)NSString *vidioId;
@property (nonatomic, copy)NSString *playAuth;
@property (nonatomic, copy)NSURL *tempUrl;
@property (nonatomic, strong)NSTimer *timer;


@property (nonatomic, assign) CGRect             saveFrame;



@property (nonatomic, strong) UIView *displayLayer;
@property (nonatomic, strong) ALPVLoadingView   *loadingView;
@property (nonatomic, strong) ALPVSeekPopupView *seekView;
@property (nonatomic, strong) AliyunVodTopView *topView;
@property (nonatomic, strong) AliyunVodBottomView *bottomView;
//@property (nonatomic, strong) UIView     *popLayer;
@end

@implementation ALVodTestView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andSkin:AliyunVodPlayerViewSkinBlue];
}

- (instancetype)initWithFrame:(CGRect)frame andSkin:(AliyunVodPlayerViewSkin)skin {
    self = [super initWithFrame:frame];
    if (self) {
        self.saveFrame = frame;
        if ([ALPVUtil isInterfaceOrientationPortrait]) {
            
        } else {
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }
        self.backgroundColor = [UIColor blackColor];
        
        //displayLayer 是 playerManager 容器
        self.displayLayer  = [[UIView alloc] init];
        self.playerManager = [[AliyunVodPlayer alloc] init];
        self.playerManager.delegate = self;
        [self.displayLayer addSubview:self.playerManager.playerView];
        [self addSubview:self.displayLayer];
        
        
        //top
        self.topView = [[AliyunVodTopView alloc] init];
        self.topView.topViewDelegate = self;
        self.topView.skin = skin;
        [self addSubview:self.topView];
        
        self.bottomView = [[AliyunVodBottomView alloc] init];
        self.bottomView.bottomViewDelegate = self;
        self.bottomView.skin = skin;
        [self addSubview:self.bottomView];
        
        //菊花。。。
        self.loadingView = [[ALPVLoadingView alloc] init];
        [self addSubview:self.loadingView];
        
        self.seekView = [[ALPVSeekPopupView alloc] init];
        [self.seekView setDelegate:self];
        
        [self makeBlightAndVolumeView];
        
        // 添加滑动手势
        UIPanGestureRecognizer  *panGesture=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDown:)];
        panGesture.delegate=self;
        [self addGestureRecognizer:panGesture];
        
        //屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil
         ];
        
        self.reachability = [ALPVReachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        //网络状态判定
        switch ([self.reachability currentReachabilityStatus]) {
            case ALPVNetworkNotReachable: {
                
                //                [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodeNoNet errorMsg:nil];
                
            }
                break;
            case ALPVNetworkReachableViaWiFi:
                
                break;
            case ALPVNetworkReachableViaWWAN: {
                
                if (self.playerManager.autoPlay) {
                    self.playerManager.autoPlay = NO;
                    
                }
                [self.playerManager pause];
                //                [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodeUseWANNet errorMsg:nil];
                
            }
                break;
            default:
                break;
        }
        
        
    }
    
    return  self;
    
}

#pragma mark - GestureRecognizer
- (void)tap {
//    if ([[self.controlLayer subviews] containsObject:self.controlLayer.qualityListView]) {
//        [self.controlLayer hideQualityListView:YES];
//    }
    
    [self loadAnimation];
//    [self.controlLayer setHidden:![_controlLayer isHidden]];
    [self.topView setHidden:!self.topView.isHidden];
    [self.bottomView setHidden:!self.bottomView.isHidden];
    
    if (![self.topView isHidden]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHideControlLayer) object:nil];
        [self performSelector:@selector(delayHideControlLayer) withObject:nil afterDelay:5];
    }
}

- (void)doubleTap {
    AliyunVodPlayerViewState state = [self playerViewState];
    if (state == AliyunVodPlayerStatePlay) {
        [self pause];
    } else if (state == AliyunVodPlayerStatePause) {
        [self resume];
    }
}

-(void)makeBlightAndVolumeView{
    
    UIImage *blightImage = [ALPVUtil imageWithNameInBundle:@"al_fingerGesture_brightness"];
    UIImage *voiceImage = [ALPVUtil imageWithNameInBundle:@"al_fingerGesture_voice@2x"];
    
    blightView =[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_HEIGHT-150)/2,(SCREEN_WIDTH-150)/2, 75, 75)];
    blightView.image =blightImage;
    blightView.alpha=0.0;
    blightView.backgroundColor =[UIColor whiteColor];
    [self addSubview:blightView];
    
    blightView.center = CGPointMake(self.width / 2, self.height / 2);
    voiceView =[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_HEIGHT-150)/2,(SCREEN_WIDTH-150)/2, 75, 75)];
    voiceView.image =voiceImage;
    voiceView.alpha=0.0;
    voiceView.backgroundColor =[UIColor whiteColor];
    //    [self addSubview:voiceView];
    
    voiceView.center =  CGPointMake(self.width / 2, self.height / 2);
    
    //    blightPtogress =[[UIProgressView alloc] initWithFrame:CGRectMake(20,blightView.frame.size.height-20,blightView.frame.size.width-40,20)];
    //    blightPtogress.backgroundColor = [UIColor clearColor];
    //    blightPtogress.trackTintColor =[UIColor blackColor];
    //    blightPtogress.progressTintColor =[UIColor whiteColor];
    //    blightPtogress.progress =0.5f;
    //    // 改变进度条的粗细
    //    blightPtogress.transform = CGAffineTransformMakeScale(1.0f,2.0f);
    //    blightPtogress.progressViewStyle=UIProgressViewStyleBar;
    //    [blightView addSubview:blightPtogress];
    //
    //    volumeProgress =[[UIProgressView alloc] initWithFrame:CGRectMake(20,blightView.frame.size.height-20,blightView.frame.size.width-40,20)];
    //    volumeProgress.backgroundColor = [UIColor clearColor];
    //    volumeProgress.trackTintColor =[UIColor blackColor];
    //    volumeProgress.progress =0.5f;
    //    volumeProgress.transform = CGAffineTransformMakeScale(1.0f,2.0f);
    //    volumeProgress.progressViewStyle=UIProgressViewStyleBar;
    //    volumeProgress.progressTintColor =[UIColor whiteColor];
    //    [voiceView addSubview:volumeProgress];
}

#pragma mark - 屏幕旋转
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation{
    UIDevice *device = [UIDevice currentDevice] ;
    
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortraitUpsideDown:
            break;
            
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            @synchronized (self) {
                self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            }
            break;
        case UIDeviceOrientationPortrait:
            @synchronized (self) {
                self.frame = self.saveFrame;
            }
            break;
        default:
            if (_pringtLog) {
                NSLog(@"无法辨识");
            }
            break;
    }
}

#pragma mark - dealloc
- (void)dealloc {
    
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [self.playerManager releasePlayer];
    self.playerManager = nil;
    
}


#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.displayLayer.frame = self.bounds;
    self.playerManager.playerView.frame = self.displayLayer.bounds;
    self.topView.frame = CGRectMake(0, 0, self.width, 44);
    self.bottomView.frame =  CGRectMake(0, self.height-44, self.width, 44);
    
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    
    float loadingViewWidth = [ALPVPixelUtil convertPixelToPoint:ALPV_PX_LOADING_VIEW_WIDTH];
    float loadingViewHeight =  [ALPVPixelUtil convertPixelToPoint:ALPV_PX_LOADING_VIEW_HEIGHT];
    float x = (self.bounds.size.width -  loadingViewWidth) / 2;
    float y = (self.bounds.size.height - loadingViewHeight) / 2;
    self.loadingView.frame = CGRectMake(x, y, loadingViewWidth, loadingViewHeight);
    
    self.seekView.center = CGPointMake(width / 2, height / 2);
}


- (void)tapVideoViewEvent{
    
}

#pragma mark - 手势代理 解决手势冲突问题,不要忘记添加代理delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch{
    if([touch.view isKindOfClass:[UISlider class]]){
        return NO;
    }else{
        return YES;
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    _currentPoint = [[touches anyObject] locationInView:self];
    
    UITouch *touch = [touches anyObject];
    NSInteger count = [touch tapCount];
    //问题:当你双击的时候,会调用单击的方法.
    
    //重点:双击事件取消单击
    if (count == 1) {
        [self performSelector:@selector(tap) withObject:nil afterDelay:0.3];
    }
    if (count == 2) {
        //取消单击
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tap) object:nil];
        [self doubleTap];
    }
    
}

-(void)panGestureDown:(UIPanGestureRecognizer*)sender{
    
    CGPoint point= [sender locationInView:self];
    CGPoint tranPoint=[sender translationInView:self];
    
    typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
        UIPanGestureRecognizerDirectionUndefined,
        UIPanGestureRecognizerDirectionUp,
        UIPanGestureRecognizerDirectionDown,
        UIPanGestureRecognizerDirectionLeft,
        UIPanGestureRecognizerDirectionRight
    };
    static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            
            _lastTranslation = 0;
            _saveCurrentTime = [self currentTime];
            
            
            if (direction == UIPanGestureRecognizerDirectionUndefined) {
                CGPoint velocity = [sender velocityInView:self];
                
                BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
                if (isVerticalGesture) {
                    if (velocity.y > 0) {
                        direction = UIPanGestureRecognizerDirectionDown;
                    } else {
                        direction = UIPanGestureRecognizerDirectionUp;
                    }
                }
                else {
                    if (velocity.x > 0) {
                        direction = UIPanGestureRecognizerDirectionRight;
                    } else {
                        direction = UIPanGestureRecognizerDirectionLeft;
                    }
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            switch (direction) {
                case UIPanGestureRecognizerDirectionUp: {
                    
                    float dy = point.y - _currentPoint.y;
                    int index = (int)dy;
                    // 左侧 上下改变亮度
                    if(_currentPoint.x <self.frame.size.width/2){
                        blightView.alpha =1.0f;
                        if(index >0){
                            [UIScreen mainScreen].brightness = [UIScreen mainScreen].brightness- 0.01;
                        }else{
                            [UIScreen mainScreen].brightness = [UIScreen mainScreen].brightness+ 0.01;
                        }
                        blightPtogress.progress =[UIScreen mainScreen].brightness;
                    }else{// 右侧上下改变声音
                        voiceView.alpha =1.0f;
                        if(index>0){
                            [self setVolumeDown];
                        }else{
                            [self setVolumeUp];
                        }
                        volumeProgress.progress =_systemVolume;
                    }
                    break;
                }
                case UIPanGestureRecognizerDirectionDown: {
                    
                    float dy = point.y - _currentPoint.y;
                    int index = (int)dy;
                    // 左侧 上下改变亮度
                    if(_currentPoint.x <self.frame.size.width/2){
                        blightView.alpha =1.0f;
                        if(index >0){
                            [UIScreen mainScreen].brightness = [UIScreen mainScreen].brightness- 0.01;
                        }else{
                            [UIScreen mainScreen].brightness = [UIScreen mainScreen].brightness+ 0.01;
                        }
                        blightPtogress.progress =[UIScreen mainScreen].brightness;
                    }else{// 右侧上下改变声音
                        voiceView.alpha =1.0f;
                        if(index>0){
                            [self setVolumeDown];
                        }else{
                            [self setVolumeUp];
                        }
                        volumeProgress.progress =_systemVolume;
                    }
                    break;
                }
                case UIPanGestureRecognizerDirectionLeft:
                case UIPanGestureRecognizerDirectionRight: {
                    [self showSeekViewWithOffset:tranPoint.x];
                    break;
                }
                default: {
                    break;
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self.timer setFireDate:[NSDate distantFuture]];
            if (![_loadingView isShown]) {
                [_loadingView show];
            }
            
            _lastTranslation = 0;
            [self.seekView onPanEnd];
            //            [self.playerManager seekToTime:_origional*self.playerManager.duration];
            
            direction = UIPanGestureRecognizerDirectionUndefined;
            
            [UIView animateWithDuration:0.5f animations:^{
                blightView.alpha =0.0f;
                voiceView.alpha=0.0f;
            }];
            
            break;
        }
        default:
            break;
    }
}

- (void)showSeekViewWithOffset:(float)offset {
    
    AliyunVodPlayerViewState state = (AliyunVodPlayerViewState)self.playerManager.state;
    
    switch (state) {
        case AliyunVodPlayerViewStateIdle:
        case AliyunVodPlayerViewStatePreparing:
        case AliyunVodPlayerViewStatePrepared:
        case AliyunVodPlayerViewStateError:
        case AliyunVodPlayerViewStateStop: {
            return;
        default:
            break;
        }
    }
    
    NSLog(@"AliyunVodPlayerView seekPopView input offset = %f", offset);
    
    BOOL right = NO;
    
    if (offset >= 0) {
        right = YES;
    }
    float x =   offset;
    _lastTranslation = x;
    double duration = self.playerManager.duration;
    float width = self.bounds.size.width;
    double seekTime = _saveCurrentTime;
    NSLog(@"current time = %f total time = %f", seekTime, duration);
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
    
    NSLog(@"AliyunVodPlayerView seekPopView seekTime = %f, format time = %@", seekTime, [ALPVUtil timeformatFromSeconds:seekTime]);
    
    if (![self.seekView isShown]) {
        [self.seekView showWithParentView:self];
    }
    [self.seekView setTime:seekTime direction:right];
}

-(void)setVolumeUp
{
    _systemVolume = _systemVolume+0.01;
    [self.playerManager setVolume:_systemVolume];
}
-(void)setVolumeDown{
    
    _systemVolume = _systemVolume-0.01;
    [self.playerManager setVolume:_systemVolume];
}


#pragma mark - topdelegate
-(void)aliyunVodTopView:(AliyunVodTopView *)topView onBackViewClick:(UIButton *)button{
    NSLog(@"topview back");
    // 只要切换屏幕 分辨率列表就隐藏
    //    [controlLayer.qualityListView removeFromSuperview];
    [self releasePlayer];
    if (![ALPVUtil isInterfaceOrientationPortrait]) {
        [ALPVUtil setFullOrHalfScreen];
    } else {
        
        [self.delegate onBackViewClickWithAliyunVodPlayerView:self];
    }
    
}


#pragma mark - bottomDelegate
- (void)aliyunVodBottomView:(AliyunVodBottomView *)bottomView dragProgressSliderValue:(float)progressValue{
    
    double currentVideoDuration = self.playerManager.duration;
    double seekTime = 0;
    seekTime = progressValue * currentVideoDuration;
    
    if (seekTime < 0) {
        seekTime = 0;
    }
    if (seekTime > currentVideoDuration) {
        seekTime = currentVideoDuration;
    }
    
    [self.playerManager seekToTime:seekTime];
    
    
}
- (void)aliyunVodBottomView:(AliyunVodBottomView *)bottomView buttonClicked:(NSInteger)buttonTag{
    switch (buttonTag) {
        case ALButtonEventPlay:
        {
            switch ([self.reachability currentReachabilityStatus]) {
                case ALPVNetworkNotReachable: {
                    //                        [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodeNoNet errorMsg:nil];
                }
                    break;
                case ALPVNetworkReachableViaWiFi:
                    
                    break;
                case ALPVNetworkReachableViaWWAN: {
                    
                    if (self.playerManager.autoPlay) {
                        self.playerManager.autoPlay = NO;
                    }
                    [self.playerManager pause];
                    //                        [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodeUseWANNet errorMsg:nil];
                }
                    break;
                default:
                    break;
            }
            
            AliyunVodPlayerViewState state = [self playerViewState];
            
            if (state == AliyunVodPlayerViewStatePlay ||state == AliyunVodPlayerViewStateResume) {
                
                [self.playerManager pause];
                
            } else if (state == AliyunVodPlayerViewStatePrepared) {
                
                [self.playerManager start];
                
            } else if(state == AliyunVodPlayerViewStatePause){
                
                [self.playerManager resume];
            }
        }
            break;
        case ALButtonEventFullScreen:
        {
            // 只要切换屏幕 分辨率列表就隐藏
            //            [controlLayer.qualityListView removeFromSuperview];
            [ALPVUtil setFullOrHalfScreen];
            
            //            [self setNeedsLayout];
            
        }
            break;
            
        case ALButtonEventQualityList:
        {
            self.bottomView.qualityButton.selected = !self.bottomView.qualityButton.selected;
            if (self.bottomView.qualityButton.selected ) {
                
                //                [controlLayer addSubview:controlLayer.qualityListView];
            } else {
                //                [controlLayer.qualityListView removeFromSuperview];
            }
        }
            break;
            
        default:
            break;
    }
    
}





#pragma mark - playerManager

- (void)setAutoPlay:(BOOL)autoPlay {
    
    [self.playerManager setAutoPlay:autoPlay];
    
}

- (void)setDisplayMode:(AliyunVodPlayerDisplayMode)displayMode
{
    [self.playerManager setDisplayMode:displayMode];
}



- (void)setMuteMode:(BOOL)muteMode{
    [self.playerManager setMuteMode: NO];
}

- (BOOL)isPlaying{
    return [self.playerManager isPlaying];
}

- (NSTimeInterval)duration{
    return  [self.playerManager duration];
}

- (NSTimeInterval)currentTime{
    return  [self.playerManager currentTime];
}

- (NSTimeInterval)loadedTime{
    return  [self.playerManager loadedTime];
}


- (int)videoWidth{
    return [self.playerManager videoWidth];
}

- (int)videoHeight{
    return [self.playerManager videoHeight];
}

- (AliyunVodPlayerVideoQuality)playingQuality{
    return [self.playerManager quality];
}

#pragma mark - timeout
-(void)setTimeout:(int)timeout{
    [self.playerManager setTimeout:timeout];
}

-(int)timeout{
    return  self.playerManager.timeout;
}

-(void)setPringtLog:(BOOL)pringtLog{
    
    [self.playerManager setPringtLog:pringtLog];
    
}

-(BOOL)isPringtLog{
    return self.playerManager.pringtLog;
}

/****************推荐播放方式*******************/
- (void)playViewPrepareWithVid:(NSString *)vid playAuth : (NSString *)playAuth{
    
    self.userMethod = AliyunVodPlayerUserMethodPlayauth;
    self.playAuth = playAuth;
    
    [self.playerManager prepareWithVid:vid playAuth:playAuth];
}


- (void)playViewPrepareWithURL:(NSURL *)url{
    
    self.userMethod = AliyunVodPlayerUserMethodUrl;
    self.tempUrl = url;
    [self.playerManager prepareWithURL:url];
}

/*******************************************/
#pragma mark - playManagerAction
- (void)start {
    
    switch ([self.reachability currentReachabilityStatus]) {
        case ALPVNetworkNotReachable: {
            //            [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodeNoNet errorMsg:nil];
            
        }
            break;
        case ALPVNetworkReachableViaWiFi:
            
            break;
        case ALPVNetworkReachableViaWWAN: {
            
            if (self.playerManager.autoPlay) {
                self.playerManager.autoPlay = NO;
                
            }
            [self.playerManager pause];
            
            //            [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodeUseWANNet errorMsg:nil];
        }
            break;
        default:
            break;
    }
    
    [self.playerManager start];
    
}

- (void)pause{
    [self.playerManager pause];
}

- (void)resume{
    [self.playerManager resume];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:onResume:)]) {
        NSTimeInterval time = self.playerManager.currentTime;//[ALPVCurrentInfo currentPlayTime];
        [self.delegate aliyunVodPlayerView:self onResume:time];
    }
}


- (void)stop {
    [self.playerManager stop];
}

- (void)replay{
    [self.playerManager replay];
}

- (void)releasePlayer {
    
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [self.playerManager releasePlayer];
    self.playerManager = nil;
    
}

- (AliyunVodPlayerViewState)playerViewState {
    return (AliyunVodPlayerViewState)[self.playerManager state];
}


-(AliyunVodPlayerVideo *)getAliyunMediaInfo{
    return  [self.playerManager getAliyunMediaInfo];
}
#pragma mark - playManagerDelegate


-(void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    
    //根据状态设置 controllayer 清晰度按钮 可用？
    //    [self.controlLayer updateViewWithPlayerState:(AliyunVodPlayerViewState)self.playerManager.state];
    //不同播放器状态下 ，进度条和进度按钮 是否可用
    AliyunVodPlayerViewState state = (AliyunVodPlayerViewState)self.playerManager.state;
    
    switch (state) {
        case AliyunVodPlayerViewStateIdle:
        case AliyunVodPlayerViewStatePreparing:
            {
                
                [self.bottomView.qualityButton setUserInteractionEnabled:NO];
                [self.bottomView.progressView setUserInteractionEnabled:NO];
            }
            break;
        case AliyunVodPlayerViewStatePrepared:
            {
                [self.bottomView.playButton setSelected:NO];
                [self.bottomView.qualityButton setUserInteractionEnabled:NO];
                [self.bottomView.progressView setUserInteractionEnabled:NO];
            }
            break;
            
        case AliyunVodPlayerViewStatePlay:
        case AliyunVodPlayerViewStateResume:
        case AliyunVodPlayerViewStateReplay:
        {
            [self.bottomView.qualityButton setUserInteractionEnabled:YES];
            [self.bottomView.playButton setSelected:YES];
            [self.bottomView.progressView setUserInteractionEnabled:YES];
        }
        break;
        case AliyunVodPlayerViewStatePause:
            {
                [self.bottomView.playButton setSelected:NO];
                [self.bottomView.progressView setUserInteractionEnabled:YES];
            }
        case AliyunVodPlayerViewStateLoading:
            [self.bottomView.progressView setUserInteractionEnabled:YES];
            break;
            
        case AliyunVodPlayerViewStateError:{
            [self.bottomView.progressView setUserInteractionEnabled:NO];
        }
            break;
            
        case AliyunVodPlayerViewStateStop:
        case AliyunVodPlayerViewStateFinish:{
            [self.bottomView.playButton setSelected:NO];
            [self.bottomView.progressView setUserInteractionEnabled:NO];
        }
            break;
            
        default:
            [self.bottomView.qualityButton setUserInteractionEnabled:NO];
             [self.bottomView.progressView setUserInteractionEnabled:NO];
            break;
    }
    
    switch (event) {
            
        case AliyunVodPlayerEventPrepareDone: {
        
            AliyunVodPlayerVideo *mediaInfo = [self.playerManager getAliyunMediaInfo];
            
            self.topView.topTitle = mediaInfo.title;
            
            ALPVVideo *v = [[ALPVVideo alloc] initWithPlayerVideo:mediaInfo];
            
            
            //            [self.controlLayer.qualityListView setAllSupportQuality:mediaInfo.allSupportQualitys];
            //            [self.controlLayer.qualityListView needHeight];
            //

            //            NSArray *ary = [ALPVQualityUtil allQuality];
            //
            //            [self.controlLayer.qualityBtn setTitle:ary[mediaInfo.videoQuality] forState:UIControlStateNormal];
            //
        
            //            self.controlLayer.qualityBtn.titleLabel.text = ary[videoModel.videoQuality];
            
            //sdk内部无计时器，需要时时获取currenttime；后期测试 需要注意 nsrunloopMode
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
            
        }
            
            break;
        case AliyunVodPlayerEventPlay: {
            
            //controlLayer 隐藏动画， 可优化
            if (![self.topView isHidden]) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayHideControlLayer) object:nil];
                [self performSelector:@selector(delayHideControlLayer) withObject:nil afterDelay:5];
            }
            //
            //            [self.controlLayer.qualityListView setCurrentQuality:self.playerManager.quality];
            //
        }
            break;
            
        case AliyunVodPlayerEventPause:
        {
            //onPause 回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:onPause:)]) {
                NSTimeInterval time = vodPlayer.currentTime;//[ALPVCurrentInfo currentPlayTime];
                [self.delegate aliyunVodPlayerView:self onPause:time];
            }
        }
            
            break;
            
        case AliyunVodPlayerEventFinish:
        {
            
            //播放完成
            //            [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodePlayFinish errorMsg:nil];
        }
            
            break;
            
        case AliyunVodPlayerEventStop: {
            
            //stop 回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(aliyunVodPlayerView:onStop:)]) {
                NSTimeInterval time = vodPlayer.currentTime;//[ALPVCurrentInfo currentPlayTime];
                [self.delegate aliyunVodPlayerView:self onStop:time];
            }
            
        }
            
            break;
            
        case AliyunVodPlayerEventSeekDone :
        {
            //seekDone结束时，设置小球状态
            //            [self.controlLayer.progressView setUserInteractionEnabled:YES];
            if ([_loadingView isShown]) {
                [_loadingView dismiss];
            }
            if (self.delegate) {
                [self.delegate aliyunVodPlayerView:self onSeekDone:vodPlayer.currentTime];
            }
            
        }
            break;
            
        case AliyunVodPlayerEventBeginLoading: {
            
            //菊花动画。。。
            if (![_loadingView isShown]) {
                [_loadingView show];
            }
        }
            
            break;
        case AliyunVodPlayerEventEndLoading: {
            //菊花动画。。。
            if ([_loadingView isShown]) {
                [_loadingView dismiss];
            }
        }
            break;
            
        default:
            break;
    }
    
}

-(void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(ALPlayerVideoErrorModel *)errorModel{
    
    if ([_loadingView isShown]) {
        [_loadingView dismiss];
    }
    
    //根据状态设置 controllayer 清晰度按钮 可用？
    //    [self.controlLayer updateViewWithPlayerState:(AliyunVodPlayerViewState)vodPlayer.state];
    //不同播放器状态下 ，进度条和进度按钮 是否可用
    //    [self.controlLayer.progressView setUserInteractionEnabled:NO];
    
    //错误信息展示,需要后期查看
    //    ALIVC_SUCCESS                                   = 0,        //无错误
    //    ALIVC_ERR_INVALID_PARAM                         = 4001 ,    //参数非法，请检查XX参数
    //    ALIVC_ERR_AUTH_EXPIRED                          = 4002,     //鉴权过期，请重新获取新的鉴权信息
    //    ALIVC_ERR_INVALID_INPUTFILE                     = 4003,     //无效的输入文件，请检查视频源和路径
    //    ALIVC_ERR_NO_INPUTFILE                          = 4004,     //没有设置视频源或视频地址不存在
    //    ALIVC_ERR_READ_DATA_FAILED                      = 4005,     //读取视频源失败
    //    ALIVC_ERR_LOADING_TIMEOUT                       = 4008,     //视频加载超时，请检查网络状况
    //    ALIVC_ERR_REQUEST_DATA_ERROR                    = 4009,     //请求数据错误
    //    ALIVC_ERR_VIDEO_FORMAT_UNSUPORTED               = 4011,     //视频格式不支持，当前视频格式为XX
    //    ALIVC_ERR_PLAYAUTH_PARSE_FAILED                 = 4012,     //playAuth解析失败
    //    ALIVC_ERR_DECODE_FAILED                         = 4013,     //视频解码失败
    //    ALIVC_ERR_NO_SUPPORT_CODEC                      = 4019,     // 视频编码格式不支持
    //    ALIVC_ERR_UNKNOWN                               = 4400,     //未知错误
    //    ALIVC_ERR_REQUEST_ERROR                         = 4500,     //服务端请求错误
    //    ALIVC_ERR_DATA_ERROR                            = 4501,     //服务器返回数据错误
    //    ALIVC_ERR_QEQUEST_SAAS_SERVER_ERROR             = 4502,     //请求saas服务器错误
    //    ALIVC_ERR_QEQUEST_MTS_SERVER_ERROR              = 4503,     //请求mts服务器错误
    //    ALIVC_ERR__SERVER_INVALID_PARAM                 = 4504,     //服务器返回参数无效，请检查XX参数
    //    ALIVC_ERR_ILLEGALSTATUS                         = 4521,     //非法的播放器状态，当前状态是xx
    //    ALIVC_ERR_NO_VIEW                               = 4022,     //没有设置显示窗口，请先设置播放视图
    //    ALIVC_ERR_NO_MEMORY                             = 4023,     //内存不足
    
    
    if([self.reachability currentReachabilityStatus] != ALPVNetworkReachableViaWiFi){
        return;
    }
    
    switch (errorModel.errorCode) {
        case ALIVC_SUCCESS:
            
            break;
        case ALIVC_ERR_LOADING_TIMEOUT:
            //            [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodeNetTimeOutError errorMsg:nil];
            break;
        case ALIVC_ERR_REQUEST_DATA_ERROR:
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
            //            [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodeServerError errorMsg:errorModel.errorMsg];
        }
            break;
            
        case ALIVC_ERR_READ_DATA_FAILED:
        {
            //            [self.popLayer showErrorViewWithCode:ALPVPlayerErrorCodeLoadDataError errorMsg:nil];
            
        }
            break;
            
        default:
            break;
    }
    
}

-(void)vodPlayer:(AliyunVodPlayer *)vodPlayer willSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    
    //根据状态设置 controllayer 清晰度按钮 可用？
    //    [self.controlLayer updateViewWithPlayerState:(AliyunVodPlayerViewState)vodPlayer.state];
    //不同播放器状态下 ，进度条和进度按钮 是否可用
    AliyunVodPlayerViewState state = (AliyunVodPlayerViewState)vodPlayer.state;
    
    switch (state) {
        case AliyunVodPlayerViewStateIdle:
        case AliyunVodPlayerViewStatePreparing:
        case AliyunVodPlayerViewStatePrepared:
                        [self.bottomView.progressView setUserInteractionEnabled:NO];
            break;
            
        case AliyunVodPlayerViewStatePlay:
        case AliyunVodPlayerViewStatePause:
        case AliyunVodPlayerViewStateReplay:
        case AliyunVodPlayerViewStateResume:
        case AliyunVodPlayerViewStateLoading:
                        [self.bottomView.progressView setUserInteractionEnabled:YES];
            break;
            
        case AliyunVodPlayerViewStateError:{
                        [self.bottomView.progressView setUserInteractionEnabled:NO];
            //            self.controlLayer.progressView.ball.state = ALPVTrackBallStateIdle;
            
        }
            break;
            
        case AliyunVodPlayerViewStateStop:
        case AliyunVodPlayerViewStateFinish:{
                        [self.bottomView.progressView setUserInteractionEnabled:NO];
            //            self.controlLayer.progressView.ball.state = ALPVTrackBallStateIdle;
            
        }
            break;
            
        default:
                        [self.bottomView.progressView setUserInteractionEnabled:NO];
            break;
    }
    
}

-(void)vodPlayer:(AliyunVodPlayer *)vodPlayer didSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    
    //controlLayer 清晰度列表
    //    [self.controlLayer hideQualityListView:YES];
    
}

-(void)vodPlayer:(AliyunVodPlayer *)vodPlayer failSwitchToQuality:(AliyunVodPlayerVideoQuality)quality{
    
}



- (void)delayHideControlLayer {
    [self loadAnimation];
    
    [self.topView setHidden:YES];
    [self.bottomView setHidden:YES];
}

- (void)loadAnimation {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [self.layer addAnimation:animation forKey:nil];
}

#pragma mark - timerRun
- (void)timerRun{
    
    if (_isChangeValue) {
        _isChangeValue = NO;
        return;
    }
    
    NSLog(@"123");
    if (self.playerManager) {
        double loadedTime = [self.playerManager loadedTime];
        AliyunVodPlayerViewState state = (AliyunVodPlayerViewState)self.playerManager.state;
        if (state == AliyunVodPlayerStatePlay ||
            state == AliyunVodPlayerStateReplay ||
            state == AliyunVodPlayerStateResume) {
            
            double currentTime = self.playerManager.currentTime;
            float duration = self.playerManager.duration;
            
            NSString *curTimeStr = [ALPVUtil timeformatFromSeconds:currentTime];
            NSString *totalTimeStr = [ALPVUtil timeformatFromSeconds:duration];
            
            [self.bottomView.rightTimeLabel setText:totalTimeStr];
            [self.bottomView.leftTimeLabel setText:curTimeStr];
            
            NSString *time = [NSString stringWithFormat:@"%@/%@", curTimeStr, totalTimeStr];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:time];
            
            [str addAttribute:NSForegroundColorAttributeName value:ALPV_COLOR_TEXT_NOMAL range:NSMakeRange(0, curTimeStr.length)];
            [str addAttribute:NSForegroundColorAttributeName value:ALPV_COLOR_TEXT_GRAY range:NSMakeRange(curTimeStr.length, curTimeStr.length + 1)];
            
            [self.bottomView.fullScreenTimeLabel setAttributedText:str];
            
            
            [self.bottomView.progressView setLoadTime:loadedTime currentTime:currentTime durationTime:duration];
            
            NSLog(@"currenttime = %f",currentTime);
            
        }
        
    }
}

#pragma mark - seekDelegate
- (void)seekPopupViewValueChanged:(float)value{
    NSLog(@"currenttime value = %f",value);
    _isChangeValue = YES;
    [self.playerManager seekToTime:value];
    [self.timer setFireDate:[NSDate date]];
}

@end
