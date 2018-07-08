//
//  AliyunPVUtil.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AliyunVodPlayerViewDefine.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface AliyunPVUtil : NSObject

//version
+ (NSString*)getSDKVersion;

//图片库bundle
+ (NSBundle *)resourceBundle;

//语言库bundle
+ (NSBundle *)languageBundle;

//从图片库获取图片
+ (UIImage *)imageWithNameInBundle:(NSString *)nameInBundle;

//根据皮肤颜色获取图片
+ (UIImage *)imageWithNameInBundle:(NSString *)name skin:(AliyunVodPlayerViewSkin)skin;

//是否手机状态条处于竖屏状态
+ (BOOL)isInterfaceOrientationPortrait;

//是否全屏
+ (void)setFullOrHalfScreen;

//根据s-》hh:mm:ss
+ (NSString *)timeformatFromSeconds:(NSInteger)seconds;

//绘制
+ (void)drawFillRoundRect:(CGRect)rect radius:(CGFloat)radius color:(UIColor *)color context:(CGContextRef)context;
//皮肤字体颜色
+ (UIColor *)textColor:(AliyunVodPlayerViewSkin)skin;

//根据像素值获取 px/2
+ (float)convertPixelToPoint:(float)px;

/*
 * 定义字体大小，font
 */
+ (float)titleTextSize;
+ (float)nomalTextSize;
+ (float)smallTextSize;
+ (float)smallerTextSize;

//获取所有已知清晰度泪飙
+ (NSArray<NSString *> *)allQualitys;

/*
 * 设置提示语
 */

//播放完成描述
+ (void)setPlayFinishTips:(NSString *)des;

+ (NSString *)playFinishTips;

//网络超时
+ (void)setNetworkTimeoutTips:(NSString *)des;

+ (NSString *)networkTimeoutTips;

//无网络状态
+ (void)setNetworkUnreachableTips:(NSString *)des;

+ (NSString *)networkUnreachableTips;

//加载数据错误
+ (void)setLoadingDataErrorTips:(NSString *)des;

+ (NSString*)loadingDataErrorTips;

//网络切换
+ (void)setSwitchToMobileNetworkTips:(NSString *)des;

+ (NSString *)switchToMobileNetworkTips;

@end
