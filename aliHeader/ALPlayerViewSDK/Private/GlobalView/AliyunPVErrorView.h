//
//  ALPVErrorMessageView.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/13.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunVodPlayerViewDefine.h"

@protocol AliyunPVErrorViewDelegate <NSObject>

/*
 * 功能 ：错误状态提示
 */
- (void)onErrorViewClickWithErrorType:(NSString *)type;
@end

@interface AliyunPVErrorView : UIView

/*
 * 功能 ：代理
 */
@property (nonatomic, weak) id<AliyunPVErrorViewDelegate> delegate;

/*
 * 功能 ：皮肤
 */
@property (nonatomic, assign) AliyunVodPlayerViewSkin errorStytleSkin;

/*
 * 功能 ：设置错误消息
 */
- (void)setMessage:(NSString *)message;

/*
 * 功能 ：设置错误按钮文本，按钮当前状态
 */
- (void)setButtonText:(NSString *)text eventType:(NSString *)type;

/*
 * 功能 ：展示错误页面偏移量
 */
- (void)showWithParentView:(UIView *)parent;

/*
 * 功能 ：是否展示界面
 */
- (BOOL)isShowing;

/*
 * 功能 ：是否删除界面
 */
- (void)dismiss;

@end
