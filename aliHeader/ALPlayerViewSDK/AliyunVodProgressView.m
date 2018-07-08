//
//  AlyunVodProgressView.m
//  playtset
//
//  Created by 王凯 on 2017/9/13.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunVodProgressView.h"


@interface AliyunVodProgressView()


@end
@implementation AliyunVodProgressView

- (UIImage *)imageWithNameInBundle:(NSString *)nameInBundle {
    return [UIImage imageNamed:[NSString stringWithFormat:@"AliyunVodPlayerViewResource.bundle/%@",  nameInBundle]];
}


-(instancetype)init{
    if (self = [super init]) {
        [self initView];
    }
    
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
-(void)initView{

    _loadtimeView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _loadtimeView.progress = 0.0;
    //设置它的风格，为默认的
    _loadtimeView.trackTintColor= [UIColor clearColor];
    //设置轨道的颜色
    _loadtimeView.progressTintColor= [UIColor whiteColor];
    
    
    
    _playtimeSlider = [[AliyunVodSlider alloc] init];
    _playtimeSlider.value = 0.0;
    // 圆点左侧条的颜色
    _playtimeSlider.minimumTrackTintColor = [UIColor blueColor];
    _playtimeSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.5 alpha:0.8];
    //圆点大小.
    //al_play_settings_radiobtn_normal_blue
    [_playtimeSlider setThumbImage:[self imageWithNameInBundle:@"al_play_settings_radiobtn_normal_blue@2x"] forState:UIControlStateNormal];
//    [_playtimeSlider setThumbImage:[UIImage imageNamed:@"iconfont-yuandian"] forState:UIControlStateHighlighted];
    
    
//    [_playtimeSlider addTarget:self action:@selector(progressSliderUpAction:) forControlEvents:UIControlEventTouchCancel];
//    [_playtimeSlider addTarget:self action:@selector(progressSliderDownAction:) forControlEvents:UIControlEventTouchDown];
//    [_playtimeSlider addTarget:self action:@selector(progressSliderUpAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playtimeSlider addTarget:self action:@selector(dragProgressSliderAction:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:_loadtimeView];
    [self addSubview:_playtimeSlider];
    
}

-(void)setSkin:(AliyunVodPlayerViewSkin)skin{
    

}

-(void)layoutSubviews{

    _loadtimeView.frame = CGRectMake(2,21, self.frame.size.width-4, 2);
    _playtimeSlider.frame = CGRectMake(0,10, self.frame.size.width, 24);
    

}

- (void)setLoadTime:(float)loadtime currentTime:(float)currentTime durationTime:(float)durationTime{
    
    [_loadtimeView setProgress:loadtime/durationTime];
    [_playtimeSlider setValue:currentTime/durationTime animated:YES];
}

- (void)dragProgressSliderAction:(UISlider *)sender{
    
    if (self.progressViewDelegate && [self.progressViewDelegate respondsToSelector:@selector(aliyunVodProgressView:dragProgressSliderValue:)]) {
        [self.progressViewDelegate aliyunVodProgressView:self dragProgressSliderValue:sender.value];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
