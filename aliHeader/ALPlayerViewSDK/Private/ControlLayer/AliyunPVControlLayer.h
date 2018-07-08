//
//  AliyunPVControlLayer.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPVBaseLayer.h"
#import "AliyunPVProgressView.h"
#import "AliyunPVQualityListView.h"
#import "AliyunPVVideo.h"
#import "AliyunPVUtil.h"
#import "AliyunVodPlayerViewDefine.h"
@class AliyunPVControlLayer;
@protocol AliyunPVControlLayerDelegate <NSObject>

/*
 * 功能 ：点击屏幕上的按钮（播放、全屏、锁屏、切换清晰度、倍速选择），提供的回调事件
 */
- (void)AliyunPVControlLayer:(AliyunPVControlLayer *)controlLayer onClickButton:(UIButton *)clickButton;

/*
 * 功能 ：seekto 变动
 */
- (void)AliyunPVControlLayer:(AliyunPVControlLayer *)controlLayer progressViewValueChanged:(float)value ;

/*
 * 功能 ：切换清晰度按钮
 */
- (void)AliyunPVControlLayer:(AliyunPVControlLayer *)controlLayer qualityListViewOnItemClick:(int)index ;

/*
 * 功能 ：切换清晰度按钮，mts清晰度
 */
- (void)AliyunPVControlLayer:(AliyunPVControlLayer *)controlLayer qualityListViewOnDefinitionClick:(NSString*)videoDefinition ;
@end

@interface AliyunPVControlLayer : AliyunPVBaseLayer
//@property (nonatomic, strong)UIButton *downloadBtn;

/*
 * 功能 ：顶部背景
 */
@property (nonatomic, strong) UIImageView *topBarBg;

/*
 * 功能 ：底部背景
 */
@property (nonatomic, strong) UIImageView *bottomBarBg;

/*
 * 功能 ：代理
 */
@property (nonatomic, weak) id<AliyunPVControlLayerDelegate>contrololLayerDelegate;

/*
 * 功能 ：标题
 */
@property (nonatomic, strong) UILabel *titleView;

/*
 * 功能 ：竖屏左侧时间
 */
@property (nonatomic, strong) UILabel *leftTimeView;

/*
 * 功能 ：竖屏右侧时间
 */
@property (nonatomic, strong) UILabel *rightTimeView;

/*
 * 功能 ：全屏时，时间展示
 */
@property (nonatomic, strong) UILabel *fullScreenTimeView;

/*
 * 功能 ：返回按钮
 */
@property (nonatomic, strong) UIButton *backBtn;

/*
 * 功能 ：倍速按钮
 */
@property (nonatomic, strong) UIButton *playSpeedBtn;

/*
 * 功能 ：锁按钮
 */
@property (nonatomic, strong) UIButton *lockBtn;

/*
 * 功能 ：播放按钮
 */
@property (nonatomic, strong) UIButton *playBtn;

/*
 * 功能 ：清晰度切换按钮
 */
@property (nonatomic, strong) UIButton *qualityBtn;

/*
 * 功能 ：全屏按钮
 */
@property (nonatomic, strong) UIButton *fullScreenBtn;

/*
 * 功能 ：seek进度
 */
@property (nonatomic, strong) AliyunPVProgressView *progressView;

/*
 * 功能 ：清晰度列表
 */
@property (nonatomic, strong) AliyunPVQualityListView *qualityListView;

/*
 * 功能 ：竖屏判断
 */
@property (nonatomic, assign) BOOL isProtrait;

/*
 * 功能 ：播放总时长
 */
@property (nonatomic, assign) double duration;

/*
 * 功能 ：当前播放时间
 */
@property (nonatomic, assign) double currentTime;

/*
 * 功能 ：公共参数
 */
@property (nonatomic, strong) AliyunPVVideo *controlLayerVideo;

/*
 * 功能 ：根据播放方式，确定清晰度 名称。
 */
@property (nonatomic, assign) AliyunVodPlayerViewPlayMethod playMethod;

/*
 * 功能 ：更新播放状态
 */
- (void)updateViewWithPlayerState:(AliyunVodPlayerState)state;

/*
 * 功能 ：根据播放状态，更新播放时长ui
 */
- (void)updateTimeView:(double)curTime duration :(double)duration state:(AliyunVodPlayerState)state;

/*
 * 功能 ：隐藏清晰度列表
 */
- (void)hideQualityListView:(BOOL)hidden;

/*
 * 功能 ：设置锁屏时需要隐藏的列表
 * 参数 ：isScreenLocked 是否锁屏
         fixedPortrait 是否时竖屏

 */
- (void)lockScreenWithIsScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait;
/*
 * 功能 ：弹出错误窗口时 取消锁屏。
 * 参数 ：isScreenLocked 是否锁屏
         fixedPortrait 是否时竖屏

 */
- (void)cancelLockScreenWithIsScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait ;

@end
