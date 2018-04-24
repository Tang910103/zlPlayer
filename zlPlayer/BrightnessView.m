//
//  BrightnessView.m
//  zlPlayer
//
//  Created by Tang杰 on 2018/4/23.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import "BrightnessView.h"
#import "Masonry.h"
#import "PlayerTool.h"

#define LIGHT_VIEW_COUNT 16

@interface BrightnessView()
@property (nonatomic, strong) NSMutableArray * lightViewArr;
@end

@implementation BrightnessView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 155, 155);
        self.backgroundColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0];
        self.layer.cornerRadius = 10.f;
        self.layer.masksToBounds = YES;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:16.f];
        label.textColor = [UIColor blackColor];
        label.text = @"亮度";
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@30);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[PlayerTool imageWithName:@"亮度"]];
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(label.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(95, 95));
        }];
        
        UIView *lightBackView = [[UIView alloc] init];
        [self addSubview:lightBackView];
        lightBackView.backgroundColor = [UIColor colorWithRed:65/255.0 green:67/255.0 blue:70/255.0 alpha:1.0];
        [lightBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.height.equalTo(@6);
            make.bottom.equalTo(self).offset(-15);
        }];
        
        self.lightViewArr = [[NSMutableArray alloc] init];
        self.layer.cornerRadius = 10.0;
        float backWidth = self.bounds.size.width - 10 * 2;
        float backHeight = 6;
        float viewWidth = (backWidth - (LIGHT_VIEW_COUNT + 1))/16;
        float viewHeight =  backHeight - 2;
        UIView *leftView = lightBackView;
        for (int i = 0; i < LIGHT_VIEW_COUNT; ++i) {
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(1 + i * (viewWidth + 1), 1, viewWidth, viewHeight)];
            view.backgroundColor = [UIColor whiteColor];
            [self.lightViewArr addObject:view];
            [lightBackView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(leftView == lightBackView ? leftView : leftView.mas_right).offset(1);
                make.height.equalTo(@(viewHeight));
                make.width.equalTo(@(viewWidth));
                make.centerY.equalTo(lightBackView);
            }];
            leftView = view;
        }
    }
    return self;
}
-(void)changeLightViewWithValue:(float)lightValue
{
    NSInteger allCount = self.lightViewArr.count;
    NSInteger lightCount = lightValue * allCount;
    for (int i = 0; i < allCount; ++i) {
        UIView * view = self.lightViewArr[i];
        if (i < lightCount) {
            view.backgroundColor = [UIColor whiteColor];
        }else{
            view.backgroundColor = view.superview.backgroundColor;
        }
    }
}
@end
