
/*!
 *  @header BAKit.h
 *          BABaseProject
 *
 *  @brief  BAKit
 *
 *  @author 博爱
 *  @copyright    Copyright © 2016年 博爱. All rights reserved.
 *  @version    V1.0
 */

//                            _ooOoo_
//                           o8888888o
//                           88" . "88
//                           (| -_- |)
//                            O\ = /O
//                        ____/`---'\____
//                      .   ' \\| |// `.
//                       / \\||| : |||// \
//                     / _||||| -:- |||||- \
//                       | | \\\ - /// | |
//                     | \_| ''\---/'' | |
//                      \ .-\__ `-` ___/-. /
//                   ___`. .' /--.--\ `. . __
//                ."" '< `.___\_<|>_/___.' >'"".
//               | | : `- \`.;`\ _ /`;.`/ - ` : | |
//                 \ \ `-. \_ __\ /__ _/ .-` / /
//         ======`-.____`-.___\_____/___.-`____.-'======
//                            `=---='
//
//         .............................................
//                  佛祖镇楼                  BUG辟易
//          佛曰:
//                  写字楼里写字间，写字间里程序员；
//                  程序人员写程序，又拿程序换酒钱。
//                  酒醒只在网上坐，酒醉还来网下眠；
//                  酒醉酒醒日复日，网上网下年复年。
//                  但愿老死电脑间，不愿鞠躬老板前；
//                  奔驰宝马贵者趣，公交自行程序员。
//                  别人笑我忒疯癫，我笑自己命太贱；
//                  不见满街漂亮妹，哪个归得程序员？

/*
 
 *********************************************************************************
 *
 * 在使用BAKit的过程中如果出现bug请及时以以下任意一种方式联系我，我会及时修复bug
 *
 * QQ     : 可以添加ios开发技术群 479663605 在这里找到我(博爱1616【137361770】)
 * 微博    : 博爱1616
 * Email  : 137361770@qq.com
 * GitHub : https://github.com/boai
 * 博客园  : http://www.cnblogs.com/boai/
 * 博客    : http://boai.github.io
 * 简书    : http://www.jianshu.com/users/95c9800fdf47/latest_articles
 * 简书专题 : http://www.jianshu.com/collection/072d578bf782
 
 *********************************************************************************
 
 */


#import "NSObject+BARunTime.h"
#import <objc/runtime.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation NSObject (BARunTime)

#pragma mark - 根据传递进来的所有字典数组 字典转模型
+ (NSArray *)ba_objectsWithArray:(NSArray *)array
{
    if (array.count == 0)
    {
        return nil;
    }
    
    // 判断是否是字典数组
    NSAssert([array[0] isKindOfClass:[NSDictionary class]], @"必须传入字典数组");
    
    // 获取属性列表数组
    NSArray *propertyList = [self ba_propertysList];
    
    NSMutableArray *arrayM = [NSMutableArray array];
  
    for (NSDictionary *dict in array)
    {
        // 创建模型
        id model = [self new];
        
        // 遍历数组
        for (NSString *key in dict)
        {
            // 判断属性列表数组中是否包含当前key 如果有, 意味着属性存在
            if ([propertyList containsObject:key]) {
                // 字典转模型
                [model setValue:dict[key] forKey:key];
            }
        }
        // 添加到可变数组中
        [arrayM addObject:model];
    }
    return arrayM;
}

#pragma mark - 获取本类所有 ‘属性‘ 的数组
/** 程序运行的时候动态的获取当前类的属性列表 
 *  程序运行的时候,类的属性不会变化
 */
