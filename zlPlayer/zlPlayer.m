//
//  zlPlayer.m
//  zlPlayer
//
//  Created by Tang杰 on 2018/4/14.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import "zlPlayer.h"
#import "NSDictionaryUtils.h"
#import "AliyunVodPlayerViewSDK.h"
#import "UZAppDelegate.h"
#import "AliyunVodDownLoadManager.h"
#import "NSObject+Header.h"

@interface MediaInfo : NSObject
/** 字符串类型；视频id */
@property(nonatomic,copy)NSString *vid;
/** 字符串类型；视频标题 */
@property(nonatomic,copy)NSString *title;
/** 字符串；遮罩Url */
@property(nonatomic,copy)NSString *coverUrl;
/** 字符串类型；视频质量 */
@property(nonatomic,assign)AliyunVodPlayerVideoQuality  quality;
/** 数字类型；下载进度， */
@property(nonatomic,assign)int progress;
/** 字符串类型；下载地址 */
@property(nonatomic,copy)NSString *savePath;
/** 数字类型；视频长度 */
@property(nonatomic,assign)int64_t duration;
/** 数字类型；视频大小 */
@property(nonatomic,assign)int64_t size;
/**  字符串；视频格式 */
@property(nonatomic,copy)NSString* format;
@end

@implementation MediaInfo

- (AliyunDownloadMediaInfo *)toAliyunDownloadMediaInfo {
    AliyunDownloadMediaInfo *mediaInfo = [[AliyunDownloadMediaInfo alloc] init];
    mediaInfo.vid = self.vid;
    mediaInfo.title = self.title;
    mediaInfo.coverURL = self.coverUrl;
    mediaInfo.quality = self.quality;
    mediaInfo.downloadProgress = self.progress;
    mediaInfo.downloadFilePath = self.savePath;
    mediaInfo.duration = self.duration;
    mediaInfo.size = self.size;
    mediaInfo.format = self.format;
    
    return mediaInfo;
}
+ (MediaInfo *)mediaInfoByAliyunDownloadMediaInfo:(AliyunDownloadMediaInfo *)aliMediaInfo {
    
    MediaInfo *mediaInfo = [[MediaInfo alloc] init];
    mediaInfo.vid = aliMediaInfo.vid;
    mediaInfo.title = aliMediaInfo.title;
    mediaInfo.coverUrl = aliMediaInfo.coverURL;
    mediaInfo.quality = aliMediaInfo.quality;
    mediaInfo.progress = aliMediaInfo.downloadProgress;
    mediaInfo.savePath = aliMediaInfo.downloadFilePath;
    mediaInfo.duration = aliMediaInfo.duration;
    mediaInfo.size = aliMediaInfo.size;
    mediaInfo.format = aliMediaInfo.format;
    
    return mediaInfo;
}

@end

typedef NS_ENUM(NSUInteger, ScreenOrientation) {
    /** 竖屏时，屏幕在home键的上面 */
    ScreenOrientation_portrait_up = 1,
    /** 竖屏时，幕在home键的下面，部分手机不支持 */
    ScreenOrientation_portrait_down = 2,
    /** //横屏时，屏幕在home键的左边 */
    ScreenOrientation_landscape_left = 3,
    /** //横屏时，屏幕在home键的右边 */
    ScreenOrientation_landscape_right = 4,
    /**  //屏幕根据重力感应在横竖屏间自动切换 */
    ScreenOrientation_auto = 5,
    /** //屏幕根据重力感应在竖屏间自动切换 */
    ScreenOrientation_auto_portrait = 6,
    /** //屏幕根据重力感应在横屏间自动切换 */
    ScreenOrientation_auto_landscape = 7,
};

typedef NS_ENUM(NSUInteger, EventType) {
    EventType_Play,
    EventType_Pause,
    EventType_Resume,
    EventType_Stop,
    EventType_Seek,
    EventType_Finish,
    EventType_LockScreen,
    EventType_FullScreen,
};

@interface zlPlayer()<AliyunVodPlayerViewDelegate,AliyunVodDownLoadDelegate,UIApplicationDelegate>
{
    NSMutableDictionary *_cbIdDictionary;
    NSString *_fixedOn;
    NSString *_referer;
    BOOL _fixed;
    CGRect _rect;
    NSString *_orientationStr;
    NSString *_title;
    NSString *_coverUrl;
    BOOL _isFullScreen;
    UIButton *_backBtn;
    UIView *_controlLayer; //工具栏
    UIButton *_fullScreenBtn;
    CGFloat _statusBarHeight;
    UIView *_popLayer; //提示视图
}
@property (nonatomic, strong) AliyunVodPlayerView *playerView;
@property (nonatomic, strong) AliyunVodPlayer *aliyunVodPlayer;
@property (nonatomic, strong) AliVcMediaPlayer *aliVcMediaPlayer;
@property (nonatomic, assign) ScreenOrientation orientation;
@property(nonatomic,strong) AliyunStsData *stsData;
@property(nonatomic,strong) AliyunDataSource *aliyunDataSource;
@end

