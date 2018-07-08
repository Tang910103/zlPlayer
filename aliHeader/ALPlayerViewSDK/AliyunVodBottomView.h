//
//  AlyunVodBottomView.h
//  playtset
//
//  Created by 王凯 on 2017/9/13.
//  Copyright © 2017年 com.alibaba.ALPlayerVodSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunVodProgressView.h"

@class AliyunVodBottomView;
@protocol AliyunVodBottomViewDelegate <NSObject>

- (void)aliyunVodBottomView:(AliyunVodBottomView *)bottomView dragProgressSliderValue:(float)progressValue;
- (void)aliyunVodBottomView:(AliyunVodBottomView *)bottomView buttonClicked:(NSInteger)buttonTag;

@end
@interface AliyunVodBottomView : UIView

@property (nonatomic, weak) id<AliyunVodBottomViewDelegate>bottomViewDelegate;
@property (nonatomic, assign)AliyunVodPlayerViewSkin skin;

@property (nonatomic ,strong)UIButton *playButton;
@property (nonatomic ,strong)UIButton *fullScreenButton;
@property (nonatomic ,strong)UIButton *qualityButton;

@property (nonatomic ,strong)UILabel *leftTimeLabel;
@property (nonatomic ,strong)UILabel *rightTimeLabel;
@property (nonatomic ,strong)UILabel *fullScreenTimeLabel;

@property (nonatomic ,strong)AliyunVodProgressView *progressView;


- (void)setQualityButtonTitle:(NSString *)title;

- (void)setAllQualitys:(NSArray *)allQualitys;



@end
