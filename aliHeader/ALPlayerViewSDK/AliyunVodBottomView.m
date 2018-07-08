//
//  AlyunVodBottomView.m
//  playtset
//
//  Created by 王凯 on 2017/9/13.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunVodBottomView.h"
#import "ALPVPrivateDefine.h"

static const int ALPV_PX_MARGIN = 16;
static const int ALPV_PX_TOP_BAR_HEIGHT = 96;
static const int ALPV_PX_BOTTOM_BAR_HEIGHT = 96;
static const int ALPV_PX_BACK_SHOW_WIDTH = 88;
static int ALPV_PX_BACK_WIDTH = ALPV_PX_BACK_SHOW_WIDTH;
static const int ALPV_PX_PLAY_WIDTH = 104;
static const int ALPV_PX_FULLSCREEN_WIDTH = 96;
// full screen
static const int ALPV_PX_FULL_TIME_WIDTH = 160 + 80;
static const int ALPV_PX_QUALITY_WIDTH = 96 + ALPV_PX_MARGIN * 2;
static const int ALPV_PX_DOWNLOAD_WIDTH = (96 + ALPV_PX_MARGIN * 2) * 0; // 先不显示


@interface AliyunVodBottomView()<AliyunVodProgressViewDelegate>





@end

@implementation AliyunVodBottomView


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

