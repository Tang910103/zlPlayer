//
//  AliyunPlayerMediaUIDemoViewController.m
//  AliyunPlayerMediaDemo
//
//  Created by 王凯 on 2017/8/21.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunPlayerMediaUIDemoViewController.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#import <sys/utsname.h>

#define VIEWSAFEAREAINSETS(view) ({UIEdgeInsets i; if(@available(iOS 11.0, *)) {i = view.safeAreaInsets;} else {i = UIEdgeInsetsZero;} i;})


@interface AliyunPlayerMediaUIDemoViewController ()<AliyunVodPlayerViewDelegate>
//控制锁屏
@property (nonatomic, assign)BOOL isLock;

//每5秒打印，边播边下内容大小，使用时 取消[self fileSize]方法注释。
@property (nonatomic,strong)NSTimer *timer;

//是否隐藏navigationbar
@property (nonatomic,assign)BOOL isStatusHidden;

//进入前后台时，对界面旋转控制
@property (nonatomic, assign)BOOL isBecome;

@end

@implementation AliyunPlayerMediaUIDemoViewController

#pragma mark - viewDidLoad

- (AliyunVodPlayerView *)playerView
{
    if (!_playerView) {
        _playerView = [[AliyunVodPlayerView alloc] initWithFrame:self.view.bounds andSkin:AliyunVodPlayerViewSkinRed];
    }
    return _playerView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.playerView];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat topHeight = 0;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ) {
        width = SCREEN_WIDTH;
        height = SCREEN_WIDTH * 9 / 16.0;
        topHeight = 44;
    }else{
        width = SCREEN_WIDTH;
        height = SCREEN_HEIGHT;
        topHeight = 0;
    }
    /****************UI播放器集成内容**********************/
    
    self.playerView.circlePlay = YES;
    [self.playerView setDelegate:self];
//    [self.playerView setAutoPlay:YES];
    /*
     *备注：isLockScreen 会锁定，播放器界面尺寸。
           isLockPortrait yes：竖屏全屏；no：横屏全屏;
           isLockScreen对isLockPortrait无效。
         - (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView lockScreen:(BOOL)isLockScreen此方法在isLockPortrait==yes时，返回的islockscreen总是yes；
          isLockScreen和isLockPortrait，因为播放器时UIView，是否旋转需要配合UIViewController来控制物理旋转。
         假设：支持竖屏全屏
             self.playerView.isLockPortrait = YES;
             self.playerView.isLockScreen = NO;
             self.isLock = self.playerView.isLockScreen||self.playerView.isLockPortrait?YES:NO;
     
             支持横屏全屏
             self.playerView.isLockPortrait = NO;
             self.playerView.isLockScreen = NO;
             self.isLock = self.playerView.isLockScreen||self.playerView.isLockPortrait?YES:NO;
     
             锁定屏幕
             self.playerView.isLockPortrait = NO;
             self.playerView.isLockScreen = YES;
             self.isLock = self.playerView.isLockScreen||self.playerView.isLockPortrait?YES:NO;
     
             self.isLock时来判定UIViewController 是否支持物理旋转。如果viewcontroller在navigationcontroller中，需要添加子类重写navigationgController中的 以下方法，根据实际情况做判定 。
     */
    
    self.playerView.isScreenLocked = NO;
    self.playerView.fixedPortrait = NO;
    self.isLock = self.playerView.isScreenLocked||self.playerView.fixedPortrait?YES:NO;
    
    //边下边播缓存沙箱位置
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [pathArray objectAtIndex:0];
    //maxsize:单位 mb    maxDuration:单位秒 ,在prepare之前调用。
    [self.playerView setPlayingCache:NO saveDir:docDir maxSize:300 maxDuration:10000];
    
    //查看缓存文件时打开。
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerun) userInfo:nil repeats:YES];
    
    //播放本地视频
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"set.mp4" ofType:nil];
//    [self.playerView playViewPrepareWithURL:[NSURL URLWithString:@"http://vod-test5.cn-shanghai.aliyuncs.com/84c80abba5e04fe9b57564d204a59585/b5a2911dd2c44c5d81ec568eb3b14431-f30978e8480a8c3a231ab2127d839b0c.mp4?auth_key=1512310022-0-0-c2f3ebd18ba1f4350edf1c5155f1e2dd"]];
}

- (void)becomeActive{
    self.isBecome = NO;
}

- (void)resignActive{
    self.isBecome = YES;
    if (self.playerView && self.playerView.playerViewState == AliyunVodPlayerStatePlay){
        [self.playerView pause];
    }
}

- (NSString*)iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    return platform;
}

