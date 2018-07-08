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
@protocol AliyunPVPlaySpeedViewDelegate

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
@end