@implementation zlPlayer


- (id)initWithUZWebView:(id)webView
{
    if (self = [super initWithUZWebView:webView]) {
        _cbIdDictionary = @{}.mutableCopy;
        _orientationStr = [self screenOrientation:ScreenOrientation_landscape_right];
        [[UZAppDelegate appDelegate] addAppHandle:self];
    }
    return self;
}
- (void)dispose
{
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [self callback:YES msg:@"页面关闭" SEL:@selector(setLogger:)];
    [self stop];
}

//- (void)receiveNotification:(NSNotification *)notifi {
//    if ([[notifi object] isKindOfClass:[AliVcMediaPlayer class]]) {
//        AliVcMediaPlayer *aliVcMediaPlayer = notifi.object;
////        NSLog(@"%@",aliVcMediaPlayer.getAllDebugInfo);
//        [self callbackByDic:aliVcMediaPlayer.getAllDebugInfo msg:notifi.name SEL:@selector(setLogger:) doDelete:NO];
//    }
//}

//- (void)removeNotification {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

//- (void)registerNotification {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerLoadDidPreparedNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerPlaybackErrorNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerPlaybackStopNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerSeekingDidFinishNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerPlaybackDidFinishNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerStartCachingNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerEndCachingNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerFirstFrameNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerCircleStartNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:AliVcMediaPlayerSeiDataNotification object:nil];
//}


/** 清除收据 */
- (void)clean {
    _cbIdDictionary = nil;
    _fixedOn = nil;
    _referer = nil;
    _fixed = NO;
    _rect = CGRectZero;
    _title = nil;
    _coverUrl = nil;
    _isFullScreen = NO;
    _backBtn = nil;
    _aliyunVodPlayer = nil;
    _aliVcMediaPlayer = nil;
    _controlLayer = nil;
    _statusBarHeight = 0;
    [[UZAppDelegate appDelegate] removeAppHandle:self];
}
- (void)stop {
    if (self.playerView != nil) {
        [self.aliyunVodPlayer removeObserver:self forKeyPath:@"currentPlayerVideo"];
        [self.playerView stop];
        [self.playerView releasePlayer];
        [self.playerView removeFromSuperview];
        self.playerView = nil;
    }
    //    [self removeNotification];
    [self clean];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[AliyunVodDownLoadManager shareManager] stopDownloadMedias:[[AliyunVodDownLoadManager shareManager] currentDownloadingdMedias]];
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
    _coverUrl = [paramDict stringValueForKey:@"coverUrl" defaultValue:@""];
    _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    if (!self.playerView) {
        [self initPlayerView];
        //        [self registerNotification];
    }
    /**************************************/
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(becomeActive)
    //                                                 name:UIApplicationDidBecomeActiveNotification
    //                                               object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(resignActive)
    //                                                 name:UIApplicationWillResignActiveNotification
    //                                               object:nil];
}

