//
//  AliyunPVSeekPopupView.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/12.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunVodPlayerViewDefine.h"

@protocol AliyunPVSeekPopupViewDelegate <NSObject>

/*
 * 功能 ：手势在播放界面上左右移动的位移
 */
- (void)seekPopupViewValueChanged:(float)value;
@end

@interface AliyunPVSeekPopupView : UIView

/*
 * 功能 ：代理
 */
@property (nonatomic, weak) id<AliyunPVSeekPopupViewDelegate> delegate;

/*
 * 功能 ：seek方向
 */
@property (nonatomic, assign) int direction; // left = 0, rignt = 1

/*
 * 功能 ：皮肤
 */
@property (nonatomic, assign) AliyunVodPlayerViewSkin seekSkin;


- (void)setTime:(double)time direction:(int)direction;
- (void)showWithParentView:(UIView *)parent;
- (void)dismiss;
- (BOOL)isShowing;
- (void)onPanFinished;

@end
