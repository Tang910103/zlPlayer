//
//  PlayerTool.m
//  zlPlayer
//
//  Created by Tang杰 on 2018/4/17.
//  Copyright © 2018年 Tang杰. All rights reserved.
//

#import "PlayerTool.h"


@implementation PlayerTool
+ (NSString *) res_zlPlayerPath{
    return [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"res_zlPlayer/"];
}
+ (NSString *) targetPath{
    return [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"target/"];
}

+ (UIImage *)imageWithName:(NSString *)imageName {
    NSString *path = [[PlayerTool res_zlPlayerPath] stringByAppendingPathComponent:imageName];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (!image) {
        image = [UIImage imageNamed:imageName];
    }
    return image;
}
//将数值转换成时间
+ (NSString *)convertTime:(CGFloat)second
{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}
@end
