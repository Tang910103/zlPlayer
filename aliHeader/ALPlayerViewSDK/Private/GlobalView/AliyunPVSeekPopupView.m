//
//  AliyunPVSeekPopupView.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/12.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVSeekPopupView.h"
#import "AliyunPVUtil.h"
#import "AliyunPVBaseLayer.h"
static const int ALYPV_PX_SEEK_VIEW_RADIUS         = 16;
static const int ALYPV_PX_SEEK_VIEW_WIDTH          = 310;
static const int ALYPV_PX_SEEK_VIEW_HEIGHT         = 310;
static const int ALYPV_PX_SEEK_VIEW_IMAGE_WIDTH    = 150;
static const int ALYPV_PX_SEEK_VIEW_IMAGE_HEIGHT   = 150;
static const int ALYPV_PX_SEEK_VIEW_IMAGE_TO_TOP   = 50;
static const int ALYPV_PX_SEEK_VIEW_MARGIN         = 18;
static const int ALYPV_PX_TEXT_SIZE      = 58;
static const NSString *ALYPV_DEFAULT_TIME = @"00:00:00";

@interface AliyunPVSeekPopupView ()

@property (nonatomic, strong) UIImage *forwardImg;
@property (nonatomic, strong) UIImage *backwardImg;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) NSMutableParagraphStyle *textStyle;

@property (nonatomic) double time;

@end

@implementation AliyunPVSeekPopupView

#pragma mark - 便利初始化函数
- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0,  [AliyunPVUtil convertPixelToPoint:ALYPV_PX_SEEK_VIEW_WIDTH], [AliyunPVUtil convertPixelToPoint:ALYPV_PX_SEEK_VIEW_HEIGHT])];
}

#pragma mark - 指定初始化函数
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _forwardImg = [AliyunPVUtil imageWithNameInBundle:@"al_fingerGesture_forward"];
        _backwardImg = [AliyunPVUtil imageWithNameInBundle:@"al_fingerGesture_backward"];
        _textFont = [UIFont systemFontOfSize:[AliyunPVUtil convertPixelToPoint:ALYPV_PX_TEXT_SIZE]];
        _textStyle = [[NSMutableParagraphStyle alloc] init];
        _textStyle.alignment = kCTTextAlignmentRight;
        _textStyle.lineBreakMode = NSLineBreakByClipping;
    }
    return self;
}

- (void)setTime:(double)time direction:(int)direction {
    self.time = time;
    self.direction = direction;
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [AliyunPVUtil drawFillRoundRect:rect radius:[AliyunPVUtil convertPixelToPoint:ALYPV_PX_SEEK_VIEW_RADIUS] color:ALPV_POP_BG_SEEK context:context];
    float imgWidth = [AliyunPVUtil convertPixelToPoint:ALYPV_PX_SEEK_VIEW_IMAGE_WIDTH];
    float imgHeight = [AliyunPVUtil convertPixelToPoint:ALYPV_PX_SEEK_VIEW_IMAGE_HEIGHT];
    float imgX = (rect.size.width - imgWidth) / 2;
    float imgY = [AliyunPVUtil convertPixelToPoint:ALYPV_PX_SEEK_VIEW_IMAGE_TO_TOP];
    if (self.direction) {
        [_forwardImg drawInRect:CGRectMake(imgX, imgY, imgWidth, imgHeight)];
    } else {
        [_backwardImg drawInRect:CGRectMake(imgX, imgY, imgWidth, imgHeight)];
    }
    NSString *time = [AliyunPVUtil timeformatFromSeconds:self.time];
    if (time && _textStyle) {
        [time drawInRect:CGRectMake(0, imgY + imgHeight + [AliyunPVUtil convertPixelToPoint:ALYPV_PX_SEEK_VIEW_MARGIN], rect.size.width, [AliyunPVUtil convertPixelToPoint:ALYPV_PX_TEXT_SIZE]) withAttributes:@{NSFontAttributeName:_textFont, NSForegroundColorAttributeName:ALPV_POP_SEEK_TEXT, NSParagraphStyleAttributeName:_textStyle}];
    }
    CGContextRestoreGState(context);
}

- (void)showWithParentView:(UIView *)parent {
    if (!parent) {
        return;
    }
    [parent addSubview:self];
    self.center = parent.center;
}

- (void)dismiss {
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0f];
}

- (BOOL)isShowing {
    return self.superview != nil;
}

- (void)onPanFinished {
    if (self.delegate) {
        [self.delegate seekPopupViewValueChanged:self.time];
    }
    [self dismiss];
}

@end
