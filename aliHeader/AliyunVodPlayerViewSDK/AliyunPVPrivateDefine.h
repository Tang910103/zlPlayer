//
//  AliyunPVPrivateDefine.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/9.
//  Copyright © 2016年 SMY. All rights reserved.
//

#ifndef AliyunPVPrivateDefine_h
#define AliyunPVPrivateDefine_h

typedef NS_ENUM(int, AliyunPVOrientation) {
    AliyunPVOrientationUnknow = 0,
    AliyunPVOrientationHorizontal,
    AliyunPVOrientationVertical
};

typedef NS_ENUM(int, AliyunPVPlayerPopCode) {
    
    // 未知错误
    AliyunPVPlayerPopCodeUnKnown = 0,
    
    // 当用户播放完成后提示用户可以重新播放。    再次观看，请点击重新播放
    AliyunPVPlayerPopCodePlayFinish = 1,
    
    // 用户主动取消播放
    AliyunPVPlayerPopCodeStop = 2,
    
    // 服务器返回错误情况
    AliyunPVPlayerPopCodeServerError= 3,
    
    // 播放中的情况
    // 当网络超时进行提醒（文案统一可以定义），用户点击可以进行重播。      当前网络不佳，请稍后点击重新播放
    AliyunPVPlayerPopCodeNetworkTimeOutError = 4,
    
    // 断网时进行断网提醒，点击可以重播（按记录已经请求成功的url进行请求播放） 无网络连接，检查网络后点击重新播放
    AliyunPVPlayerPopCodeUnreachableNetwork = 5,
    
    // 当视频加载出错时进行提醒，点击可重新加载。   视频加载出错，请点击重新播放
    AliyunPVPlayerPopCodeLoadDataError = 6,
     
    // 当用户使用移动网络播放时，首次不进行自动播放，给予提醒当前的网络状态，用户可手动使用移动网络进行播放。顶部提示条仅显示4秒自动消失。当用户从wifi切到移动网络时，暂定当前播放给予用户提示当前的网络，用户可以点击播放后继续当前播放。
    AliyunPVPlayerPopCodeUseMobileNetwork,
    
};

typedef NS_ENUM(int, AliyunPVNetworkStatus) {
    AliyunPVNetworkNotReachable = 0,
    AliyunPVNetworkReachableViaWiFi,
    AliyunPVNetworkReachableViaWWAN
};


#endif /* AliyunPVPrivateDefine_h */
