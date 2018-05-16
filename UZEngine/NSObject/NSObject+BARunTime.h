
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

/**
 *  - 添加运行时分类方法
 *  - 用于运行时动态获取当前类的属性列表、方法列表、成员变量列表、协议列表
 *  - 性能优化
 */
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (BARunTime)

/**
 *  将 ‘字典数组‘ 转换成当前模型的对象数组
 *
 *  @param array 字典数组
 *
 *  @return 返回模型对象的数组
 */
+ (NSArray *)ba_objectsWithArray:(NSArray *)array;

/**
 *  返回当前类的所有属性列表
 *
 *  @return 属性名称
 */
+ (NSArray *)ba_propertysList;

/**
 *  返回当前类的所有成员变量数组
 *
 *  @return 当前类的所有成员变量！ 
 *
 *  Tips：用于调试, 可以尝试查看所有不开源的类的ivar
 */
+ (NSArray *)ba_ivarList;

/**
 *  返回当前类的所有方法
 *
 *  @return 当前类的所有成员变量！
 */
+ (NSArray *)ba_methodList;

/**
 *  返回当前类的所有协议
 *
 *  @return 当前类的所有协议！
 */
+ (NSArray *)ba_protocolList;

@end

@interface NSObject (TJRuntime)


///大写首字母
@property (strong, nonatomic) NSString     *initial;

///最原始的字符串
@property (strong, nonatomic) NSString     *string;

///转化得到的大写英文字符串
@property (strong, nonatomic) NSString     *englishString;

///model类型
@property (strong, nonatomic) NSObject     *model;

#pragma mark - 给数组按首字母排序和分组
/**
 *  给数组按首字母排序和分组
 *@param   ary   传进来的数组(数组中可以是字符串、model)
 *@param   name  如果数组中是字符组则可以为nil，如果为model，则是需要排序的属性名
 *@return  返回一个以首字母为key的字典
 */
+ (NSMutableDictionary *)sortAndGroupForArray:(NSArray *)ary PropertyName:(NSString *)name class:(Class)class;

#pragma mark - 给字符串数组进行排序
/**
 *  给字符串数组进行排序
 *@param   ary   字符串数组
 *@return  返回排序好的数组
 */
+ (NSMutableArray *)sortForStringAry:(NSArray *)ary;

/**
 所有的属性和属性值

 @return 属性值
 */
- (nullable NSDictionary *)allPropertieAndValue;

/**
 *  转换为JSON Data
 */
- (NSData *)tj_JSONData;
/**
 *  转换为字典或者数组
 */
- (id)tj_JSONObject;
/**
 *  转换为JSON 字符串
 */
- (NSString *)tj_JSONString;

+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSDictionary *)getIPAddresses;

@end

NS_ASSUME_NONNULL_END
