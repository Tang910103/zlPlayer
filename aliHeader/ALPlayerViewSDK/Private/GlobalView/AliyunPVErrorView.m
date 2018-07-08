//
//  ALPVErrorMessageView.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/13.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVErrorView.h"
#import "AliyunPVUtil.h"
#import "AliyunPVBaseLayer.h"

static const int ALYPV_PX_ERROR_VIEW_WIDTH  = 440;
static const int ALYPV_PX_ERROR_VIEW_HEIGHT  = 240;
static const int ALYPV_PX_ERROR_TEXT_MARGIN_TOP = 60;
static const int ALYPV_PX_ERROR_BUTTON_WIDTH = 164;
static const int ALYPV_PX_ERROR_BUTTON_HEIGHT = 60;
static const int ALYPV_PX_ERROR_BUTTON_MARGIN_LEFT = 138;
static const int ALYPV_PX_ERROR_BACKGROUND_RADIUS = 8;

@interface AliyunPVErrorView ()
//错误界面，文本提示
@property (nonatomic, strong) UILabel   *errorLabel;

//界面中 点击按钮
@property (nonatomic, strong) UIButton  *errorButton;

//按钮中，提示信息（重播、重试等）
@property (nonatomic, strong) NSString  *errorButtonEventType;
@end

@implementation AliyunPVErrorView

#pragma mark - 指定初始化方法
- (instancetype)init{
    self = [super init];
    if (self) {
        int width = [AliyunPVUtil convertPixelToPoint:ALYPV_PX_ERROR_VIEW_WIDTH];
        int height = [AliyunPVUtil convertPixelToPoint:ALYPV_PX_ERROR_VIEW_HEIGHT];
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, 0, width, height);
        self.errorLabel = [[UILabel alloc] init];
        [self.errorLabel setTextColor:ALPV_COLOR_TEXT_NOMAL];
        [self.errorLabel setFont:[UIFont systemFontOfSize:[AliyunPVUtil nomalTextSize]]];
        [self.errorLabel setTextAlignment:NSTextAlignmentCenter];
        self.errorLabel.numberOfLines = 999;
        [self.errorLabel setFrame:CGRectMake(0, [AliyunPVUtil convertPixelToPoint:ALYPV_PX_ERROR_TEXT_MARGIN_TOP], width, [AliyunPVUtil nomalTextSize])];
        CGRect btnFrame = CGRectMake([AliyunPVUtil convertPixelToPoint:ALYPV_PX_ERROR_BUTTON_MARGIN_LEFT], [AliyunPVUtil convertPixelToPoint:ALYPV_PX_ERROR_TEXT_MARGIN_TOP]/2.0,
                                     [AliyunPVUtil convertPixelToPoint:ALYPV_PX_ERROR_BUTTON_WIDTH],
                                     [AliyunPVUtil convertPixelToPoint:ALYPV_PX_ERROR_BUTTON_HEIGHT]);
        self.errorButton = [self buildErrorButtonWithFrame:btnFrame];
        [self addSubview:self.errorLabel];
        [self addSubview:self.errorButton];
    }
    return self;
}

#pragma mark - message
- (void)setMessage:(NSString *)message {
    [self.errorLabel setText:message];
    self.errorLabel.numberOfLines = 999;
    int width = [AliyunPVUtil convertPixelToPoint:ALYPV_PX_ERROR_VIEW_WIDTH];
    NSDictionary *dic = @{NSFontAttributeName : self.errorLabel.font};
    CGRect infoRect = [self.errorLabel.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
    self.errorLabel.frame = CGRectMake(0, self.aliyun_height/2.0, width, infoRect.size.height);
}

#pragma mark - buttonText
- (void)setButtonText:(NSString *)text eventType:(NSString *)type {
    [self.errorButton setTitle:text forState:UIControlStateNormal];
    self.errorButtonEventType = type;
}

#pragma mark - showParentView
- (void)showWithParentView:(UIView *)parent {
    if (!parent) {
        return;
    }
    parent.hidden = NO;
    [parent addSubview:self];
    self.center = parent.center;
}

#pragma mark - isShow
- (BOOL)isShowing {
    return self.superview != nil;
}

#pragma mark - dismiss
- (void)dismiss {
    [self removeFromSuperview];
}

#pragma mark - onClick
- (void)onClick:(UIButton *)btn {
    [self dismiss];
    if (self.delegate) {
        [self.delegate onErrorViewClickWithErrorType:self.errorButtonEventType];
    }
}

#pragma mark - skin
-(void)setErrorStytleSkin:(AliyunVodPlayerViewSkin)errorSkin{
    _errorStytleSkin = errorSkin;
    [self.errorButton setTitleColor:[AliyunPVUtil textColor:errorSkin] forState:UIControlStateNormal];
    self.errorButton.titleLabel.textColor = [AliyunPVUtil textColor:errorSkin];
    self.errorButton.layer.cornerRadius = 5;
    self.errorButton.layer.borderWidth = 1;
    self.errorButton.layer.masksToBounds = YES;
    self.errorButton.layer.borderColor = [AliyunPVUtil textColor:errorSkin].CGColor;
    [self.errorButton setImage:[AliyunPVUtil imageWithNameInBundle:@"al_over_btn_refresh" skin:errorSkin] forState:UIControlStateNormal];
    self.errorLabel.textColor = [AliyunPVUtil textColor:errorSkin];
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [AliyunPVUtil drawFillRoundRect:rect radius:[AliyunPVUtil convertPixelToPoint:ALYPV_PX_ERROR_BACKGROUND_RADIUS] color:ALPV_POP_BG_ERROR context:context];
    CGContextRestoreGState(context);
}

#pragma mark - 创建提示按钮
- (UIButton *)buildErrorButtonWithFrame:(CGRect)frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setBackgroundImage:[AliyunPVUtil imageWithNameInBundle:@"al_error_btn" skin:self.errorStytleSkin] forState:UIControlStateNormal];
    [btn setImage:[AliyunPVUtil imageWithNameInBundle:@"al_over_btn_refresh" skin:self.errorStytleSkin] forState:UIControlStateNormal];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
    btn.titleLabel.font = [UIFont systemFontOfSize:[AliyunPVUtil nomalTextSize]];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:ALPV_COLOR_BLUE forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -12);
    [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

@end
