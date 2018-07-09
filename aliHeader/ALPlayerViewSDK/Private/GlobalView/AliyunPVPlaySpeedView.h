//
//  AliyunPVPlaySpeedView.h
//  AliyunVodPlayerViewSDK
//
//  Created by 王凯 on 2017/10/11.
//  Copyright © 2017年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPVUtil.h"

@class AliyunPVPlaySpeedView;
@protocol AliyunPVPlaySpeedViewDelegate<NSObject>
/*
 * 功能 ：播放方式，是否自动连播
 */
- (void)AliyunPVPlaySpeedView:(AliyunPVPlaySpeedView*)playSpeedView isAutomaticFlow:(BOOL)isAutomaticFlow;
/*
 * 功能 ：显示模式，选择的显示模式
 */
- (void)AliyunPVPlaySpeedView:(AliyunPVPlaySpeedView*)playSpeedView displayMode:(AliyunVodPlayerDisplayMode)displayMode;

/*
 * 功能 ：倍速播放，选择的倍速值
 */
- (void)AliyunPVPlaySpeedView:(AliyunPVPlaySpeedView*)playSpeedView playSpeed:(AliyunVodPlayerViewPlaySpeed)playSpeed;
@end

@interface AliyunPVPlaySpeedView : UIView
/*
 * 功能 ：皮肤
 */
@property (nonatomic, assign) AliyunVodPlayerViewSkin skin;
/*
 * 功能 ：代理
 */
@property (nonatomic, weak) id<AliyunPVPlaySpeedViewDelegate>playSpeedViewDelegate;
/**
 * 功能：获取/设置显示模式
 * 显示模式有： AliyunVodPlayerDisplayModeFit,            // 保持原始比例
 AliyunVodPlayerDisplayModeFitWithCropping // 全屏占满屏幕
 */
@property (nonatomic,assign) AliyunVodPlayerDisplayMode displayMode;
/** 是否自动连播 */
@property (nonatomic, assign) BOOL isAutomaticFlow;
@end
