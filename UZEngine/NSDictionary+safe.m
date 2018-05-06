
//
//  NSDictionary+safe.m
//  KangDeDoctor
//
//  Created by tederen on 2018/4/18.
//  Copyright © 2018年 tederen. All rights reserved.
//

#import "NSDictionary+safe.h"
#import "NSObject+exchangeMethod.h"


@implementation NSDictionary (safe)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
 
        NSArray *classMethod = @[NSStringFromSelector(@selector(dictionaryWithObjects:forKeys:count:))];
        [self exchangeClassMethod:classMethod prefix:nil];

        NSArray *instanceMethod = @[NSStringFromSelector(@selector(initWithObjects:forKeys:count:))];
        [self exchangeInstanceMethod:instanceMethod prefix:nil];

        [NSClassFromString(@"__NSDictionaryI") exchangeInstanceMethod:@[NSStringFromSelector(@selector(objectForKey:))] prefix:nil];
    });
}
+ (instancetype)new_dictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt
{
    //处理错误的数据，然后重新初始化一个字典
    NSUInteger index = 0;
    id  _Nonnull __unsafe_unretained newObjects[cnt];
    id  _Nonnull __unsafe_unretained newkeys[cnt];

    for (int i = 0; i < cnt; i++) {
        if (!objects[i] || !keys[i]) {
            NSString *s = [NSString stringWithFormat:@"object or key 值不能为nil"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"obj" object:self userInfo:nil];
            NSAssert(NO, s);
            continue;
        }
        newObjects[index] = objects[i];
        newkeys[index] = keys[i];
        index++;
    }

    return [self new_dictionaryWithObjects:newObjects forKeys:newkeys count:index];
}

- (instancetype)new_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt
{
    return [NSDictionary new_dictionaryWithObjects:objects forKeys:keys count:cnt];
}
- (id)new_objectForKey:(id)aKey
{
    id value = [self new_objectForKey:aKey];
    if ([value isKindOfClass:[NSNull class]]) {
        value = nil;
    }
    return value;
}
@end

@implementation NSMutableDictionary (safe)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *instanceMethod = @[NSStringFromSelector(@selector(setObject:forKey:))];
        [self exchangeInstanceMethod:instanceMethod prefix:nil];
    });
}
- (void)new_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject && aKey) {
        [self new_setObject:anObject forKey:aKey];
    } else {
        NSString *s = [NSString stringWithFormat:@"object or key 值不能为nil"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"obj" object:self userInfo:nil];
        NSAssert(NO, s);
    }
}
@end