//适配iphone x 界面问题，没有在 viewSafeAreaInsetsDidChange 这里做处理 ，主要 旋转监听在 它之后获取。
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.playerView.frame = self.view.bounds;
   NSString *platform =  [self iphoneType];
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat topHeight = 0;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ) {
        width = SCREEN_WIDTH;
        height = SCREEN_WIDTH * 9 / 16.0;
        topHeight = 44;
    }else{
        width = SCREEN_WIDTH;
        height = SCREEN_HEIGHT;
        topHeight = 0;
    }
    CGRect tempFrame = CGRectMake(0,topHeight, width, height);
    UIDevice *device = [UIDevice currentDevice] ;
    //iphone x
    if (![platform isEqualToString:@"iPhone10,3"] && ![platform isEqualToString:@"iPhone10,6"]) {
        switch (device.orientation) {//device.orientation
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationFaceDown:
            case UIDeviceOrientationUnknown:
            case UIDeviceOrientationPortraitUpsideDown:
                break;
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                {
                    self.playerView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
                }
                break;
            case UIDeviceOrientationPortrait:
                {
                    self.playerView.frame = tempFrame;
                }
                break;
            default:
                
                break;
            }
        return;
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    switch (device.orientation) {//device.orientation
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortraitUpsideDown:{
            if (self.isStatusHidden) {
                CGRect frame = self.playerView.frame;
                frame.origin.x = VIEWSAFEAREAINSETS(self.view).left;
                frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
                frame.size.width = SCREEN_WIDTH-VIEWSAFEAREAINSETS(self.view).left*2;
                frame.size.height = SCREEN_HEIGHT-VIEWSAFEAREAINSETS(self.view).bottom-VIEWSAFEAREAINSETS(self.view).top;
                self.playerView.frame = frame;
            }else{
                CGRect frame = self.playerView.frame;
                frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
                //竖屏全屏时 isStatusHidden 来自是否 旋转回调。
                if (self.playerView.fixedPortrait&&self.isStatusHidden) {
                    frame.size.height = SCREEN_HEIGHT- VIEWSAFEAREAINSETS(self.view).top- VIEWSAFEAREAINSETS(self.view).bottom;
                }
                self.playerView.frame = frame;
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            //
            CGRect frame = self.playerView.frame;
            frame.origin.x = VIEWSAFEAREAINSETS(self.view).left;
            frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
            frame.size.width = SCREEN_WIDTH-VIEWSAFEAREAINSETS(self.view).left*2;
            frame.size.height = SCREEN_HEIGHT-VIEWSAFEAREAINSETS(self.view).bottom;
            self.playerView.frame = frame;
        }
            
            break;
        case UIDeviceOrientationPortrait:
        {
            CGRect frame = tempFrame;
            frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
            //竖屏全屏时 isStatusHidden 来自是否 旋转回调。
            if (self.playerView.fixedPortrait&&self.isStatusHidden) {
                frame.size.height = SCREEN_HEIGHT- VIEWSAFEAREAINSETS(self.view).top- VIEWSAFEAREAINSETS(self.view).bottom;
            }
            self.playerView.frame = frame;
        }
            
            break;
        default:
            
            break;
    }

#else
    
#endif
}


#pragma mark - AliyunVodPlayerViewDelegate
- (void)onBackViewClickWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView{
    if (self.playerView != nil) {
        [self.playerView stop];
        [self.playerView releasePlayer];
        [self.playerView removeFromSuperview];
        self.playerView = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.isLock = isLockScreen; 
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onVideoQualityChanged:(AliyunVodPlayerVideoQuality)quality{
    
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView fullScreen:(BOOL)isFullScreen{
    NSLog(@"isfullScreen --%d",isFullScreen);

    self.isStatusHidden = isFullScreen  ;
    [self setNeedsStatusBarAppearanceUpdate];
   
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView onVideoDefinitionChanged:(NSString *)videoDefinition {
}

- (void)onCircleStartWithVodPlayerView:(AliyunVodPlayerView *)playerView {
}


/**
 * 功能：获取媒体信息
 */
- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView mediaInfo:(AliyunVodPlayerVideo*)mediaInfo{
    
}

-(void)timerun{
//    [self fileSize];
}

-(void)fileSize{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [pathArray objectAtIndex:0];
    NSString *filePath = docDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:docDir isDirectory:nil]){
        NSArray *subpaths = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
        for (NSString *subpath in subpaths) {
            
            NSString *fullSubpath = [filePath stringByAppendingPathComponent:subpath];
            if ([subpath hasSuffix:@".mp4"]) {
                long long fileSize =  [fileManager attributesOfItemAtPath:fullSubpath error:nil].fileSize;
                NSLog(@"fileSie ---- %lld",fileSize);
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 锁屏功能
/**
 * 说明：播放器父类是UIView。
 屏幕锁屏方案需要用户根据实际情况，进行开发工作；
 如果viewcontroller在navigationcontroller中，需要添加子类重写navigationgController中的 以下方法，根据实际情况做判定 。
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
//    return toInterfaceOrientation = UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationPortrait;
    
    if (self.isBecome) {
        return toInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
    }
    
    if (self.isLock) {
        return toInterfaceOrientation = UIInterfaceOrientationPortrait;
    }else{
        return YES;
    }
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate{
    return !self.isLock;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    if (self.isBecome) {
        return UIInterfaceOrientationMaskLandscapeLeft;
    }

    if (self.isLock) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }
}

-(BOOL)prefersStatusBarHidden
{
    return self.isStatusHidden;
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