/** 开始播放url */
- (void)play:(NSDictionary *)paramDict  {
    [self addCbIDByParamDict:paramDict SEL:@selector(play:)];
    NSString *url = [paramDict stringValueForKey:@"url" defaultValue:nil];
    _title = [paramDict stringValueForKey:@"title" defaultValue:url];
    _orientationStr = [paramDict stringValueForKey:@"direction" defaultValue:_orientationStr];
    _coverUrl = [paramDict stringValueForKey:@"coverUrl" defaultValue:@""];
    NSDictionary *sts = [paramDict dictValueForKey:@"sts" defaultValue:nil];
    url = [self getPathWithUZSchemeURL:url];
    if (self.playerView) {
        [self.playerView stop];
    }
    if (!_popLayer.hidden) {
        _popLayer.hidden = YES;
    }
    if (url) {
        [self.playerView setTitle:_title];
        [self.playerView setCoverUrl:[NSURL URLWithString:_coverUrl]];
        [self.playerView playViewPrepareWithURL:[NSURL URLWithString:url]];
        [self callbackByDic:@{@"title":_title,@"coverUrl":_coverUrl,@"url":url} msg:@"" SEL:@selector(setLogger:) doDelete:NO];
    } else {
        NSString *vid = [sts stringValueForKey:@"vid" defaultValue:nil];
        NSString *accessKeySecret = [sts stringValueForKey:@"accessKeySecret" defaultValue:nil];
        NSString *accessKeyId = [sts stringValueForKey:@"accessKeyId" defaultValue:nil];
        NSString *securityToken = [sts stringValueForKey:@"securityToken" defaultValue:nil];
        [self.playerView playViewPrepareWithVid:vid accessKeyId:accessKeyId accessKeySecret:accessKeySecret securityToken:securityToken];
        //        [self.aliyunVodPlayer prepareWithVid:vid accessKeyId:accessKeyId accessKeySecret:accessKeySecret securityToken:securityToken];
        [self callbackByDic:@{@"vid":vid,@"accessKeySecret":accessKeySecret,@"accessKeyId":accessKeyId,@"securityToken":securityToken} msg:@"" SEL:@selector(setLogger:) doDelete:NO];
    }
    [self.playerView getAliyunMediaInfo];
    [self callback:YES msg:@""  SEL:@selector(play:)];
    
    NSDictionary *dic = @{@"status":@(YES),@"eventType":@"play"};
    [self callbackByDic:dic msg:@"" SEL:@selector(addEventListener:) doDelete:NO];
}
/** 获取播放器当前播放进度 */
- (void)getCurrentPosition:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(getCurrentPosition:)];
    [self callbackByDic:@{@"status":@(YES),@"currentPosition":@(self.playerView.currentTime*1000)} msg:@"" SEL:@selector(getCurrentPosition:) doDelete:YES];
}
/** 停止播放 */
- (void)stop:(NSDictionary *)paramDict {
    
    [self addCbIDByParamDict:paramDict SEL:@selector(stop:)];
    [self callback:YES msg:@"" SEL:@selector(stop:)];
    
    [self stop];
}

/** 获取是否全屏播放状态 */
- (void)isFullScreen:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(isFullScreen:)];
    [self callback:_isFullScreen msg:@"" SEL:@selector(isFullScreen:)];
}
/** 设置播放进度位置 */
- (void)seekTo:(NSDictionary *)paramDict {
    NSInteger process = [paramDict integerValueForKey:@"process" defaultValue:0];
    [self.aliyunVodPlayer seekToTime:process/1000];
    [self addCbIDByParamDict:paramDict SEL:@selector(seekTo:)];
    [self callback:YES msg:@"" SEL:@selector(seekTo:)];
}
/** 设置播放速度 */
- (void)setPlaySpeed:(NSDictionary *)paramDict {
    CGFloat playSpeed = [paramDict floatValueForKey:@"speed" defaultValue:1.0];
    [self.aliyunVodPlayer setPlaySpeed:playSpeed];
    [self addCbIDByParamDict:paramDict SEL:@selector(setPlaySpeed:)];
    [self callback:YES msg:@"" SEL:@selector(setPlaySpeed:)];
}
/** 暂停播放 */
- (void)pause:(NSDictionary *)paramDict {
    [self.playerView pause];
    [self addCbIDByParamDict:paramDict SEL:@selector(pause:)];
    [self callback:YES msg:@"" SEL:@selector(pause:)];
}
/** 继续播放 */
- (void)resume:(NSDictionary *)paramDict {
    [self.playerView resume];
    [self addCbIDByParamDict:paramDict SEL:@selector(resume:)];
    [self callback:YES msg:@"" SEL:@selector(resume:)];
}
/** 取消全屏播放 */
- (void)unfull:(NSDictionary *)paramDict
{
    [self addCbIDByParamDict:paramDict SEL:@selector(unfull:)];
    [self clickFullSreenButton];
    [self callback:YES msg:@"" SEL:@selector(unfull:)];
}
/** 打印日志 */
- (void)setLogger:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(setLogger:)];
}
/** 事件监听 */
- (void)addEventListener:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(addEventListener:)];
}
/** 版本获取 */
- (void)getSDKVersion:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(getSDKVersion:)];
    [self callbackByDic:@{@"version}":[NSString stringWithFormat:@"%@/%@",[self.playerView getSDKVersion],version]} msg:@"" SEL:@selector(getSDKVersion:) doDelete:YES];
}

