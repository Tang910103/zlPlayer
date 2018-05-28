//
//  AliyunStartPagesView.m
//  AliyunVodPlayerViewSDK
//
//  Created by 王凯 on 2017/10/12.
//  Copyright © 2017年 SMY. All rights reserved.
//

#import "AliyunFirstStartGuideView.h"
#import "UIView+AliyunLayout.h"
#import "AliyunPVUtil.h"
@interface AliyunFirstStartGuideView()
@property (nonatomic, strong)UIControl *control;

@property (nonatomic,strong)UIImageView *centerImageView;
@property (nonatomic,strong)UILabel *centerLabel;

@property (nonatomic,strong)UIImageView *leftImageView;
@property (nonatomic,strong)UILabel *leftLabel;

@property (nonatomic,strong)UIImageView *rightImageView;
@property (nonatomic,strong)UILabel *rightLabel;


@end;
@implementation AliyunFirstStartGuideView
{
    NSString *strabc;
}

-(UIImageView *)centerImageView{
    if (!_centerImageView) {
        _centerImageView = [[UIImageView alloc] init];
     }
    return _centerImageView;
}

- (UILabel *)centerLabel{
    if (!_centerLabel) {
        _centerLabel = [[UILabel alloc] init];
        _centerLabel.font = [UIFont systemFontOfSize:17.0f];
        
    }
    return _centerLabel;
}

-(UIImageView *)leftImageView{
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
    }
    return _leftImageView;
}

- (UILabel *)leftLabel{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        
    }
    return _leftLabel;
}


-(UIImageView *)rightImageView{
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
    }
    return _rightImageView;
}

- (UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        
    }
    return _rightLabel;
}

-(UIControl *)control{
    if (!_control) {
        _control = [[UIControl alloc] init];
        [_control addTarget:self action:@selector(controlButton:) forControlEvents:UIControlEventTouchDown];
    }
    return _control;
}

- (void)controlButton:(UIControl *)sender{
    [self removeFromSuperview];
}


- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        [self addSubview:self.control];
        
        self.centerImageView.image = [AliyunPVUtil imageWithNameInBundle:@"al_hit_center" skin:self.skin];
        [self addSubview:self.centerImageView];
        [self addSubview:self.centerLabel];
        
        self.leftImageView.image = [AliyunPVUtil imageWithNameInBundle:@"al_hit_left" skin:self.skin];
        [self addSubview:self.leftImageView];
        [self addSubview:self.leftLabel];
        
        self.rightImageView.image = [AliyunPVUtil imageWithNameInBundle:@"al_hit_right" skin:self.skin];
        [self addSubview:self.rightImageView];
        [self addSubview:self.rightLabel];
        
    }
    return self;
}

-(void)layoutSubviews{
    
    NSBundle *resourceBundle = [AliyunPVUtil languageBundle];
    
    self.control.frame = CGRectMake(0, 0, self.aliyun_width, self.aliyun_height);
    
    self.centerImageView.frame = CGRectMake(0, 0, 56, 72);
    self.centerImageView.center= self.center;
    
    self.centerLabel.textAlignment = NSTextAlignmentCenter;
    self.centerLabel.center = self.centerImageView.center;
    self.centerLabel.frame = CGRectMake(0, 0, 150, 50);
    self.centerLabel.center = self.centerImageView.center;
    CGRect frame = self.centerLabel.frame;
    frame.origin.y = self.centerImageView.aliyun_bottom+10;
    self.centerLabel.frame= frame;
    self.centerLabel.numberOfLines = 999;
    self.centerLabel.textColor = [UIColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;// 字体的行间距
    
    NSString *center = NSLocalizedStringFromTableInBundle(@"center", nil, resourceBundle, nil);
    NSString *progress = NSLocalizedStringFromTableInBundle(@"progress", nil, resourceBundle, nil);
    NSString *control = NSLocalizedStringFromTableInBundle(@"control", nil, resourceBundle, nil);
    NSString *centerStr = [NSString stringWithFormat:@"%@\n %@ %@",center,progress,control];
//    @"中心\n  进度调节";
    NSMutableAttributedString *maString = [[NSMutableAttributedString alloc] initWithString:centerStr];
    [maString addAttributes:@{ NSForegroundColorAttributeName: [self textColor:self.skin] ,
                               NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
                               NSParagraphStyleAttributeName:paragraphStyle,
                               } range:NSMakeRange(center.length+2, progress.length+1)];
    self.centerLabel.attributedText = maString;
    
    
    self.leftImageView.frame = CGRectMake(self.aliyun_width/2-100-self.centerImageView.aliyun_width/2-82, (self.aliyun_height-58)/2, 82, 58);
    
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    self.leftLabel.frame = CGRectMake(0, 0, 150, 50);
    self.leftLabel.center = self.leftImageView.center;
    CGRect frame1 = self.leftLabel.frame;
    frame1.origin.y = self.centerImageView.aliyun_bottom+10;
    self.leftLabel.frame= frame1;
    self.leftLabel.numberOfLines = 999;
    self.leftLabel.textColor = [UIColor whiteColor];
    
    
    NSString *left = NSLocalizedStringFromTableInBundle(@"left", nil, resourceBundle, nil);
    NSString *brightness = NSLocalizedStringFromTableInBundle(@"brightness", nil, resourceBundle, nil);
    NSString *centerStr1 = [NSString stringWithFormat:@"%@\n %@ %@",
                                                  left,
                                                  brightness,
                                                  control];
//    @"左侧\n  亮度调节";
    NSMutableAttributedString *maString1 = [[NSMutableAttributedString alloc] initWithString:centerStr1];
    [maString1 addAttributes:@{ NSForegroundColorAttributeName: [self textColor:self.skin] ,
                               NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
                               NSParagraphStyleAttributeName:paragraphStyle,
                               } range:NSMakeRange(left.length+2, brightness.length+1)];
    self.leftLabel.attributedText = maString1;
    
    self.rightImageView.frame = CGRectMake(self.centerImageView.aliyun_right+100, (self.aliyun_height-58)/2, 82, 58);
    
    self.rightLabel.textAlignment = NSTextAlignmentCenter;
    self.rightLabel.frame = CGRectMake(0, 0, 150, 50);
    self.rightLabel.center = self.rightImageView.center;
    CGRect frame3 = self.rightLabel.frame;
    frame3.origin.y = self.centerImageView.aliyun_bottom+10;
    self.rightLabel.frame= frame3;
    self.rightLabel.numberOfLines = 999;
    self.rightLabel.textColor = [UIColor whiteColor];
    
    NSString *right = NSLocalizedStringFromTableInBundle(@"right", nil, resourceBundle, nil);
    NSString *volume = NSLocalizedStringFromTableInBundle(@"volume", nil, resourceBundle, nil);
   
    NSString *centerStr3 = [NSString stringWithFormat:@"%@\n %@ %@",right,volume,control];
    
//    @"右侧\n  音量调节";
    NSMutableAttributedString *maString3 = [[NSMutableAttributedString alloc] initWithString:centerStr3];
    [maString3 addAttributes:@{ NSForegroundColorAttributeName: [self textColor:self.skin] ,
                                NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
                                NSParagraphStyleAttributeName:paragraphStyle,
                                } range:NSMakeRange(right.length+2, volume.length+1)];
    self.rightLabel.attributedText = maString3;
  
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
