//
//  AliyunPVPlaySpeedView.m
//  AliyunVodPlayerViewSDK
//
//  Created by 王凯 on 2017/10/11.
//  Copyright © 2017年 SMY. All rights reserved.
//

#import "AliyunPVPlaySpeedView.h"
#import "AliyunPVSpeedButton.h"


@interface AliyunPVPlaySpeedView()
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *titleLabel_1;
@property(nonatomic, strong) UILabel *titleLabel_2;
@property (nonatomic, strong) UIControl *control;
@property (nonatomic, assign) NSInteger btnTag;
@property (nonatomic, assign) NSInteger btnTag_1;
@property (nonatomic, assign) NSInteger btnTag_2;
@end

@implementation AliyunPVPlaySpeedView

#pragma mark - 懒加载
-(UIControl *)control{
    if (!_control) {
        _control = [[UIControl alloc] init];
        [_control addTarget:self action:@selector(controlButton:) forControlEvents:UIControlEventTouchDown];
    }
    return _control;
}
- (void)controlButton:(UIControl *)sender{
    [UIView animateWithDuration:0.3 animations:^{
        if ([AliyunPVUtil isInterfaceOrientationPortrait]) {
            CGRect frame = self.frame;
            frame.origin.x = self.aliyun_width;
            self.frame = frame;
        }else{
            CGRect frame = self.frame;
            frame.origin.x = SCREEN_WIDTH;
            self.frame = frame;
        }
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
- (UILabel *)titleLabel{
    if(!_titleLabel){
        NSBundle *resourceBundle = [AliyunPVUtil languageBundle];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = NSLocalizedStringFromTableInBundle(@"Fast speed play", nil, resourceBundle, nil);//@"倍速播放";
        [_titleLabel setFont:[UIFont systemFontOfSize:[AliyunPVUtil titleTextSize]]];
//        _titleLabel.backgroundColor = [UIColor redColor];
//        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel setTextColor:ALPV_COLOR_TEXT_NOMAL];
        [_titleLabel setFont:[UIFont systemFontOfSize:[AliyunPVUtil titleTextSize]]];
    }
    return _titleLabel;
}
- (UILabel *)titleLabel_1{
    if(!_titleLabel_1){
        _titleLabel_1 = [[UILabel alloc] init];
        _titleLabel_1.text = @"屏幕模式";//@"屏幕模式";
        [_titleLabel_1 setFont:[UIFont systemFontOfSize:[AliyunPVUtil titleTextSize]]];
        //        _titleLabel.backgroundColor = [UIColor redColor];
//        _titleLabel_1.textAlignment = NSTextAlignmentCenter;
        [_titleLabel_1 setTextColor:ALPV_COLOR_TEXT_NOMAL];
        [_titleLabel_1 setFont:[UIFont systemFontOfSize:[AliyunPVUtil titleTextSize]]];
    }
    return _titleLabel_1;
}
- (UILabel *)titleLabel_2{
    if(!_titleLabel_2){
        _titleLabel_2 = [[UILabel alloc] init];
        _titleLabel_2.text = @"播放方式";//@"播放方式";
        [_titleLabel_2 setFont:[UIFont systemFontOfSize:[AliyunPVUtil titleTextSize]]];
        //        _titleLabel.backgroundColor = [UIColor redColor];
//        _titleLabel_2.textAlignment = NSTextAlignmentCenter;
        [_titleLabel_2 setTextColor:ALPV_COLOR_TEXT_NOMAL];
        [_titleLabel_2 setFont:[UIFont systemFontOfSize:[AliyunPVUtil titleTextSize]]];
    }
    return _titleLabel_2;
}
#pragma mark - 便利初始化函数
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

#pragma mark - 指定初始化函数
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame: frame]) {
        self.btnTag = 10001;
        self.btnTag_1 = 10005;
        self.btnTag_2 = 10007;
        [self addSubview:self.titleLabel];
        [self addSubview:self.titleLabel_1];
        [self addSubview:self.titleLabel_2];
        [self addSubview:self.control];
    }
    return self;
}
- (void)setDisplayMode:(AliyunVodPlayerDisplayMode)displayMode
{
    _displayMode = displayMode;
    NSInteger tag = displayMode == AliyunVodPlayerDisplayModeFit ? 10005 : 10006;
    UIButton *button = [self viewWithTag:tag];
    if (button) {
        [self buttonClicked:button];
    } else {
        self.btnTag_1 = tag;
    }
}
- (void)setIsAutomaticFlow:(BOOL)isAutomaticFlow
{
    _isAutomaticFlow = isAutomaticFlow;
    NSInteger tag = isAutomaticFlow ? 10008 : 10007;
    UIButton *button = [self viewWithTag:tag];
    if (button) {
        [self buttonClicked:button];
    } else {
        self.btnTag_2 = tag;
    }
}
#pragma mark - buttonClicked
- (void)buttonClicked:(UIButton *)sender{
    if (sender.tag == self.btnTag || sender.tag == self.btnTag_1 || sender.tag == self.btnTag_2) return;
    NSInteger btnTag = self.btnTag;
    if (sender.tag < 10000+5) {
        btnTag = self.btnTag;
    } else if (sender.tag < 10000+7) {
        btnTag = self.btnTag_1;
    } else if (sender.tag < 10000+9) {
       btnTag = self.btnTag_2;
    }
    AliyunPVSpeedButton *nomalBtn = [self viewWithTag:btnTag];
    nomalBtn.speedImageView.image = nil;
    nomalBtn.speedLabel.textColor = [UIColor whiteColor];
    AliyunPVSpeedButton *btn = (AliyunPVSpeedButton*)sender;
    btn.speedLabel.textColor = UIColorFromRGB(0x65d92b);
    btn.speedImageView.image = [AliyunPVUtil imageWithNameInBundle:@"al_point_btn" skin:self.skin];
    if (sender.tag < 10000+5) {
        self.btnTag = btn.tag;
        if ([self.playSpeedViewDelegate respondsToSelector:@selector(AliyunPVPlaySpeedView:playSpeed:)]) {
            [self.playSpeedViewDelegate AliyunPVPlaySpeedView:self playSpeed:(int)sender.tag-10000];
        }
    } else if (sender.tag < 10000+7) {
        self.btnTag_1 = btn.tag;
        if ([self.playSpeedViewDelegate respondsToSelector:@selector(AliyunPVPlaySpeedView:displayMode:)]) {
            [self.playSpeedViewDelegate AliyunPVPlaySpeedView:self displayMode:btn.tag == 10005 ? AliyunVodPlayerDisplayModeFit : AliyunVodPlayerDisplayModeFitWithCropping];
        }
    } else if (sender.tag < 10000+9) {
        self.btnTag_2 = btn.tag;
        if ([self.playSpeedViewDelegate respondsToSelector:@selector(AliyunPVPlaySpeedView:isAutomaticFlow:)]) {
            [self.playSpeedViewDelegate AliyunPVPlaySpeedView:self isAutomaticFlow:btn.tag == 10008];
        }
    }
    
}


