//
//  AliyunPVGifView.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/13.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVGifView.h"
#import "AliyunPVUtil.h"
#import <ImageIO/ImageIO.h>

static const int ALYPV_ANIMATION_REPEAT = 3600;
@interface AliyunPVGifView () <CAAnimationDelegate>

@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, strong) NSMutableArray *frameDelayTimes;
@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, strong) CAKeyframeAnimation *animation;

@end

@implementation AliyunPVGifView

#pragma mark - 便利初始化方法函数
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

#pragma mark - 指定初始化方法函数
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _frames = [[NSMutableArray alloc] init];
        _frameDelayTimes = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - setGifImageWithName
- (void)setGifImageWithName:(NSString *)name {
    [self reset];
    NSURL *url = [[AliyunPVUtil resourceBundle] URLForResource:name withExtension:@"gif"];
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef) url, NULL);
    size_t frameCount = CGImageSourceGetCount(gifSource);
    for (size_t i = 0; i < frameCount; ++i) {
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [_frames addObject:(__bridge id)(frame)];
        CGImageRelease(frame);
        NSDictionary *dict = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
        NSDictionary *gifDict = [dict valueForKey:(NSString *) kCGImagePropertyGIFDictionary];
        [_frameDelayTimes addObject:[gifDict valueForKey:(NSString *) kCGImagePropertyGIFDelayTime]];
        _totalTime += [[gifDict valueForKey:(NSString *) kCGImagePropertyGIFDelayTime] floatValue];
    }
    if (gifSource) {
        CFRelease(gifSource);
    }
    _animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:3];
    CGFloat currentTime = 0;
    int count = (int) _frameDelayTimes.count;
    for (int i = 0; i < count; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / _totalTime)]];
        currentTime += [[_frameDelayTimes objectAtIndex:i] floatValue];
    }
    [_animation setKeyTimes:times];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < count; ++i) {
        [images addObject:[_frames objectAtIndex:i]];
    }
    [_animation setValues:images];
    [_animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    _animation.duration = _totalTime;
    _animation.delegate = self;
    _animation.repeatCount = ALYPV_ANIMATION_REPEAT;
}

#pragma mark - startAnimation
- (void)startAnimation {    
    [self.layer addAnimation:_animation forKey:@"gifAnimation"];
}

#pragma mark - stopAnimation
- (void)stopAnimation {
    [self.layer removeAllAnimations];
}

#pragma mark - reset清理数据
- (void)reset {
    [_frames removeAllObjects];
    [_frameDelayTimes removeAllObjects];
    _totalTime = 0;
}



@end