/** 初始化下载器 */
- (void)initDownloader:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(initDownloader:)];
    //    加密文件路径（需要转化为绝对路径）
    NSString *secretImagePath = [paramDict stringValueForKey:@"secretImagePath" defaultValue:nil];
    secretImagePath = [self getPathWithUZSchemeURL:secretImagePath];
    //    下载文件路径（需要转化为绝对路径）
    NSString *downloadDir = [paramDict stringValueForKey:@"downloadDir" defaultValue:nil];
    downloadDir = [self getPathWithUZSchemeURL:downloadDir];
    //    描述：允许同时开启的个数（最多为4个）
    int maxNums = [paramDict intValueForKey:@"maxNums" defaultValue:4];
    
    [[AliyunVodDownLoadManager shareManager] setDownloadDelegate:self];
    [[AliyunVodDownLoadManager shareManager] setDownLoadPath:downloadDir];
    [[AliyunVodDownLoadManager shareManager] setMaxDownloadOperationCount:maxNums];
    [[AliyunVodDownLoadManager shareManager] setEncrptyFile:secretImagePath];
    
    [[AliyunVodDownLoadManager shareManager] clearAllMedias];
    
    [self callbackByDic:@{@"initDownloader":paramDict} msg:nil SEL:@selector(setLogger:) doDelete:NO];
}
/** 设置sts刷新回调函数 */
- (void)setRefreshStsCallback:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(setRefreshStsCallback:)];
    [self callback:YES msg:@"" SEL:@selector(setRefreshStsCallback:)];
}
/** 设置sts刷新回调函数 */
- (void)setSts:(NSDictionary *)paramDict {
    [self callbackByDic:@{@"setSts":paramDict} msg:nil SEL:@selector(setLogger:) doDelete:NO];
    self.stsData = [AliyunStsData toModel:paramDict];
}
/** 设准备下载 */
- (void)prepareDownload:(NSDictionary *)paramDict {
    NSString *vid = [paramDict stringValueForKey:@"vid" defaultValue:nil];
    AliyunStsData *stsData = [AliyunStsData toModel:paramDict];
    self.stsData = stsData;
    self.aliyunDataSource.requestMethod = AliyunVodRequestMethodStsToken;
    self.aliyunDataSource.vid = vid;
    self.aliyunDataSource.stsData = self.stsData;
    [[AliyunVodDownLoadManager shareManager] prepareDownloadMedia:self.aliyunDataSource];
    [self callbackByDic:@{@"prepareDownload":paramDict} msg:nil SEL:@selector(setLogger:) doDelete:NO];
}
/** 开始下载 */
- (void)startDownload:(NSDictionary *)paramDict {
    [self callbackByDic:@{@"startDownload":paramDict} msg:nil SEL:@selector(setLogger:) doDelete:NO];
    NSDictionary *mediaInfo = [paramDict dictValueForKey:@"mediaInfo" defaultValue:paramDict];
    AliyunDownloadMediaInfo *willDownloadMedias = [[MediaInfo toModel:mediaInfo] toAliyunDownloadMediaInfo];
    
    NSMutableArray<AliyunDownloadMediaInfo*> *downloadingdMedias = [NSMutableArray arrayWithArray:[[AliyunVodDownLoadManager shareManager] downloadingdMedias]];
    [downloadingdMedias addObject:willDownloadMedias];
    
    for (AliyunDownloadMediaInfo *mediaInfo_1 in [[AliyunVodDownLoadManager shareManager] allMedias]) {
        if ([willDownloadMedias.vid isEqualToString:mediaInfo_1.vid]) {
            [[AliyunVodDownLoadManager shareManager] clearMedia:mediaInfo_1];
            continue;
        }
    }
    NSMutableArray *ar = @[].mutableCopy;
    for (AliyunDownloadMediaInfo *aliMediaInfo in downloadingdMedias) {
        MediaInfo *info = [MediaInfo mediaInfoByAliyunDownloadMediaInfo:aliMediaInfo];
        self.aliyunDataSource.vid = info.vid;
        self.aliyunDataSource.quality = info.quality;
        self.aliyunDataSource.format = info.format;
        AliyunDataSource *sor = [AliyunDataSource toModel:self.aliyunDataSource.tj_JSONObject];
        [ar addObject:sor];
    }
    [[AliyunVodDownLoadManager shareManager] startDownloadMedias:ar];
}
/** 停止下载 */
- (void)stopDownload:(NSDictionary *)paramDict {
    [self callbackByDic:@{@"stopDownload":paramDict} msg:nil SEL:@selector(setLogger:) doDelete:NO];
    NSDictionary *mediaInfoDic = [paramDict dictValueForKey:@"mediaInfo " defaultValue:paramDict];
    if (mediaInfoDic) {
        MediaInfo *info = [MediaInfo toModel:mediaInfoDic];
        AliyunDownloadMediaInfo *mediaInfo = [info toAliyunDownloadMediaInfo];
        [[AliyunVodDownLoadManager shareManager] stopDownloadMedia:mediaInfo];
    }
}
/** 删除下载 */
- (void)removeDownload:(NSDictionary *)paramDict {
    [self callbackByDic:@{@"removeDownload":paramDict} msg:nil SEL:@selector(setLogger:) doDelete:NO];
    NSDictionary *mediaInfoDic = [paramDict dictValueForKey:@"mediaInfo " defaultValue:paramDict];
    if (mediaInfoDic) {
        MediaInfo *info = [MediaInfo toModel:mediaInfoDic];
        AliyunDownloadMediaInfo *mediaInfo = [info toAliyunDownloadMediaInfo];
        [[AliyunVodDownLoadManager shareManager] clearMedia:mediaInfo];
    }
}
/**  功能：获取正在下载视频资源列表。 */
- (void)getDownloadList:(NSDictionary *)paramDict {
    [self addCbIDByParamDict:paramDict SEL:@selector(getDownloadList:)];
    NSArray *currentDownloadingdMedias = [[AliyunVodDownLoadManager shareManager] currentDownloadingdMedias];
    NSArray *downloadingdMedias = [[AliyunVodDownLoadManager shareManager] downloadingdMedias];
    
    NSArray *mediaInfos = [[AliyunVodDownLoadManager shareManager] allMedias];
    NSMutableArray *ar = @[].mutableCopy;
    for (AliyunDownloadMediaInfo *mediaInfo in mediaInfos) {
        NSMutableDictionary *info = [MediaInfo mediaInfoByAliyunDownloadMediaInfo:mediaInfo].tj_JSONObject;
        if ([currentDownloadingdMedias containsObject:mediaInfo]) {
            [info setObject:@"Start" forKey:@"status"];
        } else if ([downloadingdMedias containsObject:mediaInfo]) {
            [info setObject:@"Wait" forKey:@"status"];
        }
        [ar addObject:info];
    }
    [self callbackByDic:@{@"getDownloadList":paramDict,@"mediaInfos":ar} msg:nil SEL:@selector(getDownloadList:) doDelete:YES];
}
#pragma mark ------------ AliyunVodDownLoadDelegate
/*
 功能：准备下载回调。
 回调数据：AliyunDownloadMediaInfo数组
 */
