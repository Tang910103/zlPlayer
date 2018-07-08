//
//  PVDropDownModule.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/8/9.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunPVQualityListViewDelegate <NSObject>
/*
 * 功能 ：清晰度列表选择
 */
- (void)qualityListViewOnItemClick:(int)index;

/*
 * 功能 ：清晰度列表选择，MTS播放方式
 */
- (void)qualityListViewOnDefinitionClick:(NSString*)videoDefinition;
@end

@interface AliyunPVQualityListView : UIView

/*
 * 功能 ：代理
 */
@property (nonatomic, weak) id<AliyunPVQualityListViewDelegate> delegate;

/*
 * 功能 ：清晰度列表信息
 */
@property (nonatomic, strong) NSArray *allSupportQualitys;

/*
 * 功能 ：根据播放方式，确定清晰度 名称。
 */
@property (nonatomic, assign) AliyunVodPlayerViewPlayMethod playMethod;

/*
 * 功能 ：计算清晰度列表所需高度
 */
- (float)estimatedHeight;

/*
 * 功能 ：清晰度按钮颜色改变
 */
- (void)setCurrentQuality:(int)quality;

/*
 * 功能 ：清晰度按钮颜色改变
 */
- (void)setCurrentDefinition:(NSString*)videoDefinition;
@end
