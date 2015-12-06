//
//  AZXSearchController.h
//  AZXSearchControllerDemo
//
//  Created by Azen.Xu on 15/12/5.
//  Copyright © 2015年 Azen.Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AZXSearchControllerType) //  搜索控制器类型
{
    AZXSearchControllerTypePartOne = 1 << 0,   //  板块一
    AZXSearchControllerTypePartTwo = 1 << 1,   //  板块二
    AZXSearchControllerTypePartThree = 1 << 2  //  板块三
};

typedef NS_ENUM(NSInteger, AZXSearchFunctionType)   //  点击事件类型
{
    AZXSearchFunctionTypeClear = 1 << 0,    //  点击了"清除搜索历史"按钮
    AZXSearchFunctionTypeSearch = 1 << 1,   //  点击了"搜索"按钮
    AZXSearchFunctionTypeSearchArray = 1 << 2,    //  点选了搜索结果列表
    AZXSearchFunctionTypeHotArray = 1 << 3,       //  点选了热门搜索列表
    AZXSearchFunctionTypeHistoryArray = 1 << 4,   //  点选了历史搜索列表
    AZXSearchFunctionTypeCreatTagForDiscover = 1 << 5   //  点选了创建标签
};

typedef void(^AZXSearchCallBack)(AZXSearchFunctionType selectedType , NSInteger selectedRowIndex , NSString *resultString); //  点击回调 参数一：点击事件类型 参数二：选中行号 参数三：选中文字
typedef void(^AZXSearchSetNewArrayHandle)(NSArray *newArray);   //  通过此block传递搜索结果字符串数组


@interface AZXSearchController : UIViewController

/**
 *  根据type创建不同展示样式的搜索控制器,返回搜索结果handleArray
 *
 *  @param fromController 来源控制器
 *  @param hotArray       热门搜索stringArray
 *  @param hisArray       历史搜索stringArray
 *  @param type           样式枚举
 *  @param calBack        回调 - 数据请求成功后请为handleStringArray重新赋值
 *
 *  @return 搜索结果handelArray
 */
+ (AZXSearchSetNewArrayHandle)showSearchControllerFromController :(UIViewController *)fromController
                                            withHotKeywordsArray :(NSArray *)hotArray
                                            historyKeywordsArray :(NSArray *)hisArray
                                                            type :(AZXSearchControllerType)type
                                                        callBack :(AZXSearchCallBack)callBack;

@end
