//
//  AliyunPVBaseLayer.h
//  AliyunVodPlayerViewSDK
//
//  Created by SMY on 16/9/8.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPVPrivateDefine.h"
#import "AliyunVodPlayerViewDefine.h"
#import "AliyunPVVideo.h"

typedef NS_ENUM(int, AliyunPVDirection) {
    AliyunPVDirectionNone,
    AliyunPVDirectionUp,
    AliyunPVDirectionDown,
    AliyunPVDirectionLeft,
    AliyunPVDirectionRight
};

typedef NS_ENUM(int, AliyunPVTapClickedEvent) {
    AliyunPVTapClickedEventNone = 0,
    AliyunPVTapClickedEventSingle,
    AliyunPVTapClickedEventDouble,
   
};

@class AliyunPVBaseLayer;
@protocol AliyunPVBaseLayerDelegate <NSObject>

- (void)baseLayer:(AliyunPVBaseLayer *)baseLayer tapClieckedNumbers:(AliyunPVTapClickedEvent)event;

- (void)baseLayer:(AliyunPVBaseLayer *)baseLayer gestureState:(UIGestureRecognizerState)gestureState
                                               onPanBegin:(float)beginFloat
                                              onPanMoving:(float)movingFloat
                                                 onPanEnd:(float)endFloat
                                                direction:(AliyunPVDirection)direction;

- (void)baseLayer:(AliyunPVBaseLayer *)baseLayer chanageBrightnessValue:(float)seekValue direction:(AliyunPVDirection)direction;

@end
@interface AliyunPVBaseLayer : UIView 

@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, getter=isEnableGesture) BOOL enableGesture;
@property (nonatomic, weak) id<AliyunPVBaseLayerDelegate>baseDelegate;
@property (nonatomic, assign) AliyunVodPlayerViewSkin skin;
@property (nonatomic, assign) float horizontalOffsetWithPanGesture ;

// 由子类重写，水平移动时算出的seek time
//单击
- (void)tap:(UITapGestureRecognizer *)gesture;

//双击
- (void)doubleTap:(UITapGestureRecognizer *)gesture;

//滑动
- (void)pan:(UIPanGestureRecognizer *)gesture;

//开始滑动
- (void)onPanBegin:(float)beginPlayTime direction:(AliyunPVDirection)direction;

//滑动中
- (void)onPanMoving:(float)offset direction:(AliyunPVDirection)direction;

//滑动结束
- (void)onPanEnd:(float)totalOffset direction:(AliyunPVDirection)direction;


- (void)updateViewWithPlayerState:(AliyunVodPlayerState)state;
- (void)show;
- (void)dismiss;
- (float)pxConvertToPt:(float)px;

@end
