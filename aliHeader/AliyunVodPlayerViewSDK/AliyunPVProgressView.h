//
//  AliyunPVProgressView.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/9.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPVPrivateDefine.h"
#import "AliyunVodPlayerViewDefine.h"

/*
 * 功能 ：seek 小球 状态。
 */

typedef NS_ENUM(int, AliyunPVTrackThumbState) {
    AliyunPVTrackThumbStateIdle,
    AliyunPVTrackThumbStateMoveBegin,
    AliyunPVTrackThumbStateMoving,
    AliyunPVTrackThumbStateMoveEnd
};


@protocol AliyunPVProgressViewDelegate <NSObject>

/*
 * 功能 ：seek 进度条
 */
- (void)progressViewValueChanged:(float)value;
@end


@interface AliyunPVTrackBall : UIImageView <UIGestureRecognizerDelegate>
/*
 * 功能 ：代理
 */
@property (nonatomic, weak) id<AliyunPVProgressViewDelegate> delegate;

/*
 * 功能 ：小球左右移动的最小值，最大值
 */
@property (nonatomic, assign) float minX;
@property (nonatomic, assign) float maxX;

/*
 * 功能 ：同步更新进度调滑块状态代理
 */
@property (atomic) AliyunPVTrackThumbState state;

@end


@interface AliyunPVProgressView : UIControl

/*
 * 功能 ：代理
 */
@property (nonatomic, weak) id<AliyunPVProgressViewDelegate> delegate;

/*
 * 功能 ：左右移动的最小值，最大值
 */
@property (nonatomic, assign) float max;
@property (nonatomic, assign) float min;

/*
 * 功能 ：currentTime进度条
 */
@property (nonatomic, assign) float progress;

/*
 * 功能 ：loadtime 进度条
 */
@property (nonatomic, assign) float secondaryProgress;

/*
 * 功能 ：同步同步更新小球状态小球状态代理
 */
@property (nonatomic, assign) AliyunPVTrackThumbState trackThumbState;

/*
 * 功能 ：进度条上的移动小球
 */
@property (nonatomic, strong) AliyunPVTrackBall *thumb;

/*
 * 功能 ：皮肤
 */
@property (nonatomic, assign) AliyunVodPlayerViewSkin prgressViewSkin;

/*
 * 功能 ：开始移动的方向
 * 参数 ：AliyunPVOrientation 移动方向
 */
- (void)moveBegin:(AliyunPVOrientation)orientation;

/*
 * 功能 ：移动中进度
 * 参数 ：progress 偏移量
 */
- (void)movingTo:(float)progress;

/*
 * 功能 ：移动结束
 * 参数 ：AliyunPVOrientation 移动方向
 */
- (void)moveEnd:(AliyunPVOrientation)orientation;

/*
 * 功能 ：是否处理消息事件，touch等
 * 参数 ：userInteractionEnabled 是否禁用手势
 */
- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled;
@end
