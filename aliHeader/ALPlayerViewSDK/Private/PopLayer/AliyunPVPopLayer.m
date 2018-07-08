//
//  AliyunPVPopLayer.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVPopLayer.h"
#import "AliyunPVUtil.h"
static const int ALYPV_PX_BACK_WIDTH = 88;
static const int ALYPV_PX_BACK_HEIGHT = 96;
@interface AliyunPVPopLayer () <AliyunPVErrorViewDelegate>
@end
@implementation AliyunPVPopLayer

#pragma mark - 便利初始化函数
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

#pragma mark - 指定初始化函数
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.enableGesture = false;
        _backBtn = [[UIButton alloc] init];
        [_backBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.frame = CGRectMake(0, 0, [self pxConvertToPt:ALYPV_PX_BACK_WIDTH], [self pxConvertToPt:ALYPV_PX_BACK_HEIGHT]);
        [self addSubview:_backBtn];
        _errorView = [[AliyunPVErrorView alloc] init];
        _errorView.delegate = self;
    }
    return self;
}

#pragma makr - 皮肤设定
- (void)setSkin:(AliyunVodPlayerViewSkin)skin {
    _errorView.errorStytleSkin = skin;
    [_backBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_top_back_nomal" skin:skin] forState:UIControlStateNormal];
    [_backBtn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_top_back_press" skin: skin] forState:UIControlStateHighlighted];
}

#pragma mark - layoutSubViews
- (void)layoutSubviews {
    _errorView.center = self.center;
    [super layoutSubviews];
}

#pragma mark - onClick
- (void)onClick:(UIButton *)btn {
    if (![AliyunPVUtil isInterfaceOrientationPortrait]) {
        [AliyunPVUtil setFullOrHalfScreen];
    } else {
        
        if (self.popLayerDelegate && [self.popLayerDelegate respondsToSelector:@selector(onBackClickedWithAlPVPopLayer:)]) {
            [self.popLayerDelegate onBackClickedWithAlPVPopLayer:self];
        }
    }
}


/*
 #define ALIYUNVODVIEW_UNKNOWN           @"未知错误"
 #define ALIYUNVODVIEW_PLAYFINISH        @"再次观看，请点击重新播放"
 #define ALIYUNVODVIEW_NETWORKTIMEOUT        @"当前网络不佳，请稍后点击重新播放"
 #define ALIYUNVODVIEW_NETWORKUNREACHABLE             @"无网络连接，检查网络后点击重新播放"
 #define ALIYUNVODVIEW_LOADINGDATAERROR     @"视频加载出错，请点击重新播放"
 #define ALIYUNVODVIEW_USEMOBILENETWORK         @"当前为移动网络，请点击播放"
 */
- (void)showPopViewWithCode:(AliyunPVPlayerPopCode)code popMsg:(NSString *)popMsg {
    if (![_errorView isShowing]) {
        [_errorView dismiss];
    }
    NSBundle *resourceBundle = [AliyunPVUtil languageBundle];
    switch (code) {            
        case AliyunPVPlayerPopCodePlayFinish:{
            NSString *temp = [AliyunPVUtil playFinishTips];
            if (!temp){
                temp = NSLocalizedStringFromTableInBundle(@"Watch again, please click replay", nil, resourceBundle, nil);
            }
            [_errorView setMessage:temp];
            [_errorView setButtonText: NSLocalizedStringFromTableInBundle(@"Replay", nil, resourceBundle, nil) eventType:ALPV_TYPE_PLAY_REPLAY];
            [_errorView showWithParentView:self];
        }
            break;
        case     AliyunPVPlayerPopCodeNetworkTimeOutError :{
            NSString *temp = [AliyunPVUtil networkTimeoutTips];
            if (!temp){
                temp = NSLocalizedStringFromTableInBundle(@"The current network is not good. Please click replay later", nil, resourceBundle, nil);
            }
            [_errorView setMessage:temp];
            [_errorView setButtonText:NSLocalizedStringFromTableInBundle(@"Replay", nil, resourceBundle, nil) eventType:ALPV_TYPE_PLAY_REPLAY];
            [_errorView showWithParentView:self];
        }
            break;
        case AliyunPVPlayerPopCodeUnreachableNetwork:{
            NSString *temp = [AliyunPVUtil networkUnreachableTips];
            if (!temp){
                temp = NSLocalizedStringFromTableInBundle(@"No network connection, check the network, click replay", nil, resourceBundle, nil);
            }
            [_errorView setMessage:temp];
            [_errorView setButtonText:NSLocalizedStringFromTableInBundle(@"Retry", nil, resourceBundle, nil) eventType:ALPV_TYPE_PLAY_REPLAY];
            [_errorView showWithParentView:self];
        }
            break;
        case AliyunPVPlayerPopCodeLoadDataError : {
            NSString *temp = [AliyunPVUtil loadingDataErrorTips];
            if (!temp){
                temp = NSLocalizedStringFromTableInBundle(@"Video loading error, please click replay", nil, resourceBundle, nil);
            }
            [_errorView setMessage:temp];
            [_errorView setButtonText:NSLocalizedStringFromTableInBundle(@"Retry", nil, resourceBundle, nil) eventType:ALPV_TYPE_PLAY_RETRY];
            [_errorView showWithParentView:self];
        }
            break;
        case AliyunPVPlayerPopCodeServerError:{
            [_errorView setMessage:popMsg];
            [_errorView setButtonText:NSLocalizedStringFromTableInBundle(@"Retry", nil, resourceBundle, nil) eventType:ALPV_TYPE_PLAY_RETRY];
            [_errorView showWithParentView:self];
        }
            break;
        case AliyunPVPlayerPopCodeUseMobileNetwork: {
            NSString *temp = [AliyunPVUtil switchToMobileNetworkTips];
            if (!temp){
                temp = NSLocalizedStringFromTableInBundle(@"For mobile networks, click play", nil, resourceBundle, nil);
            }
            [_errorView setMessage:temp];
            [_errorView setButtonText:NSLocalizedStringFromTableInBundle(@"Play", nil, resourceBundle, nil) eventType:ALPV_TYPE_PLAYER_PAUSE];
            [_errorView showWithParentView:self];
        }
            break;
        default:
            break;
    }
    [self.parentView addSubview:self];
}

#pragma mark - AliyunPVErrorViewDelegate
- (void)onErrorViewClickWithErrorType:(NSString *)type{
    if (self.popLayerDelegate && [self.popLayerDelegate respondsToSelector:@selector(onErrorViewClickWithType:)]) {
        [self.popLayerDelegate onErrorViewClickWithType:type];
    }
}



@end
