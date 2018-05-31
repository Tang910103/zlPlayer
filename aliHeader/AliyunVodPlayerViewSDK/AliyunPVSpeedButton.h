//
//  AliyunPVSpeedButton.h
//  AliyunVodPlayerViewSDK
//
//  Created by 王凯 on 2017/10/12.
//  Copyright © 2017年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AliyunPVSpeedButton : UIButton

/*
 * 功能 ： 倍速播放，圆圈
 */
@property (nonatomic, strong) UIImageView *speedImageView;

/*
 * 功能 ： 倍速播放，倍数
 */
@property (nonatomic, strong) UILabel *speedLabel;
@end
