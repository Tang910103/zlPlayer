//
//  AliyunPVProgressView.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/9.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVProgressView.h"
#import "AliyunPVUtil.h"
#import <math.h>
#import "AliyunPVBaseLayer.h"
@implementation AliyunPVTrackBall

/*
 * 功能 ：便利初始化函数
 */
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

/*
 * 功能 ：指定初始化函数
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //添加左右移动手势操作
        UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlePanAction:)];
        [self addGestureRecognizer:panGestureRecognizer];
        self.userInteractionEnabled = true;
        self.state = AliyunPVTrackThumbStateIdle;
    }
    return self;
}

/*
 * 功能 ：重绘
 */
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

#pragma mark - doHandlePanAction
- (void) doHandlePanAction:(UIPanGestureRecognizer *)paramSender {
    CGPoint point = [paramSender translationInView:self];
    float x = paramSender.view.center.x + point.x;
    if (x < self.minX) {
        x = self.minX;
    }
    if (x > self.maxX) {
        x = self.maxX;
    }
    paramSender.view.center = CGPointMake(x, self.superview.bounds.size.height / 2);
    // 清空每次触摸的产生的位移
    [paramSender setTranslation:CGPointZero inView:self];
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        float progress = x / (self.maxX - self.minX);
        if (self.delegate) {
            [self.delegate progressViewValueChanged:progress];
        }
        self.state = AliyunPVTrackThumbStateMoveEnd;
    } else if(paramSender.state == UIGestureRecognizerStateBegan) {
        self.state = AliyunPVTrackThumbStateMoving;
    }
}

@end

static const int ALYPV_PROGRESS_HEIGHT = 4;
@interface AliyunPVProgressView ()
@end
@implementation AliyunPVProgressView

/*
 * 功能 ：便利初始化函数
 */
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

/*
 * 功能 ：指定初始化函数
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.min = 0;
        self.max = 1;
        self.progress = 0;
        self.secondaryProgress = 0;
        _thumb = [[AliyunPVTrackBall alloc] init];
        [self addSubview:_thumb];
    }
    return self;
}


- (void)setPrgressViewSkin:(AliyunVodPlayerViewSkin)prgressViewSkin{
    _prgressViewSkin = prgressViewSkin;
    [_thumb setImage:[AliyunPVUtil imageWithNameInBundle:@"al_play_settings_radiobtn_normal" skin:prgressViewSkin]];
}

- (void)setTrackThumbState:(AliyunPVTrackThumbState)state {
    [_thumb setState:state];
}

- (AliyunPVTrackThumbState)trackThumbState {
    return [_thumb state];
}

- (void)setDelegate:(id<AliyunPVProgressViewDelegate>)delegate {
    _delegate = delegate;
    [_thumb setDelegate:delegate];
}

- (void)setProgress:(float)progress {
    if (_thumb.state == AliyunPVTrackThumbStateIdle) {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)setSecondaryProgress:(float)secondaryProgress {
    _secondaryProgress = secondaryProgress;
    [self setNeedsDisplay];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [_thumb setUserInteractionEnabled:userInteractionEnabled];
    [super setUserInteractionEnabled:userInteractionEnabled];
}

#pragma mark - moveBegin
- (void)moveBegin:(AliyunPVOrientation)orientation {
    if (![self isUserInteractionEnabled]) {
        return;
    }
    if (orientation != AliyunPVOrientationHorizontal) {
        return;
    }
    _thumb.state = AliyunPVTrackThumbStateMoving;
}

#pragma mark - movingTo
- (void)movingTo:(float)progress {
    if (isnan(progress)) {
        progress = 0;
    }
    if (![self isUserInteractionEnabled]) {
        return;
    }
    float x = progress * self.bounds.size.width;
    
    if (x < 0) {
        x = 0;
    }
    if (x > self.bounds.size.width) {
        x = self.bounds.size.width;
    }
    _thumb.center = CGPointMake(x, self.bounds.size.height / 2);
}

#pragma mark - moveEnd
- (void)moveEnd:(AliyunPVOrientation)orientation {
    if (![self isUserInteractionEnabled]) {
        return;
    }
    _thumb.state = AliyunPVTrackThumbStateMoveEnd;
    if (orientation != AliyunPVOrientationHorizontal) {
        return;
    }
    if (self.delegate) {
        [self.delegate progressViewValueChanged:(_thumb.center.x / self.bounds.size.width)];
    }
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    float ballWidth= _thumb.image.size.width;
    float ballHeight = _thumb.image.size.height;
    _thumb.frame = CGRectMake(0, (bounds.size.height - ballHeight) / 2, ballWidth, ballHeight);
    [_thumb setMinX:0];
    [_thumb setMaxX:self.bounds.size.width];
    [self setNeedsDisplay];
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    float progressHeight = [AliyunPVUtil convertPixelToPoint:ALYPV_PROGRESS_HEIGHT];
    float radius = progressHeight / 2;
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    // save the context
    CGContextSaveGState(context);
    // allow antialiasing
    CGContextSetAllowsAntialiasing(context, TRUE);
    // draw backgroud progress
    CGRect progressBackgroundRect = CGRectMake(0, (height - progressHeight) / 2, width, progressHeight);
    [AliyunPVUtil drawFillRoundRect:progressBackgroundRect radius:radius color:ALPV_PROGRESS_BACKGROUND context:context];
    // draw secondary progress
    float secondaryWidth = (self.min + self.secondaryProgress * (self.max - self.min)) * width;
    CGRect secondaryProgress = CGRectMake(0, (height - progressHeight) / 2, secondaryWidth, progressHeight);
    [AliyunPVUtil drawFillRoundRect:secondaryProgress radius:radius color:ALPV_PROGRESS_SECONDARY context:context];
    // draw current progress
    float progressWidth = (self.min + self.progress * (self.max - self.min)) * width;
    CGRect currentRect = CGRectMake(0, (height - progressHeight) / 2, progressWidth, progressHeight);
    /*
     CGRect frame= currentRect;
     frame.size.width = NAN;
     currentRect = frame;
     考虑wide=NAN判定，如果是NAN load进度=0，不判定会崩溃。
     */
    if (isnan(currentRect.size.width)) {
        CGRect frame = currentRect;
        frame.size.width = 0;
        currentRect = frame;
        
    }
    //ALPV_PROGRESS
    [AliyunPVUtil drawFillRoundRect:currentRect radius:radius color:[AliyunPVUtil textColor:self.prgressViewSkin] context:context];
    if (_thumb.state == AliyunPVTrackThumbStateIdle) {
        if (!isnan(progressWidth)) {
            _thumb.center = CGPointMake(progressWidth, height / 2);
        }
    }
    CGContextRestoreGState(context);
}

@end


