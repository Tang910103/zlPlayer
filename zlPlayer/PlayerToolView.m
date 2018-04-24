//
//  PlayerToolView.m
//  zlPlayer
//
//  Created by Tang杰 on 2018/4/22.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import "PlayerToolView.h"
#import "SBControlView.h"
#import "Masonry.h"
#import "PlayerTool.h"
#import "PlayerManager.h"
#import "BrightnessView.h"
#import <MediaPlayer/MediaPlayer.h>

#define kWindow [UIApplication sharedApplication].keyWindow

typedef NS_ENUM(NSUInteger, Direction) {
    DirectionLeftOrRight,
    DirectionUpOrDown,
    DirectionNone
};

@interface PlayerToolView ()
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UILabel *titleLabel;
//开始滑动的点
@property (assign, nonatomic) CGPoint                  startPoint;
//开始滑动时的亮度
@property (assign, nonatomic) CGFloat                  startVB;
//滑动方向
@property (assign, nonatomic) Direction                direction;

//底部控制视图
@property (nonatomic,strong) SBControlView *controlView;

@property (nonatomic, strong) UIVisualEffectView       *effectView;
//亮度图标
@property (nonatomic, strong) BrightnessView             *lightView;

@property (nonatomic, strong) UISlider                 *volumeViewSlider;

@property (nonatomic, strong) UILabel *timerLabel;

@end

@implementation PlayerToolView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.equalTo(@40);
        }];
        [self addSubview:self.controlView];
        [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self);
            make.height.mas_equalTo(@44);
        }];
        
        _timerLabel = [[UILabel alloc] init];
        _timerLabel.backgroundColor = [UIColor lightGrayColor];
        _timerLabel.textColor = [UIColor whiteColor];
        _timerLabel.font = [UIFont systemFontOfSize:13];
        _timerLabel.layer.cornerRadius = 4.f;
        _timerLabel.layer.masksToBounds = YES;
        _timerLabel.hidden = YES;
        [self addSubview:_timerLabel];
        [_timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom);
            make.centerX.equalTo(self);
            make.height.equalTo(@20);
        }];
        
        //系统的音量
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        _volumeViewSlider = nil;
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider *)view;
                break;
            }
        }
        
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
//        [self addGestureRecognizer:pan];
    }
    return self;
}
#pragma mark - public
- (void)updateTotalTime:(CMTime)timer {
    CGFloat second = timer.value/timer.timescale;
    self.controlView.totalTime = [PlayerTool convertTime:second];
    self.controlView.maxValue = second;
}
- (void)updatePlayTime:(CMTime)timer {
    CGFloat second = timer.value/timer.timescale;
    self.controlView.currentTime = [PlayerTool convertTime:second];
    self.controlView.value = second;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    //记录首次触摸坐标
    self.startPoint = point;
    //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
    if (self.startPoint.x <= self.frame.size.width / 2.0) {
        //亮度
        self.startVB = [UIScreen mainScreen].brightness;
    } else {
        //音/量
        self.startVB = self.volumeViewSlider.value;
    }
    //方向置为无
    self.direction = DirectionNone;
    //记录当前视频播放的进度
//    NSTimeInterval current = self.player.currentPlaybackTime;
//    NSTimeInterval total = self.player.duration;
//    self.startVideoRate = current/total;
    
}
#pragma mark - 结束触摸
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    //得出手指在Button上移动的距离
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    if (self.direction == DirectionLeftOrRight) {
        CGFloat value = panPoint.x + self.controlView.value;
        if (value < 0 ) {
            value = 0;
        }
        if (value > self.controlView.maxValue) {
            value = self.controlView.maxValue;
        }
        [[PlayerManager defaultManager] seekToSecond:value];
        self.timerLabel.hidden = YES;
    }
    else if (self.direction == DirectionUpOrDown){
        [self hideTheLightViewWithHidden:YES];
    }
}

