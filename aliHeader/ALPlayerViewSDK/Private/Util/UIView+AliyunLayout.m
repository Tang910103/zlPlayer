//
//  UIView+Layout.m
//  AliyunVodPlayerViewSDK
//
//  Created by 王凯 on 2017/8/17.
//  Copyright © 2017年 SMY. All rights reserved.
//

#import "UIView+AliyunLayout.h"

@implementation UIView (AliyunLayout)
    
@dynamic aliyun_top;
@dynamic aliyun_bottom;
@dynamic aliyun_left;
@dynamic aliyun_right;

@dynamic aliyun_x;
@dynamic aliyun_y;
@dynamic aliyun_origin;

@dynamic aliyun_centerX;
@dynamic aliyun_centerY;

@dynamic aliyun_width;
@dynamic aliyun_height;

@dynamic aliyun_size;



- (CGFloat)aliyun_top{
    return self.frame.origin.y;
}

- (void)setAliyun_top:(CGFloat)aliyun_top{
    CGRect frame = self.frame;
    frame.origin.y = aliyun_top;
    self.frame = frame;
}

- (CGFloat)aliyun_left{
    return self.frame.origin.x;
}

-(void)setAliyun_left:(CGFloat)aliyun_left{
    CGRect frame = self.frame;
    frame.origin.x = aliyun_left;
    self.frame = frame;
}

- (CGFloat)aliyun_bottom{
    return self.frame.size.height + self.frame.origin.y;
}

- (void)setAliyun_bottom:(CGFloat)aliyun_bottom{
    CGRect frame = self.frame;
    frame.origin.y = aliyun_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)aliyun_right
{
    return self.frame.size.width + self.frame.origin.x;
}

- (void)setAliyun_right:(CGFloat)aliyun_right{
    CGRect frame = self.frame;
    frame.origin.x = aliyun_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)aliyun_x{
    return self.frame.origin.x;
}

- (void)setAliyun_x:(CGFloat)aliyun_x{
    CGRect frame = self.frame;
    frame.origin.x = aliyun_x;
    self.frame = frame;
}

- (CGFloat)aliyun_y{
    return self.frame.origin.y;
}

- (void)setAliyun_y:(CGFloat)aliyun_y{
    CGRect frame = self.frame;
    frame.origin.y = aliyun_y;
    self.frame = frame;
}

- (CGPoint)aliyun_origin
{
    return self.frame.origin;
}

- (void)setAliyun_origin:(CGPoint)aliyun_origin{
    CGRect frame = self.frame;
    frame.origin = aliyun_origin;
    self.frame = frame;
}

- (CGFloat)aliyun_centerX{
    return self.center.x;
}

- (void)setAliyun_centerX:(CGFloat)aliyun_centerX{
    CGPoint center = self.center;
    center.x = aliyun_centerX;
    self.center = center;
}

- (CGFloat)aliyun_centerY{
    return self.center.y;
}

- (void)setAliyun_centerY:(CGFloat)aliyun_centerY{
    CGPoint center = self.center;
    center.y = aliyun_centerY;
    self.center = center;
}

- (CGFloat)aliyun_width{
    return self.frame.size.width;
}

- (void)setAliyun_width:(CGFloat)aliyun_width{
    CGRect frame = self.frame;
    frame.size.width = aliyun_width;
    self.frame = frame;
}

- (CGFloat)aliyun_height{
    return self.frame.size.height;
}

- (void)setAliyun_height:(CGFloat)aliyun_height{
    CGRect frame = self.frame;
    frame.size.height = aliyun_height;
    self.frame = frame;
}

- (CGSize)aliyun_size{
    return self.frame.size;
}

- (void)setAliyun_size:(CGSize)aliyun_size{
    CGRect frame = self.frame;
    frame.size = aliyun_size;
    self.frame = frame;
}


@end

