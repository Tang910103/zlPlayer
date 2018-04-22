//
//  PlayerTool.h
//  zlPlayer
//
//  Created by Tang杰 on 2018/4/17.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface PlayerTool : NSObject
+ (NSString *) res_zlPlayerPath;
+ (NSString *) targetPath;

+ (UIImage *)imageWithName:(NSString *)imageName;

+ (NSString *)convertTime:(CGFloat)second;
@end
