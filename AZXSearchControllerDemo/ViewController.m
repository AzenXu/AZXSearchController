//
//  ViewController.m
//  AZXSearchControllerDemo
//
//  Created by Azen.Xu on 15/12/5.
//  Copyright © 2015年 Azen.Xu. All rights reserved.
//

#import "ViewController.h"
#import "AZXSearchController.h"

@interface ViewController ()

/** 搜索结果传值Block*/
@property(copy,nonatomic) AZXSearchSetNewArrayHandle handle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    __weak typeof(self) weakSelf = self;
    
    self.handle = [AZXSearchController showSearchControllerFromController:self withHotKeywordsArray:@[@"帅锅",@"美眉"] historyKeywordsArray:@[@"TFBoys",@"TFS"] type:(AZXSearchControllerTypePartOne) callBack:^(AZXSearchFunctionType selectedType, NSInteger selectedRowIndex, NSString *resultString) {
        NSLog(@"%zd -- %zd -- %@",selectedType,selectedRowIndex,resultString);
        
        
        //  模拟请求到数据后的传值
        if (selectedType == AZXSearchFunctionTypeSearch) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.handle(@[@"搜索结果一",@"搜索结果二"]);
            });
        }
    }];
}
@end
