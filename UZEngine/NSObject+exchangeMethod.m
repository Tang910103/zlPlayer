//
//  NSObject+exchangeMethod.m
//  KangDeDoctor
//
//  Created by tederen on 2018/3/29.
//  Copyright © 2018年 tederen. All rights reserved.
//

#import "NSObject+exchangeMethod.h"
#import <objc/runtime.h>

@implementation NSObject (exchangeMethod)
+ (void)exchangeInstanceMethod:(NSArray <NSString *>*)methodNames prefix:(NSString *)prefix
{
    prefix = [self prefixCheck:prefix];
    [methodNames enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Method oldMethod = class_getInstanceMethod(self, NSSelectorFromString(obj));
        Method newMethod = class_getInstanceMethod(self, NSSelectorFromString([prefix stringByAppendingString:obj]));
        method_exchangeImplementations(oldMethod, newMethod);
    }];
}
+ (void)exchangeClassMethod:(NSArray<NSString *> *)methodNames prefix:(NSString *)prefix
{
    prefix = [self prefixCheck:prefix];
    [methodNames enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Method oldMethod = class_getClassMethod(self, NSSelectorFromString(obj));
        Method newMethod = class_getClassMethod(self, NSSelectorFromString([prefix stringByAppendingString:obj]));
        method_exchangeImplementations(oldMethod, newMethod);
    }];
}

+ (NSString *)prefixCheck:(NSString *)prefix {
    
    prefix = [prefix stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (prefix == nil || prefix.length == 0) {
        prefix = @"new_";
    }
    return prefix;
}
@end