#pragma mark - 拖动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    //得出手指在Button上移动的距离
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    //分析出用户滑动的方向
    if (self.direction == DirectionNone) {
        if (panPoint.x >= 30 || panPoint.x <= -30) {
            //进度
            self.direction = DirectionLeftOrRight;
        } else if (panPoint.y >= 30 || panPoint.y <= -30) {
            //音量和亮度
            self.direction = DirectionUpOrDown;
        }
    }
    
    if (self.direction == DirectionNone) {
        return;
    } else if (self.direction == DirectionUpOrDown) {
        CGFloat value = self.startVB - (panPoint.y / 300);
        //音量和亮度
        if (self.startPoint.x <= self.frame.size.width / 2.0) {
            //调节亮度
            [self hideTheLightViewWithHidden:NO];
//            NSLog(@"亮度：%f",self.startVB - (panPoint.y / 200));
            [[UIScreen mainScreen] setBrightness:value];
            if (value < 1/16) {
                value = 1/16;
            }
            //实时改变现实亮度进度的view
            [self.lightView changeLightViewWithValue:value];
            
        } else {
            //音量
            [self.volumeViewSlider setValue:value];
        }
    } else if (self.direction == DirectionLeftOrRight ) {
//        进度
        CGFloat value = panPoint.x + self.controlView.value;
        if (value < 0 ) {
            value = 0;
        }
        if (value > self.controlView.maxValue) {
            value = self.controlView.maxValue;
        }
        self.timerLabel.hidden = NO;
        NSString *timer = [NSString stringWithFormat:@"  %@/%@  ",[PlayerTool convertTime:value],self.controlView.totalTime];
        self.timerLabel.text = timer;
        NSLog(@"%f  %@",value,NSStringFromCGPoint(panPoint));
    }
}
#pragma mark - private
// 用来控制显示亮度的view, 以及毛玻璃效果的view
-(void)hideTheLightViewWithHidden:(BOOL)hidden{
    if (hidden) {
        [kWindow bringSubviewToFront:self.effectView];
        [UIView animateWithDuration:1.5 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.lightView.alpha = 0.0;
            self.effectView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            [self.lightView removeFromSuperview];
            self.lightView = nil;
            [self.effectView removeFromSuperview];
            self.effectView = nil;
        }];
        
    }else{
        if (!self.effectView) {
            //亮度
            UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            _effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
            _effectView.alpha = 0.0;
            _effectView.contentView.layer.cornerRadius = 10.0;
            _effectView.layer.masksToBounds = YES;
            _effectView.layer.cornerRadius = 10.0;
            
            self.lightView = [[BrightnessView alloc] init];
            self.lightView.alpha = 0.0;
            [_effectView.contentView addSubview:self.lightView];
            
            [self.lightView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.effectView);
            }];
            
            [kWindow addSubview:_effectView];
            [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.effectView.superview);
                make.width.equalTo(@(155));
                make.height.equalTo(@155);
            }];
        }
        [kWindow bringSubviewToFront:self.effectView];
        self.alpha = 1.0;
        self.lightView.alpha = 1.0;
        self.effectView.alpha = 1.0;
    }
}
- (void)exitFullScreen {
    if ([self.delegate respondsToSelector:@selector(exitFullScreen)]) {
        [self.delegate exitFullScreen];
    }
    [self setIsFullScreen:NO];
}
#pragma mark - event response
- (void)panGesture:(UIPanGestureRecognizer *)panGesture {
    
    if (UIGestureRecognizerStateChanged == panGesture.state) {
        CGPoint location  = [panGesture locationInView:panGesture.view];
        CGPoint translation = [panGesture translationInView:panGesture.view];
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
        
#define FULL_VALUE 200.0f
        CGFloat percent = translation.y / FULL_VALUE;
        if (location.x > self.bounds.size.width / 2) {// 调节音量
            NSLog(@"调节音量%@",NSStringFromCGPoint(translation));
//            CGFloat volume = [self.player getVolume];
//            volume -= percent;
//            if (volume < 0.01) {
//                volume = 0.01;
//            } else if (volume > 3) {
//                volume = 3;
//            }
//            [self.player setVolume:volume];
        } else {// 调节亮度f
            CGFloat currentBrightness = [[UIScreen mainScreen] brightness];
            currentBrightness -= percent;
            if (currentBrightness < 0.1) {
                currentBrightness = 0.1;
            } else if (currentBrightness > 1) {
                currentBrightness = 1;
            }
            
            [[UIScreen mainScreen] setBrightness:currentBrightness];
            NSLog(@"调节音量%@",NSStringFromCGPoint(translation));
        }
    }
}

#pragma mark - getter/setter
- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
    self.controlView.delegate = delegate;
}
- (void)setIsPlaying:(BOOL)isPlaying
{
    _isPlaying = isPlaying;
    self.controlView.isPlaying = isPlaying;
}
- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.height.equalTo(_topView);
        make.width.equalTo(isFullScreen ? self.topView.mas_height : @0);
    }];
    
    self.menuButton.hidden = !isFullScreen;
}
- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}
//懒加载控制视图
- (SBControlView *)controlView{
    if (!_controlView) {
        _controlView = [[SBControlView alloc]init];
        _controlView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _controlView.minValue = 0;
        //        [_controlView.tapGesture requireGestureRecognizerToFail:self.pauseOrPlayView.imageBtn.gestureRecognizers.firstObject];
    }
    return _controlView;
}
- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = self.controlView.backgroundColor;
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[PlayerTool imageWithName:@"返回"] forState:UIControlStateNormal];
        [_topView addSubview:backButton];
        [backButton addTarget:self action:@selector(exitFullScreen) forControlEvents:UIControlEventTouchUpInside];
        _backButton = backButton;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.numberOfLines = 1;
        [_topView addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:[PlayerTool imageWithName:@"更多"] forState:UIControlStateNormal];
        menuButton.hidden = YES;
        [_topView addSubview:menuButton];
        _menuButton = menuButton;
        
        [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.height.equalTo(_topView);
            make.width.equalTo(@0);
        }];
        [menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.height.equalTo(_topView);
            make.width.equalTo(menuButton.mas_height);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backButton.mas_right).offset(15);
            make.centerY.equalTo(_topView);
            make.right.equalTo(menuButton.mas_left);
        }];
    }
    return _topView;
}
@end
