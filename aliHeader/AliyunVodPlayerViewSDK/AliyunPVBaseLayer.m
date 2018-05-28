//
//  AliyunPVBaseLayer.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVBaseLayer.h"
#import "AliyunPVUtil.h"
#import <Math.h>
#import "AliyunPVSeekPopupView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AliyunPVBaseLayer () <UIGestureRecognizerDelegate>

/*
 * 功能 ： 单击手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

/*
 * 功能 ： 双击手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;

/*
 * 功能 ： 滑动手势
 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

/*
 * 功能 ： 声音
 */
@property (nonatomic, assign) float systemVolume;

/*
 * 功能 ： 亮度
 */
@property (nonatomic, assign) float systemBrightness;

/*
 * 功能 ： 临时参数，记录偏移大小
 */
@property (nonatomic, assign) CGPoint currentPoint;

/*
 * 功能 ： 声音设置
 */
@property (nonatomic, strong) MPMusicPlayerController *mMplayer;
@property (nonatomic, assign) CGPoint savePoint;

@end

@implementation AliyunPVBaseLayer

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        [_doubleTapGesture setNumberOfTapsRequired:2];
        // 先检测双击
        [_tapGesture requireGestureRecognizerToFail:_doubleTapGesture];
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _tapGesture.delegate = self;
        _panGesture.delegate = self;
        _doubleTapGesture.delegate = self;
        [_tapGesture setEnabled:NO];
        [_panGesture setEnabled:NO];
        [_doubleTapGesture setEnabled:YES];
        [self addGestureRecognizer:_tapGesture];
        [self addGestureRecognizer:_panGesture];
        [self addGestureRecognizer:_doubleTapGesture];
        self.horizontalOffsetWithPanGesture = 0;
        _mMplayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    return self;
}

- (void)setSkin:(AliyunVodPlayerViewSkin)skin{
    NSLog(@"123");
}
- (void)setEnableGesture:(BOOL)enableGesture {
    [_tapGesture setEnabled:YES];
    [_doubleTapGesture setEnabled:enableGesture];
    [_panGesture setEnabled:enableGesture];
}

- (BOOL)isEnableGesture {
    return [_tapGesture isEnabled] || [_panGesture isEnabled];
}

- (void)onPanBegin:(float)beginPlayTime direction:(AliyunPVDirection)direction {
    if (self.baseDelegate) {
        [self.baseDelegate baseLayer:self gestureState:UIGestureRecognizerStateBegan onPanBegin:0 onPanMoving:0 onPanEnd:0 direction:direction];
    }
}

- (void)onPanMoving:(float)offset direction:(AliyunPVDirection)direction {
    if (self.baseDelegate) {
        [self.baseDelegate baseLayer:self gestureState:UIGestureRecognizerStateChanged onPanBegin:0 onPanMoving:offset onPanEnd:0 direction:direction];
    }
}

- (void)onPanEnd:(float)totalOffset direction:(AliyunPVDirection)direction {
    if (self.baseDelegate) {
        [self.baseDelegate baseLayer:self gestureState:UIGestureRecognizerStateEnded onPanBegin:0 onPanMoving:0 onPanEnd:totalOffset direction:direction];
    }
}

- (void)updateViewWithPlayerState:(AliyunVodPlayerState)state {
    
}

- (void)show {
    
}
- (void)dismiss {
    
}

- (float)pxConvertToPt:(float)px {
    return [AliyunPVUtil convertPixelToPoint:px];
}

#pragma mark - GestureRecognizer
- (void)tap:(UITapGestureRecognizer *)gesture {
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(baseLayer:tapClieckedNumbers:)]) {
        [self.baseDelegate baseLayer:self tapClieckedNumbers:AliyunPVTapClickedEventSingle];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture {
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(baseLayer:tapClieckedNumbers:)]) {
        [self.baseDelegate baseLayer:self tapClieckedNumbers:AliyunPVTapClickedEventDouble];
    }
}

#pragma mark - delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([touch.view isKindOfClass:[UIControl class]]){
        return NO;
    }else{
        return YES;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _currentPoint = [[touches anyObject] locationInView:self];
    _savePoint = [[touches anyObject] locationInView:self];
}