- (UIColor *)textColor:(AliyunVodPlayerViewSkin)skin{
    UIColor *color = nil;
    switch (skin) {
        case AliyunVodPlayerViewSkinBlue:
            color = UIColorFromRGB(0x379DF2);
            break;
        case AliyunVodPlayerViewSkinRed:
            color = UIColorFromRGB(0xE94033);
            break;
        case AliyunVodPlayerViewSkinOrange:
            color = UIColorFromRGB(0xEE7C33);
            break;
        case AliyunVodPlayerViewSkinGreen:
            color = UIColorFromRGB(0x57AB44);
            break;
            
        default:
            break;
    }
    return color;
}

#pragma mark - layoutSubviews
-(void)layoutSubviews{
    CGFloat leftWidth = 20;
    CGFloat buttonWidth = 60;
    CGFloat buttonWidth_1 = 80;
    CGFloat buttonHeight = 30;
    CGFloat disWidth = (self.aliyun_width - 5*buttonWidth-2*leftWidth)/4;
    self.titleLabel.frame = CGRectMake(leftWidth, 0, self.aliyun_width-leftWidth, 35);
    self.titleLabel_1.frame = CGRectMake(leftWidth, 65, self.aliyun_width-leftWidth, 35);
    self.titleLabel_2.frame = CGRectMake(leftWidth, 130, self.aliyun_width-leftWidth, 35);
    self.control.frame = CGRectMake(0, 0, self.aliyun_width, self.aliyun_height);
    CGFloat tempY  = CGRectGetMaxY(self.titleLabel.frame);
    for (int i = 0; i<9; i++) {
        AliyunPVSpeedButton *tempButton = [self viewWithTag:10000+i];
        if (tempButton) {
            if (i < 5) {
                tempButton.frame = CGRectMake(leftWidth+i*(disWidth+buttonWidth), tempY, buttonWidth, buttonHeight);
            } else if (i < 6) {
                tempButton.frame = CGRectMake(leftWidth, CGRectGetMaxY(self.titleLabel_1.frame), buttonWidth_1, buttonHeight);
            } else if (i < 7) {
                tempButton.frame = CGRectMake(buttonWidth_1 + 2*leftWidth, CGRectGetMaxY(self.titleLabel_1.frame), buttonWidth_1, buttonHeight);
            } else if (i < 8) {
                tempButton.frame = CGRectMake(leftWidth, CGRectGetMaxY(self.titleLabel_2.frame), buttonWidth_1, buttonHeight);
            } else if (i < 9) {
                tempButton.frame = CGRectMake(buttonWidth_1 + 2*leftWidth, CGRectGetMaxY(self.titleLabel_2.frame), buttonWidth_1, buttonHeight);
            }
            continue;
        }
        AliyunPVSpeedButton *btn = [AliyunPVSpeedButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 10000+i;
        btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.speedLabel.font = [UIFont systemFontOfSize:15.0];
        btn.speedLabel.textAlignment = NSTextAlignmentCenter;
        if (self.btnTag==btn.tag || (i == 5 && self.displayMode == AliyunVodPlayerDisplayModeFit) || (i == 6 && self.displayMode == AliyunVodPlayerDisplayModeFitWithCropping) || (i == 7 && !self.isAutomaticFlow) || (i == 8 && self.isAutomaticFlow)) {
            btn.speedLabel.textColor = UIColorFromRGB(0x65d92b);
            btn.speedImageView.image = [AliyunPVUtil imageWithNameInBundle:@"al_point_btn" skin:self.skin];
        }else{
            btn.speedLabel.textColor = [UIColor whiteColor];
            btn.speedImageView.image = [[UIImage alloc] init];
        }
        NSBundle *resourceBundle = [AliyunPVUtil languageBundle];
        if (i < 5) {
            tempButton.frame = CGRectMake(leftWidth+i*(disWidth+buttonWidth), tempY, buttonWidth, buttonHeight);
        } else if (i < 6) {
            tempButton.frame = CGRectMake(leftWidth, CGRectGetMaxY(self.titleLabel_1.frame), buttonWidth_1, buttonHeight);
        } else if (i < 7) {
            tempButton.frame = CGRectMake(buttonWidth_1 + 2*leftWidth, CGRectGetMaxY(self.titleLabel_1.frame), buttonWidth_1, buttonHeight);
        } else if (i < 8) {
            tempButton.frame = CGRectMake(leftWidth, CGRectGetMaxY(self.titleLabel_2.frame), buttonWidth_1, buttonHeight);
        } else if (i < 9) {
            tempButton.frame = CGRectMake(buttonWidth_1 + 2*leftWidth, CGRectGetMaxY(self.titleLabel_2.frame), buttonWidth_1, buttonHeight);
        }
        switch (i) {
            case 0:
                btn.speedLabel.text =  @"0.8倍";
                break;
            case 1:
                btn.speedLabel.text =  NSLocalizedStringFromTableInBundle(@"Nomal", nil, resourceBundle, nil);//@"正常";
                break;
            case 2:
                btn.speedLabel.text =  NSLocalizedStringFromTableInBundle(@"1.25X", nil, resourceBundle, nil);
                break;
            case 3:
                btn.speedLabel.text =  NSLocalizedStringFromTableInBundle(@"1.5X", nil, resourceBundle, nil);
                break;
            case 4:
                btn.speedLabel.text =  NSLocalizedStringFromTableInBundle(@"2X", nil, resourceBundle, nil);
                break;
            case 5:
                btn.speedLabel.text =  @"适应大小";
                break;
            case 6:
                btn.speedLabel.text =  @"裁剪铺满";
                break;
            case 7:
                btn.speedLabel.text =  @"播完暂停";
                break;
            case 8:
                btn.speedLabel.text =  @"自动连播";
                break;
            default:
                break;
        }
        [self addSubview:btn];
    }
}


@end
