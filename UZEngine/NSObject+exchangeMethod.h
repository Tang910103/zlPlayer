//
//  NSObject+exchangeMethod.h
//  KangDeDoctor
//
//  Created by tederen on 2018/3/29.
//  Copyright © 2018年 tederen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (exchangeMethod)

/**
 替换实例方法
 @param methodNames 方法名数组（@[NSStringFromSelector(@selector(awakeFromNib))]）
 @param prefix 新方法前缀，如果prefix为nil或去掉空格后为nil，默认使用@"new_";(new_awakeFromNib)
 */
+ (void)exchangeInstanceMethod:(NSArray <NSString *>*)methodNames prefix:(NSString *)prefix;
/**
 替换类方法
 @param methodNames 方法名数组（@[NSStringFromSelector(@selector(awakeFromNib))]）
 @param prefix 新方法前缀，如果prefix为nil或去掉空格后为nil，默认使用@"new_";(new_awakeFromNib)
 */
+ (void)exchangeClassMethod:(NSArray <NSString *>*)methodNames prefix:(NSString *)prefix;
@end
