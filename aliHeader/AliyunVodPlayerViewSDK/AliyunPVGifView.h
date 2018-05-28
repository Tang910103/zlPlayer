//
//  AliyunPVGifView.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/13.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunPVGifView : UIView

/*
 * 功能 ：设定gif动画图片
 */
- (void)setGifImageWithName:(NSString *)name;

/*
 * 功能 ：开始动画
 */
- (void)startAnimation;

/*
 * 功能 ：停止动画
 */
- (void)stopAnimation;
@end
