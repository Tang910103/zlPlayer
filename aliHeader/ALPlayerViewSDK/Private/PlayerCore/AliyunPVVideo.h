//
//  AliyunPVVideo.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/11.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunVodPlayerVideo.h"
#import "AliyunPVPrivateDefine.h"

@interface AliyunPVVideo : NSObject
@property (nonatomic, strong) AliyunVodPlayerVideo *video;
@property (nonatomic, strong, readonly) NSString *videoId;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, assign, readonly) double duration; //秒

- (instancetype)initWithPlayerVideo:(AliyunVodPlayerVideo *)video;

- (NSArray *)allSupportQualitys;

@end
