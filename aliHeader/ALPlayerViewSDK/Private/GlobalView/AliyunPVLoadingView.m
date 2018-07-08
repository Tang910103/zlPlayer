//
//  ALPVCenterView.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/9.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVLoadingView.h"
#import "AliyunPVGifView.h"
#import <Foundation/NSBundle.h>

static const int ALYPV_PX_LOADING_GIF_WIDTH  = 56;
static const int ALYPV_PX_LOADING_GIF_HEIGHT  = 56;
static const int ALYPV_PX_LOADING_VIEW_MARGIN = 4;

@interface AliyunPVLoadingView ()

@property (nonatomic, strong) AliyunPVGifView *gifView;
@property (nonatomic, strong) UILabel *tipLabelView;

@end

@implementation AliyunPVLoadingView
#pragma mark - 便利初始化函数
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

#pragma mark - 指定初始化函数
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        NSBundle *resourceBundle = [AliyunPVUtil languageBundle];
        _gifView = [[AliyunPVGifView alloc] init];
        [_gifView setGifImageWithName:@"al_loader"];
        NSString *str = NSLocalizedStringFromTableInBundle(@"loading", nil, resourceBundle, nil);
        _tipLabelView = [[UILabel alloc] init];
        [_tipLabelView setText:str];
        [_tipLabelView setTextColor:ALPV_COLOR_TEXT_NOMAL];
        [_tipLabelView setFont:[UIFont systemFontOfSize:[AliyunPVUtil nomalTextSize]]];
        [_tipLabelView setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_gifView];
        [self addSubview:_tipLabelView];
        [self setHidden:YES];
    }
    return self;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    float width = self.bounds.size.width;
    float margin = [AliyunPVUtil convertPixelToPoint:ALYPV_PX_LOADING_VIEW_MARGIN];
    float textHeight = [AliyunPVUtil nomalTextSize];
    float messageViewY = (width - textHeight) / 2;
    _tipLabelView.frame = CGRectMake(0, messageViewY, width, textHeight);
    float gifWidth = [AliyunPVUtil convertPixelToPoint:ALYPV_PX_LOADING_GIF_WIDTH];
    float gifHeight = [AliyunPVUtil convertPixelToPoint:ALYPV_PX_LOADING_GIF_HEIGHT];
    _gifView.frame = CGRectMake((width - gifWidth) / 2, messageViewY - gifHeight - margin, gifWidth, gifWidth);
    [_gifView startAnimation];
}

#pragma mark - show
- (void)show {
    if (![self isHidden]) {
        return;
    }
    [_gifView startAnimation];
    [self setHidden:NO];
}

#pragma mark - dismiss
- (void)dismiss {
    if ([self isHidden]) {
        return;
    }
    [_gifView stopAnimation];
    [self setHidden:YES];
}

@end
