//
//  AliyunPVVideo.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/11.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVVideo.h"

@implementation AliyunPVVideo

- (instancetype)init {
    return [self initWithPlayerVideo:nil];
}

- (instancetype)initWithPlayerVideo:(AliyunVodPlayerVideo *)video {
    self = [super init];
    if (self) {
        self.video = video;
    }
    return self;
}

- (NSString *)videoId {
    return self.video.videoId;
}

- (NSString *)title {
    return self.video.title;
}

- (double)duration {
    return self.video.duration;
}
    
- (NSArray *)allSupportQualitys {
    return [self.video allSupportQualitys];
}

@end
