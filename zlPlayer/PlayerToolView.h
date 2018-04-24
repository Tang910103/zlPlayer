//
//  PlayerToolView.h
//  zlPlayer
//
//  Created by Tang杰 on 2018/4/22.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@protocol PlayerToolViewDelegate<NSObject>
- (void)exitFullScreen;
@end

@interface PlayerToolView : UIView 
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, copy) NSString *title;

- (void)updateTotalTime:(CMTime)timer;
- (void)updatePlayTime:(CMTime)timer;
@end
