//
//  PVDropDownModule.m
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/8/9.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "AliyunPVQualityListView.h"
#import "AliyunPVUtil.h"

static const int ALYPV_BUTTON_HEIGHT = 64;

@interface AliyunPVQualityListView ()
@property (nonatomic, assign) BOOL isChangedRow;
/*
 * 功能 ：清晰度按钮数组
 */
@property (nonatomic, strong)NSMutableArray<UIButton *> *qualityBtnArray;
@end
@implementation AliyunPVQualityListView

#pragma mark - init
- (instancetype)init{
    self = [super init];
    if (self) {
        _playMethod = AliyunVodPlayerViewPlayMethodSTS;
        self.clipsToBounds = NO;
        self.backgroundColor = ALPV_POP_BG_QUALITY_LIST;
    }
    return self;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    float width = self.bounds.size.width;
    float btnHeight = [AliyunPVUtil convertPixelToPoint:ALYPV_BUTTON_HEIGHT];
    for (int i = 0; i < _qualityBtnArray.count; i++) {
        UIButton *btn = _qualityBtnArray[i];
        btn.frame = CGRectMake(0, btnHeight * i, width, btnHeight);
    }
}

#pragma  mark - needHeight
- (float)estimatedHeight {
    return [self.allSupportQualitys count] * [AliyunPVUtil convertPixelToPoint:ALYPV_BUTTON_HEIGHT];
}

#pragma mark - 监测字符串中的int值
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

#pragma mark - allSupportQuality
-(void)setAllSupportQualitys:(NSArray *)allSupportQuality {
    if ([allSupportQuality count] == 0) {
        return;
    }
    _allSupportQualitys = allSupportQuality;
    _qualityBtnArray = [NSMutableArray array];
    
    //枚举类型
    NSArray *ary  = [AliyunPVUtil allQualitys];
    for (int i = 0; i < allSupportQuality.count; i++) {
        
        int tempTag = -1;
        UIButton *btn = [[UIButton alloc] init];
        if (self.playMethod == AliyunVodPlayerViewPlayMethodMPS) {
            tempTag = i+100000;
            [btn setTitle:allSupportQuality[i] forState:UIControlStateNormal];
        }else{
            tempTag = [allSupportQuality[i] intValue]+100000;
            [btn setTitle:ary[[allSupportQuality[i] intValue]] forState:UIControlStateNormal];
        }
        
        UIButton *tempButton = (UIButton *)[self viewWithTag:tempTag];
        if (tempButton) {
            [tempButton removeFromSuperview];
            tempButton = nil;
        }

        [btn setTitleColor:ALPV_COLOR_TEXT_GRAY forState:UIControlStateNormal];
        [btn setTitleColor:ALPV_COLOR_BLUE forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:[AliyunPVUtil nomalTextSize]]];
        [btn setTag:tempTag];
        [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [_qualityBtnArray addObject:btn];
    }
}

#pragma mark - quality
- (void)setCurrentQuality:(int)quality {
    if (![self.allSupportQualitys containsObject:[NSString stringWithFormat:@"%d", quality]]) {
        return;
    }
    for (UIButton *btn in self.qualityBtnArray) {
        if (btn.tag == quality) {
            [btn setTitleColor:ALPV_COLOR_BLUE forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:ALPV_COLOR_TEXT_NOMAL forState:UIControlStateNormal];
        }
    }
}

#pragma mark - videoDefinition
- (void)setCurrentDefinition:(NSString*)videoDefinition{
    if (![self.allSupportQualitys containsObject:videoDefinition]) {
        return;
    }
    for (UIButton *btn in self.qualityBtnArray) {
        if ([btn.titleLabel.text isEqualToString:videoDefinition]) {
            [btn setTitleColor:ALPV_COLOR_BLUE forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:ALPV_COLOR_TEXT_NOMAL forState:UIControlStateNormal];
        }
    }
}

#pragma mark - onClick
- (void)repeatDelay{
    self.isChangedRow = false;
}
- (void)onClick:(UIButton *)btn {
    if (self.isChangedRow == false) {
        self.isChangedRow = true;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatDelay) object:nil];
        [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:2];
        
        if (self.playMethod == AliyunVodPlayerViewPlayMethodMPS) {
            NSString* videoDefinition = btn.titleLabel.text;
            if (self.delegate) {
                [self.delegate qualityListViewOnDefinitionClick:videoDefinition];
            }
        }else{
            int tag = (int) btn.tag-100000;
            if (self.delegate) {
                [self.delegate qualityListViewOnItemClick:tag];
            }
        }
    }else{
        return;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}


@end
