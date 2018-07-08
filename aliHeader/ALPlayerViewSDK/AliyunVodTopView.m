//
//  AlyunVodTopView.m
//  playtset
//
//  Created by 王凯 on 2017/9/13.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import "AliyunVodTopView.h"
//#import "ALPVUtil.h"

@interface AliyunVodTopView(){
    UILabel *_titleLabel;
    UIButton *_backButton;
}


@end
@implementation AliyunVodTopView

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


-(void)setSkin:(AliyunVodPlayerViewSkin)skin{
    
//    [_backButton setBackgroundImage:[ALPVUtil imageWithNameInBundle:@"al_top_back_nomal" skin:skin] forState:UIControlStateNormal];
//    [_backButton setBackgroundImage:[ALPVUtil imageWithNameInBundle:@"al_top_back_press" skin:skin] forState:UIControlStateHighlighted];

}

-(void)setTopTitle:(NSString *)topTitle{
    _titleLabel.text = topTitle;
}

- (void)initView{
    _titleLabel = [[UILabel alloc] init];
    [_titleLabel setTextColor:ALPV_COLOR_TEXT_NOMAL];
    [_titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    
    _backButton = [[UIButton alloc] init];
    [_backButton setTag:1000];
    [_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_titleLabel];
    [self addSubview:_backButton];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    float width = self.bounds.size.width;
    _backButton.frame = CGRectMake(0, 0, 40, 44);
    _titleLabel.frame = CGRectMake(44, 0, width - 44, 44);
    
}

- (void)backButtonClick:(UIButton *)sender{
    if (self.topViewDelegate && [self.topViewDelegate respondsToSelector:@selector(aliyunVodTopView:onBackViewClick:)]) {
        [self.topViewDelegate aliyunVodTopView:self onBackViewClick:(UIButton *)sender];
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
