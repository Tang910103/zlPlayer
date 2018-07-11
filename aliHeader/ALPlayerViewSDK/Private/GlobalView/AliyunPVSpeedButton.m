//
//  AliyunPVSpeedButton.m
//  AliyunVodPlayerViewSDK
//
//  Created by 王凯 on 2017/10/12.
//  Copyright © 2017年 SMY. All rights reserved.
//

#import "AliyunPVSpeedButton.h"
#import "UIView+AliyunLayout.h"


@implementation AliyunPVSpeedButton

- (UILabel *)speedLabel{
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] init];
    }
    return _speedLabel;
}

- (UIImageView *)speedImageView{
    if (!_speedImageView) {
        _speedImageView = [[UIImageView alloc] init];
    }
    return _speedImageView;
}

- (instancetype)init{
    return  [self  initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)layoutSubviews{
    self.speedImageView.frame = CGRectMake((self.aliyun_width-5)/2, 0, 0, 0);
    [self addSubview:self.speedImageView];
    self.speedLabel.frame = CGRectMake(0, self.speedImageView.aliyun_bottom+0, self.aliyun_width, 30);
    [self addSubview:self.speedLabel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
