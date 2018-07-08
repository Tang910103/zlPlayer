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
@property (nonatomic, strong) UIControl *control;
@property (nonatomic, assign) NSInteger btnTag;
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
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel setTextColor:ALPV_COLOR_TEXT_NOMAL];
        [_titleLabel setFont:[UIFont systemFontOfSize:[AliyunPVUtil titleTextSize]]];
    }
    return _titleLabel;
}

#pragma mark - 便利初始化函数
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

#pragma mark - 指定初始化函数
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame: frame]) {
        self.btnTag = 10000;
        [self addSubview:self.titleLabel];
        [self addSubview:self.control];
    }
    return self;
}

#pragma mark - buttonClicked
- (void)buttonClicked:(UIButton *)sender{
    if (sender.tag == self.btnTag) {
        return;
    }
    if (self.playSpeedViewDelegate) {
    AliyunPVSpeedButton *nomalBtn = [self viewWithTag:self.btnTag];
    nomalBtn.speedImageView.image = nil;
    nomalBtn.speedLabel.textColor = [UIColor whiteColor];
    AliyunPVSpeedButton *btn = (AliyunPVSpeedButton*)sender;
    btn.speedLabel.textColor = [self textColor:self.skin];
    btn.speedImageView.image = [AliyunPVUtil imageWithNameInBundle:@"al_point_btn" skin:self.skin];
    self.btnTag = btn.tag;
    [self.playSpeedViewDelegate AliyunPVPlaySpeedView:self playSpeed:(int)sender.tag-10000];
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
    self.titleLabel.frame = CGRectMake(0, 0, self.aliyun_width, 48);
    self.control.frame = CGRectMake(0, 0, self.aliyun_width, self.aliyun_height);
    CGFloat leftWidth = 20;
    CGFloat buttonWidth = 60;
    CGFloat disWidth = (self.aliyun_width - 4*buttonWidth-2*leftWidth)/3;
    CGFloat tempY  = self.aliyun_height/2-45;
    for (int i = 0; i<4; i++) {
        AliyunPVSpeedButton *tempButton = [self viewWithTag:10000+i];
        if (tempButton) {
            tempButton.frame = CGRectMake(leftWidth+i*(disWidth+buttonWidth), tempY, buttonWidth, 30+15);
            continue;
        }
        AliyunPVSpeedButton *btn = [AliyunPVSpeedButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 10000+i;
        btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.speedLabel.font = [UIFont systemFontOfSize:15.0];
        btn.speedLabel.textAlignment = NSTextAlignmentCenter;
        if (self.btnTag==btn.tag) {
            btn.speedLabel.textColor = [self textColor:self.skin];
            btn.speedImageView.image = [AliyunPVUtil imageWithNameInBundle:@"al_point_btn" skin:self.skin];
        }else{
            btn.speedLabel.textColor = [UIColor whiteColor];
            btn.speedImageView.image = [[UIImage alloc] init];
        }
        NSBundle *resourceBundle = [AliyunPVUtil languageBundle];
        btn.frame = CGRectMake(leftWidth+i*(disWidth+buttonWidth), tempY, buttonWidth, 30+15);
        switch (i) {
            case 0:
                btn.speedLabel.text =  NSLocalizedStringFromTableInBundle(@"Nomal", nil, resourceBundle, nil);//@"正常";
                break;
            case 1:
                btn.speedLabel.text =  NSLocalizedStringFromTableInBundle(@"1.25X", nil, resourceBundle, nil);
                break;
            case 2:
                btn.speedLabel.text =  NSLocalizedStringFromTableInBundle(@"1.5X", nil, resourceBundle, nil);
                break;
            case 3:
                btn.speedLabel.text =  NSLocalizedStringFromTableInBundle(@"2X", nil, resourceBundle, nil);
                break;
            default:
                break;
        }
        [self addSubview:btn];
    }
}


@end
