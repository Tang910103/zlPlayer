//
//  AlyunVodProgressView.h
//  playtset
//
//  Created by 王凯 on 2017/9/13.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunVodSlider.h"

@class AliyunVodProgressView;
@protocol AliyunVodProgressViewDelegate <NSObject>

- (void)aliyunVodProgressView : (AliyunVodProgressView *)progressView dragProgressSliderValue:(float)value;

@end

@interface AliyunVodProgressView : UIView

@property (nonatomic, weak)id<AliyunVodProgressViewDelegate>progressViewDelegate;
@property (nonatomic,strong)UIProgressView *loadtimeView;
@property (nonatomic,strong)AliyunVodSlider*playtimeSlider;

@property (nonatomic ,assign)AliyunVodPlayerViewSkin skin;

- (void)setLoadTime:(float)loadtime currentTime:(float)currentTime durationTime : (float)durationTime;
@end
