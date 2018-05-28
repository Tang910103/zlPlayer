//
//  UIView+Layout.h
//  AliyunVodPlayerViewSDK
//
//  Created by 王凯 on 2017/8/17.
//  Copyright © 2017年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AliyunLayout)

@property (assign, nonatomic) CGFloat    aliyun_top;
@property (assign, nonatomic) CGFloat    aliyun_bottom;
@property (assign, nonatomic) CGFloat    aliyun_left;
@property (assign, nonatomic) CGFloat    aliyun_right;

@property (assign, nonatomic) CGFloat    aliyun_x;
@property (assign, nonatomic) CGFloat    aliyun_y;
@property (assign, nonatomic) CGPoint    aliyun_origin;

@property (assign, nonatomic) CGFloat    aliyun_centerX;
@property (assign, nonatomic) CGFloat    aliyun_centerY;

@property (assign, nonatomic) CGFloat    aliyun_width;
@property (assign, nonatomic) CGFloat    aliyun_height;
@property (assign, nonatomic) CGSize     aliyun_size;

@end
