//
//  NSArrary+safe.m
//  KangDeDoctor
//
//  Created by tederen on 2018/4/17.
//  Copyright © 2018年 tederen. All rights reserved.
//

#import "NSArrary+safe.h"
#import "NSObject+exchangeMethod.h"
#import <objc/runtime.h>

@implementation NSArray (safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *classMethod = @[NSStringFromSelector(@selector(arrayWithObjects:count:))];
        [self exchangeClassMethod:classMethod prefix:nil];

        [NSClassFromString(@"__NSArrayM") exchangeInstanceMethod:@[NSStringFromSelector(@selector(objectAtIndex:)),NSStringFromSelector(@selector(arrayByAddingObject:)),NSStringFromSelector(@selector(arrayByAddingObject:))] prefix:nil];
    });
}
- (id)new_objectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self new_objectAtIndex:index];
    }
    return nil;
}
- (NSArray *)new_arrayByAddingObject:(id)anObject
{
    if (anObject) {
        return [self new_arrayByAddingObject:anObject];
    } else {
        NSAssert(anObject, @"数组不能添加空数据nil");
        return self;
    }
}
+ (instancetype)new_arrayWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt
{
    NSUInteger index = 0;
    id  _Nonnull __unsafe_unretained newObjects[cnt];
    
    for (int i = 0; i < cnt; i++) {
        if (!objects[i]) {
            NSAssert(NO, @"数组不能添加空数据nil");
            continue;
        }
        newObjects[index] = objects[i];
        index++;
    }
    
    return [self new_arrayWithObjects:newObjects count:index];
}
@end
@implementation NSMutableArray (safe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSClassFromString(@"__NSArrayM") exchangeInstanceMethod:@[NSStringFromSelector(@selector(insertObject:atIndex:))] prefix:@"mutable_"];
    });
}

- (void)mutable_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject) {
        [self mutable_insertObject:anObject atIndex:index];
    } else {
        NSAssert(anObject, @"数组不能插入空数据nil");
    }
}
@end
