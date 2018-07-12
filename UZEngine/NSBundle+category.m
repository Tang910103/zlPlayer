//
//  NSBundle+category.m
//  intellect_socket
//
//  Created by Tang杰 on 17/4/7.
//  Copyright © 2017年 LinLang. All rights reserved.
//

#import "NSBundle+category.h"
#import <objc/runtime.h>
const void *myLanguage = @"my language";

@interface LanguageBundle : NSBundle

@end

@implementation LanguageBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    NSBundle *bundle = objc_getAssociatedObject(self, myLanguage);
    
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] : [super localizedStringForKey:key value:value table:tableName];
}

@end

@implementation NSBundle (category)

+ (void)setLanguage:(NSString *)language {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [LanguageBundle class]);
    });
    
    objc_setAssociatedObject([NSBundle mainBundle], myLanguage, language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