-(void) onPrepare:(NSArray<AliyunDownloadMediaInfo*>*)mediaInfos
{
    NSMutableArray *ar = @[].mutableCopy;
    for (AliyunDownloadMediaInfo *mediaInfo in mediaInfos) {
        [ar addObject:[MediaInfo mediaInfoByAliyunDownloadMediaInfo:mediaInfo].tj_JSONObject];
    }
    [self callbackByDic:@{@"status":@(YES),@"event":@"prepared",@"mediaInfos":ar} msg:@"" SEL:@selector(initDownloader:) doDelete:NO];
}
/*
 功能：下载开始回调。
 回调数据：AliyunDownloadMediaInfo
 */
-(void) onStart:(AliyunDownloadMediaInfo*)mediaInfo
{
    [self callbackByDic:@{@"status":@(YES),@"event":@"start",@"mediaInfos":@[[MediaInfo mediaInfoByAliyunDownloadMediaInfo:mediaInfo].tj_JSONObject]} msg:@"" SEL:@selector(initDownloader:) doDelete:NO];
}
/*
  功能：调用stop结束下载时回调。
  回调数据：AliyunDownloadMediaInfo
  */
-(void) onStop:(AliyunDownloadMediaInfo*)mediaInfo
{
    [self callbackByDic:@{@"status":@(YES),@"event":@"stop",@"mediaInfos":@[[MediaInfo mediaInfoByAliyunDownloadMediaInfo:mediaInfo].tj_JSONObject]} msg:@"" SEL:@selector(initDownloader:) doDelete:NO];
}
/*
  功能：下载完成回调。
  回调数据：AliyunDownloadMediaInfo
 */
-(void) onCompletion:(AliyunDownloadMediaInfo*)mediaInfo
{
    [self callbackByDic:@{@"status":@(YES),@"event":@"completion",@"mediaInfos":@[[MediaInfo mediaInfoByAliyunDownloadMediaInfo:mediaInfo].tj_JSONObject]} msg:@"" SEL:@selector(initDownloader:) doDelete:NO];
}
/*
  功能：下载进度回调。可通过mediaInfo.downloadProgress获取进度。
  回调数据：AliyunDownloadMediaInfo
  */
