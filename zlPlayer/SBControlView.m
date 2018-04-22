//
//  SBControlView.m
//  SBPlayer
//
//  Created by sycf_ios on 2017/4/10.
//  Copyright © 2017年 shibiao. All rights reserved.
//

#import "SBControlView.h"
#import "Masonry.h"
#import "PlayerTool.h"

@interface SBControlView ()
//当前时间
@property (nonatomic,strong) UILabel *timeLabel;
//总时间
@property (nonatomic,strong) UILabel *totalTimeLabel;
//进度条
@property (nonatomic,strong) UISlider *slider;
//缓存进度条
@property (nonatomic,strong) UISlider *bufferSlier;
//播放按钮
@property (nonatomic, strong) UIButton *playButton;

@end
static NSInteger padding = 8;
@implementation SBControlView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}
//懒加载
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.text = @"00:00";
    }
    return _timeLabel;
}
-(UILabel *)totalTimeLabel{
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc]init];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.font = [UIFont systemFontOfSize:13];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.text = @"00:00";
    }
    return _totalTimeLabel;
}
-(UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc]init];
        [_slider setThumbImage:[PlayerTool imageWithName:@"dian"] forState:UIControlStateNormal];
        _slider.continuous = YES;
        self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [_slider addTarget:self action:@selector(handleSliderPosition:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(handleSliderWillSliding:) forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self action:@selector(handleSliderEndSliding:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addGestureRecognizer:self.tapGesture];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor colorWithRed:0 green:90/255.0 blue:155/255.0 alpha:1.0];
    }
    return _slider;
}
-(UIButton *)largeButton{
    if (!_largeButton) {
        _largeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _largeButton.contentMode = UIViewContentModeScaleToFill;
        [_largeButton setImage:[PlayerTool imageWithName:@"full_screen"] forState:UIControlStateNormal];
        [_largeButton setImage:[PlayerTool imageWithName:@"unfull_screen"] forState:UIControlStateSelected];
        [_largeButton addTarget:self action:@selector(hanleLargeBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _largeButton;
}
-(UISlider *)bufferSlier{
    if (!_bufferSlier) {
        _bufferSlier = [[UISlider alloc]init];
        [_bufferSlier setThumbImage:[UIImage new] forState:UIControlStateNormal];
        _bufferSlier.continuous = YES;
        _bufferSlier.minimumTrackTintColor = [UIColor lightGrayColor];
//        _bufferSlier.maximumTrackTintColor = [UIColor clearColor];
        _bufferSlier.minimumValue = 0.f;
        _bufferSlier.maximumValue = 1.f;
        _bufferSlier.userInteractionEnabled = NO;
    }
    return _bufferSlier;
}
- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[PlayerTool imageWithName:@"播放"] forState:UIControlStateSelected];
        [_playButton setImage:[PlayerTool imageWithName:@"暂停"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

-(void)setupUI{
    [self addSubview:self.timeLabel];
    [self addSubview:self.bufferSlier];
    [self addSubview:self.slider];
    [self addSubview:self.totalTimeLabel];
    [self addSubview:self.largeButton];
    [self addSubview:self.playButton];
    
//    _playButton.backgroundColor = [UIColor redColor];
//    _timeLabel.backgroundColor = [UIColor redColor];
//    _totalTimeLabel.backgroundColor = [UIColor redColor];
//    _largeButton.backgroundColor = [UIColor redColor];
    
    //添加约束
    [self addConstraintsForSubviews];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}
-(void)deviceOrientationDidChange{
    //添加约束
    [self addConstraintsForSubviews];
}
-(void)addConstraintsForSubviews{
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(padding);
        make.top.bottom.mas_equalTo(self);
        make.width.equalTo(self.mas_height);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right);
        make.bottom.height.mas_equalTo(self);
        make.width.mas_equalTo(@55);
        make.centerY.mas_equalTo(@[self.timeLabel,self.playButton,self.slider,self.totalTimeLabel,self.largeButton]);
    }];
    [self.largeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-padding);
        make.width.height.mas_equalTo(self.mas_height);
    }];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.largeButton.mas_left);
        make.bottom.height.mas_equalTo(self);
        make.width.mas_equalTo(self.timeLabel).priorityHigh();
    }];
    [self.slider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_right);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left);
    }];
    
    [self.bufferSlier mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.slider).offset(5);
        make.right.mas_equalTo(self.slider).offset(-5);
        make.center.mas_equalTo(self.slider);
    }];
    [self layoutIfNeeded];
}
-(void)hanleLargeBtn:(UIButton *)button{
    button.selected = !button.selected;
    if ([self.delegate respondsToSelector:@selector(controlView:withLargeButton:)]) {
        [self.delegate controlView:self withLargeButton:button];
    }
}

- (void)clickPlayButton:(UIButton *)button {
    button.selected = !button.selected;
    if ([self.delegate respondsToSelector:@selector(controlView:withPlayButton:)]) {
        [self.delegate controlView:self withPlayButton:self.playButton];
    }
}
-(void)handleSliderWillSliding:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(controlView:sliderWillSliding:)]) {
        [self.delegate controlView:self sliderWillSliding:slider];
    }
}
-(void)handleSliderEndSliding:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(controlView:sliderEndSliding:)]) {
        [self.delegate controlView:self sliderEndSliding:slider];
    }
}
-(void)handleSliderPosition:(UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(controlView:draggedPositionWithSlider:)]) {
        [self.delegate controlView:self draggedPositionWithSlider:self.slider];
    }
}
-(void)handleTap:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self.slider];
    CGFloat pointX = point.x;
    CGFloat sliderWidth = self.slider.frame.size.width;
    CGFloat currentValue = pointX/sliderWidth * self.slider.maximumValue;
    if ([self.delegate respondsToSelector:@selector(controlView:pointSliderLocationWithCurrentValue:)]) {
        [self.delegate controlView:self pointSliderLocationWithCurrentValue:currentValue];
    }
}

//setter 和 getter方法
-(void)setValue:(CGFloat)value{
    self.slider.value = value;
}
-(CGFloat)value{
    return self.slider.value;
}
-(void)setMinValue:(CGFloat)minValue{
    self.slider.minimumValue = minValue;
}
-(CGFloat)minValue{
    return self.slider.minimumValue;
}
-(void)setMaxValue:(CGFloat)maxValue{
    self.slider.maximumValue = maxValue;
}
-(CGFloat)maxValue{
    return self.slider.maximumValue;
}
-(void)setCurrentTime:(NSString *)currentTime{
    self.timeLabel.text = currentTime;
}
-(NSString *)currentTime{
    return self.timeLabel.text;
}
-(void)setTotalTime:(NSString *)totalTime{
    self.totalTimeLabel.text = totalTime;
}
-(NSString *)totalTime{
    return self.totalTimeLabel.text;
}
-(CGFloat)bufferValue{
    return self.bufferSlier.value;
}
-(void)setBufferValue:(CGFloat)bufferValue{
    self.bufferSlier.value = bufferValue;
}
@end