- (void)initView{
    _leftTimeLabel = [[UILabel alloc] init];
    _leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    [_leftTimeLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_leftTimeLabel setTextColor:ALPV_COLOR_TEXT_NOMAL];
    
    _rightTimeLabel = [[UILabel alloc] init];
    _rightTimeLabel.textAlignment = NSTextAlignmentRight;
    [_rightTimeLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_rightTimeLabel setTextColor:ALPV_COLOR_TEXT_NOMAL];
    
    _fullScreenTimeLabel = [[UILabel alloc] init];
    _fullScreenTimeLabel.textAlignment = NSTextAlignmentCenter;
    [_fullScreenTimeLabel setFont:[UIFont systemFontOfSize:12.0f]];
    
    NSString *curTimeStr = @"00:00:00";
    NSString *totalTimeStr = @"00:00:00";
    
#pragma mark - todo
    _leftTimeLabel.text = curTimeStr;
    _rightTimeLabel.text = curTimeStr;
    
    NSString *time = [NSString stringWithFormat:@"%@/%@", curTimeStr, totalTimeStr];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:time];
    
    [str addAttribute:NSForegroundColorAttributeName value:ALPV_COLOR_TEXT_NOMAL range:NSMakeRange(0, curTimeStr.length)];
    [str addAttribute:NSForegroundColorAttributeName value:ALPV_COLOR_TEXT_GRAY range:NSMakeRange(curTimeStr.length, curTimeStr.length + 1)];
    
    [_fullScreenTimeLabel setAttributedText:str];
    
    _playButton = [[UIButton alloc] init];
    [_playButton setTag:ALButtonEventPlay];
    [_playButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _qualityButton = [[UIButton alloc] init];
    [_qualityButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_qualityButton setTitleColor:ALPV_COLOR_TEXT_NOMAL forState:UIControlStateNormal];
    [_qualityButton setTitleColor:ALPV_COLOR_BLUE forState:UIControlStateSelected];
    [_qualityButton setTag:ALButtonEventQualityList];
    [_qualityButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _fullScreenButton = [[UIButton alloc] init];
    [_fullScreenButton setTag:ALButtonEventFullScreen];
    [_fullScreenButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _progressView = [[AliyunVodProgressView alloc] init];
    _progressView.progressViewDelegate = self;
    
    
    [self addSubview:_leftTimeLabel];
    [self addSubview:_rightTimeLabel];
    [self addSubview:_fullScreenButton];
    [self addSubview:_playButton];
    [self addSubview:_qualityButton];
    [self addSubview:_fullScreenButton];
    [self addSubview: _progressView];
    [self addSubview:_fullScreenTimeLabel];
    
}

-(void)setSkin:(AliyunVodPlayerViewSkin)skin{
    
    [_fullScreenButton setBackgroundImage:[ALPVUtil imageWithNameInBundle:@"al_play_screen" skin:skin] forState:UIControlStateSelected];
    [_fullScreenButton setBackgroundImage:[ALPVUtil imageWithNameInBundle:@"al_play_screen_full" skin:skin] forState:UIControlStateNormal];
    
    [_playButton setBackgroundImage:[ALPVUtil imageWithNameInBundle:@"al_play_start" skin:skin] forState:UIControlStateNormal];
    [_playButton setBackgroundImage:[ALPVUtil imageWithNameInBundle:@"al_play_stop" skin:skin] forState:UIControlStateSelected];
    
    [_qualityButton setBackgroundImage:[ALPVUtil imageWithNameInBundle:@"al_quality_btn_nomal" skin:skin] forState:UIControlStateNormal];
    [_qualityButton setBackgroundImage:[ALPVUtil imageWithNameInBundle:@"al_quality_btn_press" skin:skin] forState:UIControlStateSelected];
    _progressView.skin = skin;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    
    float topBarHeight = 44;
    float bottomBarHeight = 44;
    float bottomBarY = height - bottomBarHeight;
    _playButton.frame = CGRectMake(0, bottomBarY, 44, bottomBarHeight);
    _fullScreenButton.frame = CGRectMake(width - 44, bottomBarY, 44, bottomBarHeight);
    
    /* DISABLES CODE */
    if ([ALPVUtil isInterfaceOrientationPortrait]) {
        _fullScreenButton.selected = NO;
        _qualityButton.hidden = YES;
        _leftTimeLabel.hidden = NO;
        _rightTimeLabel.hidden = NO;
        _fullScreenTimeLabel.hidden = YES;
        
        _progressView.frame = CGRectMake(48, bottomBarY, width - 100, bottomBarHeight);
        
        CGRect progressFrame = _progressView.frame;
        
        _leftTimeLabel.frame = CGRectMake(progressFrame.origin.x, bottomBarY + bottomBarHeight / 2, progressFrame.size.width / 2, bottomBarHeight / 2);
        
        _rightTimeLabel.frame = CGRectMake(progressFrame.origin.x + progressFrame.size.width / 2, bottomBarY + bottomBarHeight / 2, progressFrame.size.width / 2, bottomBarHeight / 2);
        
    } else {
        _fullScreenButton.selected = YES;
        _qualityButton
        .hidden = NO;
        _leftTimeLabel.hidden = YES;
        _rightTimeLabel.hidden = YES;
        _fullScreenTimeLabel.hidden = NO;
        
        _fullScreenTimeLabel.frame = CGRectMake(52, bottomBarY, 120, bottomBarHeight);
        
        _qualityButton.frame = CGRectMake(width - 114, bottomBarY, 64, bottomBarHeight);
        
        
        
        _progressView.frame = CGRectMake((ALPV_PX_PLAY_WIDTH + ALPV_PX_FULL_TIME_WIDTH + ALPV_PX_MARGIN)/2.0, bottomBarY, width - (ALPV_PX_PLAY_WIDTH + ALPV_PX_FULL_TIME_WIDTH + 2 * ALPV_PX_MARGIN + ALPV_PX_DOWNLOAD_WIDTH + ALPV_PX_QUALITY_WIDTH + ALPV_PX_FULLSCREEN_WIDTH)/2.0, bottomBarHeight);
    }
    
    
}


- (void)setQualityButtonTitle:(NSString *)title{
    [self.qualityButton setTitle:title forState:UIControlStateNormal];
}

-(void)setAllQualitys:(NSArray *)allQualitys{
    
}

- (void)onClick:(UIButton *)sender{
    
    if (self.bottomViewDelegate && [self.bottomViewDelegate respondsToSelector:@selector(aliyunVodBottomView:buttonClicked:)]) {
        
        [self.bottomViewDelegate aliyunVodBottomView:self buttonClicked:sender.tag];
    }
    
}

#pragma mark - progressDelegate
- (void)aliyunVodProgressView:(AliyunVodProgressView *)progressView dragProgressSliderValue:(float)value{
    if (self.bottomViewDelegate && [self.bottomViewDelegate respondsToSelector:@selector(aliyunVodProgressView:dragProgressSliderValue:)]) {
    
        [self.bottomViewDelegate aliyunVodBottomView:self dragProgressSliderValue:value];
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