-(void) onProgress:(AliyunDownloadMediaInfo*)mediaInfo
{
    [self callbackByDic:@{@"status":@(YES),@"event":@"progress",@"mediaInfos":@[[MediaInfo mediaInfoByAliyunDownloadMediaInfo:mediaInfo].tj_JSONObject]} msg:@"" SEL:@selector(initDownloader:) doDelete:NO];
}
/*
  功能：错误回调。错误码与错误信息详见文档。
  回调数据：AliyunDownloadMediaInfo， code：错误码 msg：错误信息
  */
-(void)onError:(AliyunDownloadMediaInfo*)mediaInfo code:(int)code msg:(NSString *)msg
{
    [self callbackByDic:@{@"status":@(YES),@"event":@"error",@"mediaInfos":@[[MediaInfo mediaInfoByAliyunDownloadMediaInfo:mediaInfo].tj_JSONObject],@"code":@(code)} msg:@"" SEL:@selector(initDownloader:) doDelete:NO];
}
/*
 功能：未完成回调，异常中断导致下载未完成，下次启动后会接收到此回调。
 回调数据：AliyunDownloadMediaInfo数组
 */
-(void) onUnFinished:(NSArray<AliyunDataSource*>*)mediaInfos
{
    NSMutableArray *ar = @[].mutableCopy;
    for (AliyunDataSource *dataSource in mediaInfos) {
        MediaInfo *mediaInfo = [MediaInfo toModel:dataSource.tj_JSONObject];
        [ar addObject:mediaInfo.tj_JSONObject];
    }
    
    [self callbackByDic:@{@"status":@(YES),@"event":@"unfinished",@"mediaInfos":ar} msg:@"" SEL:@selector(initDownloader:) doDelete:NO];
}

#pragma mark - private

/** 回调JS */
- (void)callback:(BOOL)status msg:(NSString *)msg SEL:(SEL)sel {
    
    [self callbackByDic:@{@"status":@(status)} msg:msg SEL:sel doDelete:YES];
}

