//
//  ALVodTestView.h
//  AliyunVodPlayerViewSDK
//
//  Created by 王凯 on 2017/9/13.
//  Copyright © 2017年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunVodPlayerViewDefine.h"
#import "AliyunVodPlayerDefine.h"
#import "AliyunVodPlayerVideo.h"
/*
 当视频返回的时候的消息响应代理，此处可以进行一些销毁操作
 */
@class ALVodTestView;
@protocol ALVodTestViewDelegate <NSObject>
/**
 * 功能：返回按钮事件
 */
- (void)onBackViewClickWithAliyunVodPlayerView:(ALVodTestView*)playerView;
- (void)aliyunVodPlayerView:(ALVodTestView*)playerView onPause:(NSTimeInterval)currentPlayTime;
- (void)aliyunVodPlayerView:(ALVodTestView*)playerView onResume:(NSTimeInterval)currentPlayTime;
- (void)aliyunVodPlayerView:(ALVodTestView*)playerView onStop:(NSTimeInterval)currentPlayTime;
- (void)aliyunVodPlayerView:(ALVodTestView*)playerView onSeekDone:(NSTimeInterval)seekDoneTime;

/**
 * 功能：获取媒体信息
 */
- (void)aliyunVodPlayerView:(ALVodTestView*)playerView onVideoQualityChanged:(AliyunVodPlayerVideoQuality)quality;

@end

/*
 AliyunVodPlayerView为带皮肤界面的播放器，可以直接作为View来使用
 */
@interface ALVodTestView : UIView

/*
 功能：设置AliyunVodPlayerViewDelegate代理
 */
@property (nonatomic, weak) id<ALVodTestViewDelegate> delegate;

/**
 * 功能：播放器初始化后，获取播放器是否播放。
 */
@property (nonatomic, readonly,assign)BOOL isPlaying;

/**
 * 功能：设置网络超时时间，单位毫秒
 * 备注：当播放网络流时，设置网络超时时间，默认15000毫秒
 */
@property(nonatomic, assign) int timeout;

/**
 * 功能：日志开关, default : NO
 */
@property (nonatomic, getter=isPrintLog,assign) BOOL pringtLog;

/*
 功能：初始化窗口大小
 参数：frame:视图view大小
 备注：默认皮肤为蓝色
 */
- (instancetype)initWithFrame:(CGRect)frame;

/*
 功能：初始化窗口大小，并且设置播放器窗口皮肤
 参数：
 frame:视图view大小
 skin: 皮肤样式，类型有：
 AliyunVodPlayerViewSkinBlue,
 AliyunVodPlayerViewSkinRed,
 AliyunVodPlayerViewSkinOrange,
 AliyunVodPlayerViewSkinGreen
 */
- (instancetype)initWithFrame:(CGRect)frame andSkin:(AliyunVodPlayerViewSkin)skin;


/*
 *功能：使用vid+playauth方式播放。
 *参数：playKey 播放凭证
 vid 视频id
 *备注：本地视频播放，AliyunVodPlayerManagerDelegate在AliyunVodPlayerEventPrepareDone 状态下，某些参数无法获取（如：视频标题、清晰度）
 建议用户最终使用方案。
 userPlayKey :1.2.0之前版本参数名称 apikey。
 
 *playauth获取方法：https://help.aliyun.com/document_detail/52881.html?spm=5176.doc52879.6.650.aQZsBR
 
 客户端开发也可以通过python脚本获取播放凭证进行调试，具体流程如下：
 安装python2.7+pip环境（Mac环境下自带，Windows环境自行安装）
 使用终端安装SDK，运行以下命令：
 pip install aliyun-python-sdk-core
 pip install aliyun-python-sdk-vod
 下载Python脚本，从阿里云控制台获取accessKeyId和accessKeySecret并替换脚本里面的字段内容，从点播控制台获取已经上传视频的videoID并替换脚本里面的字段内容。
 在python脚本所在目录下通过终端执行以下命令：
 python playAuth.py
 在终端中查看获取的PlayAuth和VideoId。
 在播放器SDK中使用获取的PlayAuth和VideoId进行播放，注意PlayAuth的时效为100秒，如果过期请重新获取。
 
 */
- (void)playViewPrepareWithVid:(NSString *)vid playAuth : (NSString *)playAuth;

/*
 *功能：播放器初始化视频，主要目的是分析视频内容，读取视频头信息，解析视频流中的视频和音频信息，并根据视频和音频信息去寻找解码器，创建播放线程等
 *参数：url，输入的url，包括本地地址和网络视频地址
 *备注：调用该函数完成后立即返回，需要等待准备完成通知，收到该通知后代表视频初始化完成，视频准备完成后可以获取到视频的相关信息。
 使用本地地址播放，注意用户需要传 NSURL 类型数据，不是NSSting 类型数据。
 本地视频播放，AliyunVodPlayerManagerDelegate在AliyunVodPlayerEventPrepareDone 状态下，某些参数无法获取（如：视频标题、清晰度）
 */
- (void)playViewPrepareWithURL:(NSURL *)url;

/*
 功能：设置是否自动播放
 参数：
 autoPlay：YES为自动播放
 */
- (void)setAutoPlay:(BOOL)autoPlay;


/*
 功能：开始播放视频
 备注：在prepareWithVid之后可以调用start进行播放。
 */
- (void)start;

/*
 功能：停止播放视频
 */
- (void)stop;

/*
 功能：暂停播放视频
 */
- (void)pause;

/*
 功能：继续播放视频，此功能应用于pause之后，与pause功能匹配使用
 */
- (void)resume;

/*
 功能：重播
 */
- (void)replay;

/*
 功能：释放播放器
 */
- (void)releasePlayer;

/*
 功能：播放器播放状态
 状态有以下
 AliyunVodPlayerViewStateIdle,          无播放空闲状态
 AliyunVodPlayerViewStateError,         播放错误状态
 AliyunVodPlayerViewStatePreparing,     正在播放准备状态
 AliyunVodPlayerViewStatePrepared,      播放准备完成状态
 AliyunVodPlayerViewStatePlay,          正在播放状态
 AliyunVodPlayerViewStatePause,         播放暂停状态
 AliyunVodPlayerViewStateStop,          播放停止状态
 AliyunVodPlayerViewStateLoading        正在加载状态
 AliyunVodPlayerViewStateResume,         继续播放
 AliyunVodPlayerViewStateFinish,        播放完成
 AliyunVodPlayerViewStateReplay,        重播
 
 */
- (AliyunVodPlayerViewState)playerViewState;

/**
 * 功能：声音调节,调用系统MPVolumeView类实现，并非视频声音;volume(0~1.0)
 */
- (void)setVolume:(float)volume;

/**
 * 功能：亮度,调用brightness系统属性，brightness(0~1.0)
 */
- (void)setBrightness :(float)brightness;


/*
 功能：获取此播放器版本号
 */
- (NSString*) getSDKVersion;

/*
 功能：隐藏,后续改进隐藏方案;yes：隐藏所有功能按钮界面。
 */
- (void)setBackViewHidden:(BOOL)hidden ;

/*
 功能：设置标题
 */
- (void)setTitle:(NSString *)title ;

/**
 * 功能：获取媒体信息, 当AliyunVodPlayerEventPrepareDone时，才能获取到该参数对象
 */
- (AliyunVodPlayerVideo *)getAliyunMediaInfo;


@end
