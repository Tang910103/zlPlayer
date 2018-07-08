//
//  AliyunPVUtil.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVUtil.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

static NSString *ALPV_RESOURCE_BUNDLE_NAME = @"AliyunImageSource.bundle";
static NSString *ALPV_RESOURCE_BUNDLE = @"AliyunImageSource";
static NSString *ALYUN_LANGUAGE_BUNDLE = @"AliyunLanguageSource";

static const int ALPV_TITLE_TEXT_SIZE = 36;
static const int ALPV_NOMAL_TEXT_SIZE = 28;
static const int ALPV_SMALL_TEXT_SIZE = 24;
static const int ALPV_SMALLER_TEXT_SIZE = 20;

#define ALPLAYERVIEW_VERSION @"3.4.5"

@implementation AliyunPVUtil

+ (NSString*)getSDKVersion{
    return ALPLAYERVIEW_VERSION;
}

+ (NSBundle *)resourceBundle {
    NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:ALPV_RESOURCE_BUNDLE ofType:@"bundle"]];
    if (!resourceBundle) {
        resourceBundle = [NSBundle mainBundle];
    }
    return resourceBundle;
}

+ (NSBundle *)languageBundle {
    NSBundle *resourceBundle = [NSBundle mainBundle];
    return resourceBundle;
}

+ (UIImage *)imageWithNameInBundle:(NSString *)nameInBundle {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", ALPV_RESOURCE_BUNDLE_NAME, nameInBundle]];
}

+ (UIImage *)imageWithNameInBundle:(NSString *)name skin:(AliyunVodPlayerViewSkin)skin{
    UIImage *img = [AliyunPVUtil imageWithNameInBundle:name];
    if (!img) {
        NSString *suffix = @"blue";
        
        switch (skin) {
            case AliyunVodPlayerViewSkinBlue:
            default:
                suffix = @"blue";
                break;
            case AliyunVodPlayerViewSkinRed:
                suffix = @"red";
                break;
            case AliyunVodPlayerViewSkinOrange:
                suffix = @"orange";
                break;
            case AliyunVodPlayerViewSkinGreen:
                suffix = @"green";
                break;
        }
        img = [AliyunPVUtil imageWithNameInBundle:[NSString stringWithFormat:@"%@_%@", name, suffix]];
    }
    return img;
    
}


+ (BOOL)isInterfaceOrientationPortrait {
    UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
    return o == UIInterfaceOrientationPortrait;
}

+ (void)setFullOrHalfScreen {
    BOOL isFull = [self isInterfaceOrientationPortrait];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = isFull ? UIInterfaceOrientationLandscapeRight:UIInterfaceOrientationPortrait;
        
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
}


+ (NSString *)timeformatFromSeconds:(NSInteger)seconds {
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld", (long) seconds / 3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long) (seconds % 3600) / 60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long) seconds % 60];
    //format of time
    NSString *format_time = nil;
//    if (seconds / 3600 <= 0) {
//        format_time = [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
//    } else {
        format_time = [NSString stringWithFormat:@"%@:%@:%@", str_hour, str_minute, str_second];
//    }
    return format_time;
}

+ (void)drawFillRoundRect:(CGRect)rect radius:(CGFloat)radius color:(UIColor *)color context:(CGContextRef)context {
    CGContextSetAllowsAntialiasing(context, TRUE);
    CGContextSetFillColor(context, CGColorGetComponents(color.CGColor));
    //    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
    CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    CGContextClosePath(context);
    CGContextFillPath(context);
}



+ (UIColor *)textColor:(AliyunVodPlayerViewSkin)skin{
    UIColor *color = nil;
    switch (skin) {
        case AliyunVodPlayerViewSkinBlue:
            color = UIColorFromRGB(0x379DF2);
            break;
        case AliyunVodPlayerViewSkinRed:
            color = UIColorFromRGB(0xE94033);
            break;
        case AliyunVodPlayerViewSkinOrange:
            color = UIColorFromRGB(0xEE7C33);
            break;
        case AliyunVodPlayerViewSkinGreen:
            color = UIColorFromRGB(0x57AB44);
            break;
            
        default:
            break;
    }
    return color;
}

+ (float)convertPixelToPoint:(float)px {
    if (px < 0) {
        return 0;
    }
    return px / 2;
}

+ (float)titleTextSize {
    return ALPV_TITLE_TEXT_SIZE / 2.0;
}

+ (float)nomalTextSize {
    return ALPV_NOMAL_TEXT_SIZE / 2.0;
}

+ (float)smallTextSize {
    return ALPV_SMALL_TEXT_SIZE / 2.0;
}

+ (float)smallerTextSize {
    return ALPV_SMALLER_TEXT_SIZE / 2.0;
}



//"fd_definition" = "流畅";
//"ld_definition" = "标清";
//"sd_definition" = "高清";
//"hd_definition" = "超清";
//"2k_definition" = "2K";
//"4k_definition" = "4K";
//"od_definition" = "OD";
//获取所有已知清晰度泪飙
+ (NSArray<NSString *> *)allQualitys {
    NSBundle *resourceBundle = [AliyunPVUtil languageBundle];
    return @[NSLocalizedStringFromTableInBundle(@"FD", nil, resourceBundle, nil),
             NSLocalizedStringFromTableInBundle(@"LD", nil, resourceBundle, nil),
             NSLocalizedStringFromTableInBundle(@"SD", nil, resourceBundle, nil),
             NSLocalizedStringFromTableInBundle(@"HD", nil, resourceBundle, nil),
             NSLocalizedStringFromTableInBundle(@"2K", nil, resourceBundle, nil),
             NSLocalizedStringFromTableInBundle(@"4K", nil, resourceBundle, nil),
             NSLocalizedStringFromTableInBundle(@"OD", nil, resourceBundle, nil),
             ];
}


+ (void)setPlayFinishTips:(NSString *)des{
    ALIYUNVODVIEW_PLAYFINISH = des;
}

+ (NSString *)playFinishTips{
    return ALIYUNVODVIEW_PLAYFINISH;
}

+ (void)setNetworkTimeoutTips:(NSString *)des{
    ALIYUNVODVIEW_NETWORKTIMEOUT = des;
}

+ (NSString *)networkTimeoutTips{
    return ALIYUNVODVIEW_NETWORKTIMEOUT;
}

+ (void)setNetworkUnreachableTips:(NSString *)des{
    ALIYUNVODVIEW_NETWORKUNREACHABLE = des;
}

+ (NSString *)networkUnreachableTips{
    return ALIYUNVODVIEW_NETWORKUNREACHABLE;
}

+ (void)setLoadingDataErrorTips:(NSString *)des{
    ALIYUNVODVIEW_LOADINGDATAERROR = des;
}

+ (NSString*)loadingDataErrorTips{
    return ALIYUNVODVIEW_LOADINGDATAERROR;
}

+ (void)setSwitchToMobileNetworkTips:(NSString *)des{
    ALIYUNVODVIEW_USEMOBILENETWORK = des;
}
+ (NSString *)switchToMobileNetworkTips{
    return ALIYUNVODVIEW_USEMOBILENETWORK;
}
@end