- (void)callbackByDic:(NSDictionary *)dic msg:(NSString *)msg SEL:(SEL)sel doDelete:(BOOL)doDelete  {
    if (!msg) msg = @"";
    
    NSMutableDictionary *mutDic = dic.mutableCopy;
    if (![mutDic.allKeys containsObject:@"status"]) {
        [mutDic setObject:@(YES) forKey:@"status"];
    }
    if (!self.playerView) {
        [mutDic setObject:@(NO) forKey:@"status"];
        msg = @"还未初始化播放器";
    }
    if ([_cbIdDictionary.allKeys containsObject:NSStringFromSelector(sel)]) {
        NSInteger cbID = [_cbIdDictionary intValueForKey:NSStringFromSelector(sel) defaultValue:0];
        [self sendResultEventWithCallbackId:cbID dataDict:mutDic errDict:@{@"msg":msg} doDelete:doDelete];
        if (doDelete) {
            [_cbIdDictionary removeObjectForKey:NSStringFromSelector(sel)];
        }
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
    if (orientation == ScreenOrientation_portrait_up) {
        return @"portrait_up";
    } else if (orientation == ScreenOrientation_portrait_down) {
        return @"portrait_down";
    } else if (orientation == ScreenOrientation_landscape_left) {
        return @"landscape_left";
    } else if (orientation == ScreenOrientation_landscape_right) {
        return @"landscape_right";
    } else if (orientation == ScreenOrientation_auto) {
        return @"auto";
    } else if (orientation == ScreenOrientation_auto_portrait) {
        return @"auto_portrait";
    } else if (orientation == ScreenOrientation_auto_landscape) {
        return @"auto_landscape";
    }
    return @"landscape_right";
}
#pragma mark - AliyunVodPlayerViewDelegate
/**
 * 功能：播放事件协议方法,主要内容 AliyunVodPlayerEventPrepareDone状态下，此时获取到播放视频数据（时长、当前播放数据、视频宽高等）
 * 参数：event 视频事件
 */
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event
{
    if (event == AliyunVodPlayerEventFirstFrame) {
        NSDictionary *dic = @{@"status":@(YES),@"eventType":@"firstframe"};
        [self callbackByDic:dic msg:@"firstframe" SEL:@selector(addEventListener:) doDelete:NO];
    }
}
/**
 * 功能：播放器播放时发生错误时，回调信息
 * 参数：errorModel 播放器报错时提供的错误信息对象
 */
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(AliyunPlayerVideoErrorModel *)errorModel
{
    NSDictionary *dic = @{@"status":@(YES),@"eventType":@"error",@"message":errorModel.errorMsg,@"code":@(errorModel.errorCode)};
    [self callbackByDic:dic msg:@"error" SEL:@selector(addEventListener:) doDelete:NO];
}
- (void)onBackViewClickWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView{
    
}
- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onPause:(NSTimeInterval)currentPlayTime{
    NSDictionary *dic = @{@"status":@(YES),@"eventType":@"pause"};
    [self callbackByDic:dic msg:@"onPause" SEL:@selector(addEventListener:) doDelete:NO];
}
- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onResume:(NSTimeInterval)currentPlayTime{
    NSDictionary *dic = @{@"status":@(YES),@"eventType":@"resume"};
    [self callbackByDic:dic msg:@"onResume" SEL:@selector(addEventListener:) doDelete:NO];
}
- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onStop:(NSTimeInterval)currentPlayTime{
    NSDictionary *dic = @{@"status":@(YES),@"eventType":@"stop"};
    [self callbackByDic:dic msg:@"onStop" SEL:@selector(addEventListener:) doDelete:NO];
}
- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onSeekDone:(NSTimeInterval)seekDoneTime{
    NSDictionary *dic = @{@"status":@(YES),@"eventType":@"seekDone"};
    [self callbackByDic:dic msg:@"onSeekDone" SEL:@selector(addEventListener:) doDelete:NO];
    [self callbackByDic:@{@"seekDoneTime":@(seekDoneTime)} msg:@"" SEL:@selector(setLogger:) doDelete:NO];
}
-(void)onFinishWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView{
    NSDictionary *dic = @{@"status":@(YES),@"eventType":@"end"};
    [self callbackByDic:dic msg:@"onFinish" SEL:@selector(addEventListener:) doDelete:NO];
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView lockScreen:(BOOL)isLockScreen{
    NSDictionary *dic = @{@"status":@(YES),@"eventType":@(EventType_LockScreen)};
    [self callbackByDic:dic msg:@"LockScreen" SEL:@selector(addEventListener:) doDelete:NO];
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onVideoQualityChanged:(AliyunVodPlayerVideoQuality)quality
{
    
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView fullScreen:(BOOL)isFullScreen{
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView onVideoDefinitionChanged:(NSString *)videoDefinition {
    
}


- (void)onCircleStartWithVodPlayerView:(AliyunVodPlayerView *)playerView {
    
}
#pragma mark ------------ event response
/** 设置屏幕取向 */
- (void)setOrientation:(ScreenOrientation)orientation {
    if (_orientation == orientation) return;
    _orientation = orientation;
    
    dispatch_semaphore_t signal = dispatch_semaphore_create(1); //传入值必须 >=0, 若传入为0则阻塞线程并等待timeout,时间到后会执行其后的语句
    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_semaphore_wait(signal, overTime); //signal 值 -1
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *orientationStr = [self screenOrientation:orientation];
            NSLog(@"%@",orientationStr);
            
            [self setScreenOrientation:@{@"orientation":[self screenOrientation:orientation]}];
            
            [self callbackByDic:@{@"playerViewFrame":NSStringFromCGRect(self.playerView.frame),@"controlLayerFrame":NSStringFromCGRect(self->_controlLayer.frame),@"isFullScreen":@(self->_isFullScreen),@"contentOffset":NSStringFromCGPoint(self.scrollView.contentOffset),@"orientation":orientationStr} msg:@"" SEL:@selector(setLogger:) doDelete:NO];
        });
        
        dispatch_semaphore_signal(signal); //signal 值 +1
    });
}
- (void)updatePlayerViewFrame:(BOOL)isFullScreen {
    BOOL fixed = _fixed;
    [self.playerView removeFromSuperview];
    if (isFullScreen) {
        CGRect frame = [UIScreen mainScreen].bounds;
        frame.size.height = CGRectGetHeight(frame) - _statusBarHeight;
        self.playerView.frame = frame;
        fixed = YES;
    } else {
        self.playerView.frame = _rect;
    }
    [self addSubview:self.playerView fixedOn:_fixedOn fixed:fixed];
    NSLog(@"self.playerView.frame->%@",NSStringFromCGRect(self.playerView.frame));
}

#pragma mark - getter/setter

//添加视图
-(void)initPlayerView{
    
    self.playerView = [[AliyunVodPlayerView alloc] initWithFrame:_rect andSkin:AliyunVodPlayerViewSkinRed];
    //    self.playerView.circlePlay = YES;
    [self.playerView setDelegate:self];
    [self.playerView setAutoPlay:YES];
    self.playerView.coverUrl = [NSURL URLWithString:_coverUrl];
    
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
    _popLayer = [self.playerView valueForKey:@"_popLayer"];
    _controlLayer = [self.playerView valueForKey:@"_controlLayer"];
    _fullScreenBtn = [_controlLayer valueForKey:@"_fullScreenBtn"];
    [_popLayer addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerView setUseWanNetDescribe:@"当前为移动网络"];
    
    _backBtn = [_controlLayer valueForKey:@"_backBtn"];
    _backBtn.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.playerView name:UIDeviceOrientationDidChangeNotification object:nil];
    
    for (id target in [_fullScreenBtn allTargets]) {
        for (NSString *sel in [_fullScreenBtn actionsForTarget:target forControlEvent:UIControlEventTouchUpInside]) {
            [_fullScreenBtn removeTarget:target action:NSSelectorFromString(sel) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    //    _fullScreenBtn.backgroundColor = [UIColor greenColor];
    [_fullScreenBtn addTarget:self action:@selector(clickFullSreenButton) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn addTarget:self action:@selector(clickFullSreenButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playerView setPrintLog:YES];
    
    aliPlayer.referer = _referer;
    self.aliyunVodPlayer = aliPlayer;
    [self addSubview:self.playerView fixedOn:_fixedOn fixed:_fixed];
    [self callback:YES msg:@"" SEL:@selector(init:)];
    
    [self.aliyunVodPlayer addObserver:self forKeyPath:@"currentPlayerVideo" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentPlayerVideo"]) {
        //        处理切换播放视频，title不变问题
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AliyunVodPlayerVideo *video = [self.playerView getAliyunMediaInfo];
            [self.playerView setTitle:video.title];
        });
    } else if ([keyPath isEqualToString:@"hidden"] && object == _popLayer) {
        //        屏蔽移动网络提示视图
        UILabel *label = [[_popLayer valueForKey:@"_errorView"] valueForKey:@"_errorLabel"];
        BOOL hidden = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (!hidden) {
            UIButton *bu = [_popLayer valueForKey:@"_backBtn"];
            [bu addTarget:self action:@selector(clickFullSreenButton) forControlEvents:UIControlEventTouchUpInside];
        }
        if (!hidden && [label.text isEqualToString:@"当前为移动网络"]) {
            UIButton *button = [[_popLayer valueForKey:@"_errorView"] valueForKey:@"_errorButton"];
            _popLayer.hidden = YES;
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}
- (void)clickFullSreenButton {
    
    _isFullScreen = !_isFullScreen;
    _backBtn.hidden = !_isFullScreen;
    NSDictionary *dic = @{@"status":@(YES),@"eventType":_isFullScreen ? @"fullscreen" : @"unfull"};
    [self callbackByDic:dic msg:@"" SEL:@selector(addEventListener:) doDelete:NO];
    
    if (_isFullScreen) {
        [self updatePlayerViewFrame:YES];
        if ([[self screenOrientation:ScreenOrientation_landscape_right] isEqualToString:_orientationStr]) {
            [self setOrientation:ScreenOrientation_landscape_right];
        } else {
            [self setOrientation:ScreenOrientation_landscape_left];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    } else {
        [self setOrientation:ScreenOrientation_portrait_up];
        [self updatePlayerViewFrame:NO];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notifi {
    if (self.playerView.isScreenLocked) return;
    [self callbackByDic:@{@"屏幕旋转":@([UIDevice currentDevice].orientation),@"orientation":[self screenOrientation:self.orientation]} msg:@"" SEL:@selector(setLogger:) doDelete:NO];
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        [self setOrientation:ScreenOrientation_landscape_right];
        [self updatePlayerViewFrame:YES];
    }
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
        [self setOrientation:ScreenOrientation_landscape_left];
        [self updatePlayerViewFrame:YES];
    }
}

- (AliyunStsData *)stsData
{
    if (!_stsData) {
        _stsData = [[AliyunStsData alloc] init];
    }
    return _stsData;
}
- (AliyunDataSource *)aliyunDataSource
{
    if (!_aliyunDataSource) {
        _aliyunDataSource = [[AliyunDataSource alloc] init];
    }
    return _aliyunDataSource;
}
//
//- (void)becomeActive{
//    [self.playerView resume];
//}
//
//- (void)resignActive{
//    if (self.playerView && self.playerView.playerViewState == AliyunVodPlayerStatePlay){
//        [self.playerView pause];
//    }
//}
@end
