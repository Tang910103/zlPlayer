//
//  AliyunPVControlLayer.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVControlLayer.h"
#import "UIView+AliyunLayout.h"

static const int ALYPV_PX_MARGIN = 16;
static const int ALYPV_PX_TOP_BAR_HEIGHT = 96;
static const int ALYPV_PX_BOTTOM_BAR_HEIGHT = 96;
static const int ALYPV_PX_BACK_SHOW_WIDTH = 88;
static int ALYPV_PX_BACK_WIDTH = ALYPV_PX_BACK_SHOW_WIDTH;
static const int ALYPV_PX_PLAY_WIDTH = 104;
static const int ALPV_PX_FULLSCREEN_WIDTH = 96;
// full screen
static const int ALYPV_PX_FULL_TIME_WIDTH = 160 + 80;
static const int ALYPV_PX_QUALITY_WIDTH = 0 ;//146 + ALYPV_PX_MARGIN * 2;
static const int ALPV_PX_DOWNLOAD_WIDTH = (96 + ALYPV_PX_MARGIN * 2) * 0; // 先不显示

@interface AliyunPVControlLayer () <AliyunPVProgressViewDelegate, AliyunPVQualityListViewDelegate>
@end
@implementation AliyunPVControlLayer

#pragma mark - init
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
        self.clipsToBounds = NO;
        
        _topBarBg = [[UIImageView alloc] init];
        _bottomBarBg = [[UIImageView alloc] init];
        _titleView = [[UILabel alloc] init];
        [_titleView setTextColor:ALPV_COLOR_TEXT_NOMAL];
        [_titleView setFont:[UIFont systemFontOfSize:[AliyunPVUtil titleTextSize]]];
        
        _leftTimeView = [[UILabel alloc] init];
        _leftTimeView.textAlignment = NSTextAlignmentLeft;
        [_leftTimeView setFont:[UIFont systemFontOfSize:[AliyunPVUtil smallerTextSize]]];
        [_leftTimeView setTextColor:ALPV_COLOR_TEXT_NOMAL];
        
        _rightTimeView = [[UILabel alloc] init];
        _rightTimeView.textAlignment = NSTextAlignmentRight;
        [_rightTimeView setFont:[UIFont systemFontOfSize:[AliyunPVUtil smallerTextSize]]];
        [_rightTimeView setTextColor:ALPV_COLOR_TEXT_NOMAL];
        
        _fullScreenTimeView = [[UILabel alloc] init];
        _fullScreenTimeView.textAlignment = NSTextAlignmentCenter;
        [_fullScreenTimeView setFont:[UIFont systemFontOfSize:[AliyunPVUtil smallTextSize]]];
        
        NSString *curTimeStr = @"00:00:00";
        NSString *totalTimeStr = @"00:00:00";
        NSString *time = [NSString stringWithFormat:@"%@/%@", curTimeStr, totalTimeStr];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:time];
        
        [str addAttribute:NSForegroundColorAttributeName value:ALPV_COLOR_TEXT_NOMAL range:NSMakeRange(0, curTimeStr.length)];
        [str addAttribute:NSForegroundColorAttributeName value:ALPV_COLOR_TEXT_GRAY range:NSMakeRange(curTimeStr.length, curTimeStr.length + 1)];
        [_fullScreenTimeView setAttributedText:str];
        
        _backBtn = [[UIButton alloc] init];
        [_backBtn setTag:ALPV_CLICK_BACK];
        [_backBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _playSpeedBtn = [[UIButton alloc] init];
        [_playSpeedBtn setTag:ALPV_CLICK_PLAYSPEED];
        [_playSpeedBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _lockBtn = [[UIButton alloc] init];
        [_lockBtn setTag:ALPV_CLICK_LOCK];
        [_lockBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_left_unlock"] forState:UIControlStateNormal];
        [_lockBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _playBtn = [[UIButton alloc] init];
        [_playBtn setTag:ALPV_CLICK_PLAY];
        [_playBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _qualityBtn = [[UIButton alloc] init];
        [_qualityBtn.titleLabel setFont:[UIFont systemFontOfSize:[AliyunPVUtil nomalTextSize]]];
        [_qualityBtn setTitleColor:ALPV_COLOR_TEXT_NOMAL forState:UIControlStateNormal];
        [_qualityBtn setTitleColor:ALPV_COLOR_BLUE forState:UIControlStateSelected];
        
        [_qualityBtn setTag:ALPV_CLICK_CHANGE_QUALITY];
        [_qualityBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _fullScreenBtn = [[UIButton alloc] init];
        [_fullScreenBtn setTag:ALPV_CLICK_FULL_SCREEN];
        [_fullScreenBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _progressView = [[AliyunPVProgressView alloc] init];
        _progressView.delegate = self;
        
        _qualityListView = [[AliyunPVQualityListView alloc] init];
        _qualityListView.delegate = self;
        
        [self addSubview:_topBarBg];
        [self addSubview:_bottomBarBg];
        [self addSubview:_titleView];
        [self addSubview:_leftTimeView];
        [self addSubview:_rightTimeView];
        [self addSubview:_fullScreenTimeView];
        [self addSubview:_backBtn];
        [self addSubview:_playSpeedBtn];
        [self addSubview:_lockBtn];
        [self addSubview:_playBtn];
        [self addSubview:_qualityBtn];
        [self addSubview:_fullScreenBtn];
        [self addSubview:_progressView];
    }
    return self;
}

/*
 * 功能 ：skin set方法，重写方法设置皮肤
 */
-(void)setSkin:(AliyunVodPlayerViewSkin)skin{
    [_topBarBg setImage:[AliyunPVUtil imageWithNameInBundle:@"al_topbar_bg" skin:skin]];
    [_bottomBarBg setImage:[AliyunPVUtil imageWithNameInBundle:@"al_playbar_bg" skin:skin]];
    
    [_backBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_top_back_nomal" skin:skin] forState:UIControlStateNormal];
    [_backBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_top_back_press" skin:skin] forState:UIControlStateHighlighted];
    [_playSpeedBtn setImage:[AliyunPVUtil imageWithNameInBundle:@"al_top_right" skin:skin] forState:UIControlStateNormal];
    [_playSpeedBtn setImage:[AliyunPVUtil imageWithNameInBundle:@"al_top_right" skin:skin] forState:UIControlStateHighlighted];
    [_fullScreenBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_play_screen" skin:skin] forState:UIControlStateSelected];
    [_fullScreenBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_play_screen_full" skin:skin] forState:UIControlStateNormal];
    [_playBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_play_start" skin:skin] forState:UIControlStateNormal];
    [_playBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_play_stop" skin:skin] forState:UIControlStateSelected];
    [_qualityBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_quality_btn_nomal" skin:skin] forState:UIControlStateNormal];
    [_qualityBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_quality_btn_press" skin:skin] forState:UIControlStateSelected];
    _progressView.prgressViewSkin = skin;
}

#pragma mark - layoutsubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    float topBarHeight = [self pxConvertToPt:ALYPV_PX_TOP_BAR_HEIGHT];
    float bottomBarHeight = [self pxConvertToPt:ALYPV_PX_BOTTOM_BAR_HEIGHT];
    float bottomBarY = height - bottomBarHeight;
    _topBarBg.frame = CGRectMake(0, 0, width, topBarHeight);
    _bottomBarBg.frame = CGRectMake(0, bottomBarY, width, bottomBarHeight);
    _backBtn.frame = CGRectMake(0, 0, [self pxConvertToPt:ALYPV_PX_BACK_WIDTH], topBarHeight);
    _titleView.frame = CGRectMake([self pxConvertToPt:(ALYPV_PX_BACK_WIDTH + ALYPV_PX_MARGIN)], 0, width - 2*[self pxConvertToPt:(ALYPV_PX_BACK_WIDTH + ALYPV_PX_MARGIN)], topBarHeight);
    _playBtn.frame = CGRectMake(0, bottomBarY, [self pxConvertToPt:ALYPV_PX_PLAY_WIDTH], bottomBarHeight);
    _fullScreenBtn.frame = CGRectMake(width - [self pxConvertToPt:ALPV_PX_FULLSCREEN_WIDTH], bottomBarY, [self pxConvertToPt:ALPV_PX_FULLSCREEN_WIDTH], bottomBarHeight);
    _playSpeedBtn.frame = CGRectMake(_titleView.aliyun_right+10, 0, _backBtn.aliyun_width, _backBtn.aliyun_height);
    _lockBtn.frame = CGRectMake(20, self.aliyun_height/2.0-20, 40, 40);
    //全屏竖屏
    if (self.isProtrait) {
        _fullScreenBtn.selected = YES;
        _qualityBtn.hidden = _progressView.hidden;
        _leftTimeView.hidden = _progressView.hidden;
        _rightTimeView.hidden = _progressView.hidden;
        _fullScreenTimeView.hidden = YES;
        _lockBtn.hidden = NO;
        _qualityBtn.frame = CGRectMake(width - [self pxConvertToPt:ALYPV_PX_QUALITY_WIDTH + ALPV_PX_FULLSCREEN_WIDTH], bottomBarY, [self pxConvertToPt:ALYPV_PX_QUALITY_WIDTH], bottomBarHeight);
        _qualityListView.frame = CGRectMake(_qualityBtn.frame.origin.x, bottomBarY - [_qualityListView estimatedHeight], _qualityBtn.frame.size.width, [_qualityListView estimatedHeight]);
        int qualityWidth = ALYPV_PX_QUALITY_WIDTH;
        NSArray* arry = _controlLayerVideo.video.allSupportQualitys;
        if (arry == nil || [arry count] == 0) {
            _qualityBtn.hidden = YES;
            qualityWidth = 0;
        }else {
            _qualityBtn.hidden = _progressView.hidden;
        }
        _progressView.frame = CGRectMake([self pxConvertToPt:ALYPV_PX_PLAY_WIDTH], bottomBarY,
                                         width - [self pxConvertToPt:ALYPV_PX_PLAY_WIDTH + ALPV_PX_FULLSCREEN_WIDTH+qualityWidth],
                                         bottomBarHeight);
        CGRect progressFrame = _progressView.frame;
        _leftTimeView.frame = CGRectMake(progressFrame.origin.x, bottomBarY + bottomBarHeight / 2, progressFrame.size.width / 2, bottomBarHeight / 2);
        _rightTimeView.frame = CGRectMake(progressFrame.origin.x + progressFrame.size.width / 2, bottomBarY + bottomBarHeight / 2, progressFrame.size.width / 2, bottomBarHeight / 2);
        return;
    }
    if ([AliyunPVUtil isInterfaceOrientationPortrait]) {
        _fullScreenBtn.selected = NO;
        //        _downloadBtn.hidden = YES;
        _qualityBtn.hidden = YES;
        _leftTimeView.hidden = NO;
        _rightTimeView.hidden = NO;
        _fullScreenTimeView.hidden = YES;
        _lockBtn.hidden = YES;
        _progressView.frame = CGRectMake([self pxConvertToPt:ALYPV_PX_PLAY_WIDTH], bottomBarY, width - [self pxConvertToPt:ALYPV_PX_PLAY_WIDTH + ALPV_PX_FULLSCREEN_WIDTH], bottomBarHeight);
        CGRect progressFrame = _progressView.frame;
        _leftTimeView.frame = CGRectMake(progressFrame.origin.x, bottomBarY + bottomBarHeight / 2, progressFrame.size.width / 2, bottomBarHeight / 2);
        _rightTimeView.frame = CGRectMake(progressFrame.origin.x + progressFrame.size.width / 2, bottomBarY + bottomBarHeight / 2, progressFrame.size.width / 2, bottomBarHeight / 2);
    } else {
        _fullScreenBtn.selected = YES;
        //        _downloadBtn.hidden = NO;
        _qualityBtn.hidden = NO;
        _leftTimeView.hidden = YES;
        _rightTimeView.hidden = YES;
        _fullScreenTimeView.hidden = NO;
        _lockBtn.hidden = NO;
        NSArray* arry = _controlLayerVideo.video.allSupportQualitys;
        if (arry == nil || [arry count] == 0) {
            _qualityBtn.hidden = YES;
        }else {
            _qualityBtn.hidden = NO;
        }
        _fullScreenTimeView.frame = CGRectMake([self pxConvertToPt:ALYPV_PX_PLAY_WIDTH], bottomBarY, [self pxConvertToPt:ALYPV_PX_FULL_TIME_WIDTH], bottomBarHeight);
        _qualityBtn.frame = CGRectMake(width - [self pxConvertToPt:ALYPV_PX_QUALITY_WIDTH + ALPV_PX_FULLSCREEN_WIDTH], bottomBarY, [self pxConvertToPt:ALYPV_PX_QUALITY_WIDTH], bottomBarHeight);
        //        _downloadBtn.frame = CGRectMake(width - [self pxConvertToPt:ALPV_PX_DOWNLOAD_WIDTH + ALYPV_PX_QUALITY_WIDTH + ALPV_PX_FULLSCREEN_WIDTH], bottomBarY, [self pxConvertToPt:ALPV_PX_DOWNLOAD_WIDTH], bottomBarHeight);
        _qualityListView.frame = CGRectMake(_qualityBtn.frame.origin.x, bottomBarY - [_qualityListView estimatedHeight], _qualityBtn.frame.size.width, [_qualityListView estimatedHeight]);
        int qualityWidth = ALYPV_PX_QUALITY_WIDTH;
        if (_qualityBtn.hidden == YES) {
            qualityWidth = 0;
        }
        _progressView.frame = CGRectMake([self pxConvertToPt:ALYPV_PX_PLAY_WIDTH + ALYPV_PX_FULL_TIME_WIDTH + ALYPV_PX_MARGIN], bottomBarY, width - [self pxConvertToPt:ALYPV_PX_PLAY_WIDTH + ALYPV_PX_FULL_TIME_WIDTH + 2 * ALYPV_PX_MARGIN + ALPV_PX_DOWNLOAD_WIDTH + qualityWidth + ALPV_PX_FULLSCREEN_WIDTH], bottomBarHeight);
        if (_lockBtn.selected) {
            _fullScreenTimeView.hidden = YES;
            _qualityBtn.hidden = YES;
        }
    }
}

/*
 * 功能 ：重写controlleLayerVideo方法，记录数据
 */
-(void)setControlLayerVideo:(AliyunPVVideo *)controlLayerVideo{
    _controlLayerVideo = controlLayerVideo;
    //更新是否显示清晰度列表
    NSArray* arry = controlLayerVideo.video.allSupportQualitys;//[ALPVCurrentInfo currentVideoAllQuality];
    if (arry == nil || [arry count] == 0) {
        _qualityBtn.hidden = YES;
    }else {
        _qualityBtn.hidden = NO;
    }
    [self setNeedsLayout];
}

#pragma mark - 更新播放时间
- (void)updateTimeView:(double)curTime duration:(double)duration state:(AliyunVodPlayerState)state{
    self.duration = duration;
    if (state == AliyunVodPlayerStatePlay || state == AliyunVodPlayerStatePause) {
        NSString *curTimeStr = [AliyunPVUtil timeformatFromSeconds:curTime];
        NSString *totalTimeStr = [AliyunPVUtil timeformatFromSeconds:duration];
        [_rightTimeView setText:totalTimeStr];
        [_leftTimeView setText:curTimeStr];
        NSString *time = [NSString stringWithFormat:@"%@/%@", curTimeStr, totalTimeStr];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:time];
        [str addAttribute:NSForegroundColorAttributeName value:ALPV_COLOR_TEXT_NOMAL range:NSMakeRange(0, curTimeStr.length)];
        [str addAttribute:NSForegroundColorAttributeName value:ALPV_COLOR_TEXT_GRAY range:NSMakeRange(curTimeStr.length, curTimeStr.length + 1)];
        [_fullScreenTimeView setAttributedText:str];
    }
}

#pragma mark - 父类方法
- (void)show {
}

- (void)dismiss {
}

#pragma mark - button点击事件,增加对外代理方法
- (void)onClick:(UIButton *)btn {
    if (self.contrololLayerDelegate) {
        [self.contrololLayerDelegate AliyunPVControlLayer:self onClickButton:btn];
    }
}

#pragma mark - 隐藏清晰度列表设置
- (void)hideQualityListView:(BOOL)hidden {
    if (hidden) {
        [_qualityBtn setSelected:NO];
        [_qualityListView removeFromSuperview];
    } else {
        [_qualityBtn setSelected:YES];
        [self addSubview:_qualityListView];
    }
}

#pragma mark - 设置锁屏时需要隐藏的列表
- (void)lockScreenWithIsScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait{
    if (!isScreenLocked) {
        [self.lockBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_left_unlock"] forState:UIControlStateNormal];
        self.topBarBg.hidden = NO;
        self.backBtn.hidden = NO;
        self.titleView.hidden = NO;
        self.playBtn.hidden = NO;
        self.fullScreenBtn.hidden=  NO;
        self.fullScreenTimeView.hidden =NO;
        self.qualityBtn.hidden = NO;
        self.playSpeedBtn.hidden = NO;
        if (fixedPortrait) {
            self.leftTimeView.hidden = NO;
            self.rightTimeView.hidden = NO;
        }else{
            self.leftTimeView.hidden = YES;
            self.rightTimeView.hidden = YES;
        }
        
        NSArray *arry = self.controlLayerVideo.video.allSupportQualitys;
        if (arry == nil || [arry count] == 0) {
            self.qualityBtn.hidden = YES;
        }else {
            self.qualityBtn.hidden = NO;
        }
        self.qualityListView.hidden= NO;
        self.progressView.hidden = NO;
        self.bottomBarBg.hidden = NO;
        [self setEnableGesture:YES];
    }else{
        [self.lockBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_left_lock"] forState:UIControlStateNormal];
        self.topBarBg.hidden = YES;
        self.backBtn.hidden = YES;
        self.titleView.hidden = YES;
        self.playBtn.hidden = YES;
        self.fullScreenBtn.hidden=  YES;
        self.fullScreenTimeView.hidden =YES;
        self.qualityBtn.hidden = YES;
        self.qualityListView.hidden= YES;
        self.progressView.hidden = YES;
        self.bottomBarBg.hidden = YES;
        self.playSpeedBtn.hidden = YES;
        self.leftTimeView.hidden = YES;
        self.rightTimeView.hidden = YES;
        [self setEnableGesture:NO];
    }
}

#pragma mark - 弹出错误窗口时 取消锁屏。
- (void)cancelLockScreenWithIsScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait {
    if (isScreenLocked||fixedPortrait) {
        if (fixedPortrait) {
            self.leftTimeView.hidden = NO;
            self.rightTimeView.hidden = NO;
        }else{
            self.leftTimeView.hidden = YES;
            self.rightTimeView.hidden = YES;
        }
        
        [self.lockBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_left_unlock"] forState:UIControlStateNormal];
        self.topBarBg.hidden = NO;
        self.backBtn.hidden = NO;
        self.titleView.hidden = NO;
        self.playBtn.hidden = NO;
        self.fullScreenBtn.hidden=  NO;
        self.fullScreenTimeView.hidden =NO;
        self.qualityBtn.hidden = NO;
        self.playSpeedBtn.hidden = NO;
        
        NSArray *arry = self.controlLayerVideo.video.allSupportQualitys;
        if (arry == nil || [arry count] == 0) {
            self.qualityBtn.hidden = YES;
        }else {
            self.qualityBtn.hidden = NO;
        }
        self.qualityListView.hidden= NO;
        self.progressView.hidden = NO;
        self.bottomBarBg.hidden = NO;
        [self setEnableGesture:YES];
        
    }
}

#pragma mark - 根据播放器状态处理 ，seek小球状态和进度条状态
- (void)updateViewWithPlayerState:(AliyunVodPlayerState)state {
    switch (state) {
        case AliyunVodPlayerStateIdle:
        {
            [_qualityBtn setUserInteractionEnabled:NO];
            [_progressView setTrackThumbState:AliyunPVTrackThumbStateIdle];
            [_progressView setUserInteractionEnabled:NO];
        }
            break;
        case AliyunVodPlayerStateError:
        {
            [_qualityBtn setUserInteractionEnabled:NO];
            [_progressView setTrackThumbState:AliyunPVTrackThumbStateIdle];
            [_progressView setUserInteractionEnabled:NO];
            _progressView.thumb.state = AliyunPVTrackThumbStateIdle;
        }
            break;
        case AliyunVodPlayerStatePrepared:
        {
            [_playBtn setUserInteractionEnabled:YES];
            [_playBtn setSelected:NO];
            [_qualityBtn setUserInteractionEnabled:NO];
            [_progressView setUserInteractionEnabled:NO];
        }
            break;
        case AliyunVodPlayerStatePlay:
        {
            [_playBtn setUserInteractionEnabled:YES];
            [self setEnableGesture:YES];
            [_qualityBtn setUserInteractionEnabled:YES];
            [_playBtn setSelected:YES];
            [_progressView setUserInteractionEnabled:YES];
            _progressView.thumb.state = AliyunPVTrackThumbStateIdle;
        }
            break;
        case AliyunVodPlayerStatePause:
        {
            [_playBtn setUserInteractionEnabled:YES];
            [_playBtn setSelected:NO];
            [_progressView setUserInteractionEnabled:YES];
            _progressView.thumb.state = AliyunPVTrackThumbStateIdle;
        }
            break;
        case AliyunVodPlayerStateStop:
        {
            [_playBtn setUserInteractionEnabled:YES];
            [_playBtn setSelected:NO];
            [_qualityBtn setUserInteractionEnabled:NO];
            [_progressView setTrackThumbState:AliyunPVTrackThumbStateIdle];
            [_progressView setUserInteractionEnabled:NO];
            
        }
            break;
        case AliyunVodPlayerStateLoading:
        {
            [_playBtn setUserInteractionEnabled:NO];
            [self setEnableGesture:NO];
            [_qualityBtn setUserInteractionEnabled:NO];
            [_progressView setUserInteractionEnabled:NO];
            [_progressView setTrackThumbState:AliyunPVTrackThumbStateIdle];
        }
            break;
        case AliyunVodPlayerStateFinish:
        {
            [_progressView setUserInteractionEnabled:NO];
            _progressView.thumb.state = AliyunPVTrackThumbStateIdle;
        }
            break;
            
        default:
        {
            [_qualityBtn setUserInteractionEnabled:NO];
            [_progressView setUserInteractionEnabled:NO];
        }
            
            break;
    }
}


#pragma mark - AliyunPVProgressViewDelegate
- (void)progressViewValueChanged:(float)value {
    if (self.contrololLayerDelegate) {
        [self.contrololLayerDelegate AliyunPVControlLayer:self progressViewValueChanged:value];
    }
}

#pragma mark - AliyunPVQualityListViewDelegate
- (void)qualityListViewOnItemClick:(int)index {
    if (self.contrololLayerDelegate) {
        [self.contrololLayerDelegate AliyunPVControlLayer:self qualityListViewOnItemClick:index];
    }
}
- (void)qualityListViewOnDefinitionClick:(NSString*)videoDefinition {
    if (self.contrololLayerDelegate) {
        [self.contrololLayerDelegate AliyunPVControlLayer:self qualityListViewOnDefinitionClick:videoDefinition];
    }
}

- (void)setPlayMethod:(AliyunVodPlayerViewPlayMethod)playMethod{
    _playMethod = playMethod;
    [_qualityListView setPlayMethod:playMethod];
}

@end
