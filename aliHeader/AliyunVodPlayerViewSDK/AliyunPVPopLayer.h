//
//  AliyunPVPopLayer.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPVBaseLayer.h"
#import "AliyunPVLoadingView.h"
#import "AliyunPVErrorView.h"
#import "AliyunPVUtil.h"
@class AliyunPVPopLayer;

@protocol AliyunPVPopLayerDelegate <NSObject>

/*
 * 功能 ：点击返回时操作
 */
- (void)onBackClickedWithAlPVPopLayer:(AliyunPVPopLayer *)popLayer ;

/*
 * 功能 ：提示错误信息时，当前按钮状态
 */
- (void)onErrorViewClickWithType:(NSString *)typeString;

@end

@interface AliyunPVPopLayer : AliyunPVBaseLayer

/*
 * 功能 ：代理
 */
@property (nonatomic, weak) id<AliyunPVPopLayerDelegate>popLayerDelegate;

/*
 * 功能 ：返回按钮
 */
@property (nonatomic, strong) UIButton *backBtn;

/*
 * 功能 ：错误view
 */
@property (nonatomic, strong) AliyunPVErrorView *errorView;

/*
 * 功能 ：根据不同code，展示弹起的消息界面
 * 参数 ： code ： 事件
          popMsg ： 弹起的界面
 */
- (void)showPopViewWithCode:(AliyunPVPlayerPopCode)code popMsg:(NSString *)popMsg;
@end
