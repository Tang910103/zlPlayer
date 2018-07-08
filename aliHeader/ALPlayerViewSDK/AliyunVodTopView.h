//
//  AlyunVodTopView.h
//  playtset
//
//  Created by 王凯 on 2017/9/13.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunVodPlayerViewDefine.h"

@class AliyunVodTopView;

@protocol AliyunVodTopViewDelegate <NSObject>

- (void)aliyunVodTopView:(AliyunVodTopView*)topView onBackViewClick:(UIButton *)button;

@end

@interface AliyunVodTopView : UIView
@property (nonatomic, weak)id<AliyunVodTopViewDelegate>topViewDelegate;
@property (nonatomic, assign)AliyunVodPlayerViewSkin skin;
@property (nonatomic, copy)NSString *topTitle;

@end