- (void)pan:(UIPanGestureRecognizer *)sender{
    CGPoint point= [sender locationInView:self];// 上下控制点
    CGPoint tranPoint=[sender translationInView:self];//播放进度
    static AliyunPVDirection direction = AliyunPVDirectionNone;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (direction == AliyunPVDirectionNone) {
                CGPoint velocity = [sender velocityInView:self];
                BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
                if (isVerticalGesture) {
                    if (velocity.y > 0) {
                        direction = AliyunPVDirectionDown;
                    } else {
                        direction = AliyunPVDirectionUp;
                    }
                }
                else {
                    if (velocity.x > 0) {
                        direction = AliyunPVDirectionRight;
                    } else {
                        direction = AliyunPVDirectionLeft;
                    }
                }
                [self onPanBegin:0 direction:direction];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            switch (direction) {
                case AliyunPVDirectionUp: {
                    // 左侧 上下改变亮度
                    if(point.x <self.frame.size.width/2){
                        if(_currentPoint.y > point.y){
                            [UIScreen mainScreen].brightness += 0.01;
                        }else{
                            [UIScreen mainScreen].brightness -= 0.01;
                        }
                        if (self.baseDelegate) {
                            [self.baseDelegate baseLayer:self chanageBrightnessValue:[UIScreen mainScreen].brightness direction:direction];
                        }
                        _currentPoint = point;
                    }else{// 右侧上下改变声音
                        if (_savePoint.y>point.y) {
                            [self setVolumeUp];
                        }else if(_savePoint.y<point.y){
                            [self setVolumeDown];
                        }
                        _savePoint = point;
                    }
                    break;
                }
                case AliyunPVDirectionDown: {
                    // 左侧 上下改变亮度
                    if(point.x <self.frame.size.width/2){
                        if(_currentPoint.y > point.y){
                            [self setBrightnessUp];
                        }else{
                            [self setBrightnessDown];
                        }
                        if (self.baseDelegate) {
                            [self.baseDelegate baseLayer:self chanageBrightnessValue:[UIScreen mainScreen].brightness direction:direction];
                        }
                    }else{// 右侧上下改变声音
                        if (_savePoint.y>point.y) {
                            [self setVolumeUp];
                        }else if(_savePoint.y<point.y){
                            [self setVolumeDown];
                        }
                        _savePoint = point;
                    }
                    break;
                }
                case AliyunPVDirectionLeft:
                case AliyunPVDirectionRight: {
                    self.horizontalOffsetWithPanGesture =  tranPoint.x;
                    [self onPanMoving:self.horizontalOffsetWithPanGesture direction:direction];
                    break;
                }
                default: {
                    break;
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self onPanEnd:self.horizontalOffsetWithPanGesture direction:direction];
            direction = AliyunPVDirectionNone;
            self.horizontalOffsetWithPanGesture = 0;
            break;
        }
        default:
            [self onPanEnd:self.horizontalOffsetWithPanGesture direction:direction];
            direction = AliyunPVDirectionNone;
            self.horizontalOffsetWithPanGesture = 0;
            break;
    }
}

- (void)setBrightnessUp{
    if ([UIScreen mainScreen].brightness >=1) {
        return;
    }
    [UIScreen mainScreen].brightness += 0.01;
}
- (void)setBrightnessDown{
    if ([UIScreen mainScreen].brightness <=0) {
        return;
    }
    [UIScreen mainScreen].brightness -= 0.01;
}
- (void)setVolumeUp{
    _systemVolume = [AVAudioSession sharedInstance].outputVolume;
    if (_mMplayer.volume >=1) {
        return;
    }
    _systemVolume = _systemVolume+0.01;
    [_mMplayer setVolume:_systemVolume];
}
- (void)setVolumeDown{
    _systemVolume = [AVAudioSession sharedInstance].outputVolume;
    if (_systemVolume <=0) {
        return;
    }
    _systemVolume = _systemVolume-0.01;
    [_mMplayer setVolume:_systemVolume];
}

@end