const void *ba_propertyListKey = @"ba_propertyListKey";
+ (NSArray *)ba_propertysList
{
    NSArray *result = objc_getAssociatedObject(self, ba_propertyListKey);
    
    if (result != nil)
    {
        return result;
    }
    
    NSMutableArray *arrayM = [NSMutableArray array];
    // 获取当前类的属性数组
    // count -> 属性的数量
    unsigned int count = 0;
   objc_property_t *list = class_copyPropertyList([self class], &count);
    
    for (unsigned int i = 0; i < count; i++) {
        // 根据下标获取属性
        objc_property_t property = list[i];
        
        // 获取属性的名字
        const char *cName = property_getName(property);
        
        // 转换成OC字符串
        NSString *name = [NSString stringWithUTF8String:cName];
        [arrayM addObject:name];
    }
    
    /*! ⚠️注意： 一定要释放数组 class_copyPropertyList底层为C语言，所以我们一定要记得释放properties */
    free(list);
    
    // ---保存属性数组对象---
    objc_setAssociatedObject(self, ba_propertyListKey, arrayM, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return objc_getAssociatedObject(self, ba_propertyListKey);
}

#pragma mark - 获取本类所有 ‘方法‘ 的数组
const void *ba_methodListKey = "ba_methodListKey";
+ (NSArray *)ba_methodList
{
    // 1. 使用运行时动态添加属性
    NSArray *methodsList = objc_getAssociatedObject(self, ba_methodListKey);
    
    // 2. 如果数组中直接返回方法数组
    if (methodsList != nil)
    {
        return methodsList;
    }
    
    // 3. 获取当前类的方法数组
    unsigned int count = 0;
    Method *list = class_copyMethodList([self class], &count);
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (unsigned int i = 0; i < count; i++)
    {
        // 根据下标获取方法
        Method method = list[i];
        
       SEL methodName = method_getName(method);
        
        NSString *methodName_OC = NSStringFromSelector(methodName);
        
//        IMP imp = method_getImplementation(method);
        const char *name_s =sel_getName(method_getName(method));
        int arguments = method_getNumberOfArguments(method);
        const char* encoding =method_getTypeEncoding(method);
        NSLog(@"方法名：%@,参数个数：%d,编码方式：%@",[NSString stringWithUTF8String:name_s],
              arguments,
              [NSString stringWithUTF8String:encoding]);
        
        [arrayM addObject:methodName_OC];
    }
    
    // 4. 释放数组
    free(list);
    
    // 5. 保存方法的数组对象
    objc_setAssociatedObject(self, ba_methodListKey, arrayM, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return objc_getAssociatedObject(self, ba_methodListKey);
}


#pragma mark - 获取本类所有 ‘成员变量‘ 的数组 <用来调试>
/** 获取当前类的所有成员变量 */
const char *ba_ivarListKey = "ba_ivarListKey";
+ (NSArray *)ba_ivarList
{
   
    // 1. 查询根据key 保存的成员变量数组
    NSArray *ivarList = objc_getAssociatedObject(self, ba_ivarListKey);
    
    // 2. 判断数组中是否有值, 如果有直接返回
    if (ivarList != nil)
    {
        return ivarList;
    }
    
    // 3. 如果数组中没有, 则根据当前类,获取当前类的所有 ‘成员变量‘
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    
    // 4. 遍历 成员变量 数组, 获取成员变量的名
    NSMutableArray *arrayM = [NSMutableArray array];
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        // - C语言的字符串都是 ‘char *‘ 类型的
        const char *ivarName_C = ivar_getName(ivar);
        
        // - 将 C语言的字符串 转换成 OC字符串
        NSString *ivarName_OC = [NSString stringWithUTF8String:ivarName_C];
        // - 将本类 ‘成员变量名‘ 添加到数组
        [arrayM addObject:ivarName_OC];
    }
    
    // 5. 释放ivars
    free(ivars);
    
    // 6. 根据key 动态获取保存在关联对象中的数组
    objc_setAssociatedObject(self, ba_ivarListKey, arrayM, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return objc_getAssociatedObject(self, ba_ivarListKey);
}

#pragma mark - 获取本类所有 ‘协议‘ 的数组
/** 用来获取动态保存在关联对象中的协议数组 |运行时的关联对象根据key动态取值| */
const char *ba_protocolListKey = "ba_protocolListKey";

+ (NSArray *)ba_protocolList {
    NSArray *protocolList = objc_getAssociatedObject(self, ba_protocolListKey);
    if (protocolList != nil)
    {
        return protocolList;
    }
    
    unsigned int count = 0;
    Protocol * __unsafe_unretained *protocolLists = class_copyProtocolList([self class], &count);
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (unsigned int i = 0; i < count; i++) {
        // 获取 协议名
        Protocol *protocol = protocolLists[i];
        const char *protocolName_C = protocol_getName(protocol);
        NSString *protocolName_OC = [NSString stringWithUTF8String:protocolName_C];
        
        // 将 协议名 添加到数组
        [arrayM addObject:protocolName_OC];
    }
    
    // 释放数组
    free(protocolLists);
    // 将保存 协议的数组动态添加到 关联对象
    objc_setAssociatedObject(self, ba_protocolListKey, arrayM, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return objc_getAssociatedObject(self, ba_protocolListKey);
}

@end

@implementation NSObject (TJRuntime)

- (void)setString:(NSString *)string
{
    objc_setAssociatedObject(self, @selector(string), string, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)string
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setInitial:(NSString *)initial
{
    objc_setAssociatedObject(self, @selector(initial), initial, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)initial
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEnglishString:(NSString *)englishString
{
    objc_setAssociatedObject(self, @selector(englishString), englishString, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)englishString
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setModel:(NSObject *)model
{
    objc_setAssociatedObject(self, @selector(model), model, OBJC_ASSOCIATION_RETAIN);
}

- (NSObject *)model
{
    return objc_getAssociatedObject(self, _cmd);
}

+ (NSMutableArray *)sortForStringAry:(NSArray *)ary {
    NSMutableArray *sortAry = [NSMutableArray arrayWithArray:ary];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *descriptorAry = [NSArray arrayWithObject:descriptor];
    [sortAry sortUsingDescriptors:descriptorAry];
    
    //将 # 数据放到末尾
    NSMutableArray *removeAry = [NSMutableArray new];
    for (NSString *str in sortAry){
        if ([str isEqualToString:@"#"]) {
            [removeAry addObject:str];
            break;
        }
    }
    [sortAry removeObjectsInArray:removeAry];
    [sortAry addObjectsFromArray:removeAry];
    
    return sortAry;
}
/**
 *  将数组按首字母排序
 */
+ (NSMutableArray *)sortAsInitialWithArray:(NSArray *)ary {
    //存储包含首字母和字符串的对象
    NSMutableArray *objectAry = [NSMutableArray array];
    
    //遍历的同时把首字符和对应的字符串存入到srotString对象属性中
    for (NSInteger index = 0; index < ary.count; index++) {
        NSObject *sortString = ary[index];
        if (sortString.string == nil) {
            sortString.string = @"";
        }
        sortString.englishString = [NSObject transform:sortString.string];
        
        //判断首字符是否为字母
        NSString *regex = @"[A-Za-z]+";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        //得到字符串首个字符
        NSString *header = [sortString.string substringToIndex:1];
        if ([predicate evaluateWithObject:header]) {
            sortString.initial = [header capitalizedString];
        }else{
            
            if (![sortString.string isEqualToString:@""]) {
                //特殊处理的一个字
                if ([header isEqualToString:@"长"]) {
                    sortString.initial = @"C";
                    sortString.englishString = [sortString.englishString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"C"];
                }else{
                    
                    char initial = [sortString.englishString characterAtIndex:0];
                    if (initial >= 'A' && initial <= 'Z') {
                        sortString.initial = [NSString stringWithFormat:@"%c",initial];
                    }else{
                        sortString.initial = @"#";
                    }
                }
            }else{
                sortString.initial = @"#";
            }
        }
        [objectAry addObject:sortString];
    }
    //先按照首字母initial排序，然后对于首字母相同的再按照englishString排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"initial" ascending:YES];
    NSSortDescriptor *descriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"englishString" ascending:YES];
    NSArray *descriptorAry = [NSArray arrayWithObjects:descriptor,descriptor2, nil];
    [objectAry sortUsingDescriptors:descriptorAry];
    
    return objectAry;
}

+ (NSMutableDictionary *)sortAndGroupForArray:(NSArray *)ary PropertyName:(NSString *)name class:(Class)class{
    NSMutableDictionary *sortDic = [NSMutableDictionary new];
    NSMutableArray *sortAry = [NSMutableArray new];
    NSMutableArray *objAry = [NSMutableArray new];
    NSString *type;
    
    if (ary.count <= 0) {
        NSLog(@"数据源不能为空");
        return sortDic;
    }
    
    if ([class isKindOfClass:[NSString class]]) {
        type = @"string";
        for (NSString *str in ary){
            NSObject *sortString = [NSObject new];
            sortString.string = str;
            [objAry addObject:sortString];
        }
    }else if ([class isKindOfClass:[NSDictionary class]]){
        type = @"dict";
    }else{
        type = @"model";
        unsigned int propertyCount, i;
        
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        
        for (NSObject *obj in ary){
            NSObject *sortString = [NSObject new];
            sortString.model = obj;
            for (i = 0; i < propertyCount; i++) {
                objc_property_t property = properties[i];
                const char *char_name = property_getName(property);
                NSString *propertyName = [NSString stringWithUTF8String:char_name];
                if ([propertyName isEqualToString:name]) {
                    id propertyValue = [obj valueForKey:name];
                    sortString.string = propertyValue;
                    [objAry addObject:sortString];
                    break;
                }
                if (i == propertyCount -1) {
                    NSLog(@"%@",[NSString stringWithFormat:@"数据源中的Model没有你指定的属性:%@",name]);
                    
                    return sortDic;
                }
            }
        }
    }
    
    sortAry = [self sortAsInitialWithArray:objAry];
    
    NSMutableArray *item = [NSMutableArray array];
    NSString *itemString;
    for (NSObject *sort in sortAry){
        //首字母不同则item重新初始化，相同则共用一个item
        if (![itemString isEqualToString:sort.initial]) {
            itemString = sort.initial;
            item = [NSMutableArray array];
            if ([type isEqualToString:@"string"]) {
                [item addObject:sort.string];
            }else if ([type isEqualToString:@"model"]){
                [item addObject:sort.model];
            }
            [sortDic setObject:item forKey:itemString];
        }else{
            //item已添加到 regularAry，所以item数据改变时，对应regularAry中也会改变
            if ([type isEqualToString:@"string"]) {
                [item addObject:sort.string];
            }else if ([type isEqualToString:@"model"]){
                [item addObject:sort.model];
            }
        }
    }
    
    return sortDic;
}

/**
 * 将中文转化为英文(英文不变)
 *@param   chinese   传入的字符串
 *@return  返回去掉空格并大写的字符串
 */
+ (NSString *)transform:(NSString *)chinese
{
    NSMutableString *english = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)english, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)english, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    //去除两端空格和回车 中间空格不用去，用以区分不同汉字
    [english stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [english uppercaseString];
}

- (nullable NSDictionary *)allPropertieAndValue
{
//    unsigned int count = 0;
    
//    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableDictionary *resultDict = [@{} mutableCopy];
    NSArray *properties = [[self class] ba_propertysList];
    for (NSString *name in properties) {
        id propertyValue = [self valueForKey:name];
        if (propertyValue) {
            resultDict[name] = propertyValue;
        }
        else
        {
            resultDict[name] = @"";
        }
    }
    
//    for (NSUInteger i = 0; i < count; i ++) {
//        
//        const char *propertyName = property_getName(properties[i]);
//        NSString *name = [NSString stringWithUTF8String:propertyName];
//        id propertyValue = [self valueForKey:name];
//        
//        if (propertyValue) {
//            resultDict[name] = propertyValue;
//        } else {
//            resultDict[name] = @"字典的key对应的value不能为nil";
//        }
//    }
//    
//    free(properties);
    
    return resultDict;
}

#pragma mark - 转为Data

- (NSData *)tj_JSONData
{
    if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    
    return [NSJSONSerialization dataWithJSONObject:[self tj_JSONObject] options:kNilOptions error:nil];
}
#pragma mark - 转换为JSON
- (id)tj_JSONObject
{
    if ([self isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    } else if ([self isKindOfClass:[NSArray class]]) {
        NSMutableArray *ar = @[].mutableCopy;
        for (NSObject *obj in (NSArray *)self) {
            [ar addObject:[obj allPropertieAndValue]];
        }
        return ar;
    }
    
    return [self allPropertieAndValue];
}
#pragma mark - 转为string

- (NSString *)tj_JSONString
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }
    
    return [[NSString alloc] initWithData:[self tj_JSONData] encoding:NSUTF8StringEncoding];
}

+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    //NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    
    // The dictionary keys have the form "interface" "/" "ipv4 or ipv6"
    return [addresses count] ? addresses : nil;
}

@end
