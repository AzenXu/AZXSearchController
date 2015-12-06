//
//  AZXSearchController.m
//  AZXSearchControllerDemo
//
//  Created by Azen.Xu on 15/12/5.
//  Copyright © 2015年 Azen.Xu. All rights reserved.
//

#import "AZXSearchController.h"
#import "UIView+Location.h"

typedef void(^AZXHeightCallBack)(CGFloat height);
@interface AZXSearchController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
/** tableView*/
@property(strong,nonatomic) UITableView *tableView;
/** 搜索框*/
@property(strong,nonatomic) UISearchBar *searchBar;
/** 占位文字*/
@property(copy,nonatomic) NSString *placeHolder;
/** 回调*/
@property(copy,nonatomic) AZXSearchCallBack callBack;
/** 热门搜索String Array*/
@property(strong,nonatomic) NSArray *hotKeywordsArray;
/** 历史搜索String Array*/
@property(strong,nonatomic) NSArray *historyKeywordsArray;
/** 搜索结果StringArray*/
@property(copy,nonatomic) NSArray *resultArray;
/** 热门搜索Btns*/
@property(strong,nonatomic) NSMutableArray *hotKeywordsBtnArray;
/** 历史搜索Btns*/
@property(strong,nonatomic) NSMutableArray *historyKeywordsBtnArray;
/** 样式 */
@property(assign,nonatomic) AZXSearchControllerType type;
/** 是否点击了搜索 */
@property(assign,nonatomic,getter=isSearching) BOOL searching;
/** 是有有搜索结果 */
@property(assign,nonatomic,getter=hasResult) BOOL result;
/** 设置数据源的block*/
@property(strong,nonatomic) AZXSearchSetNewArrayHandle setNewArrayHandle;

@end

@implementation AZXSearchController
#pragma mark - 构造方法
+ (AZXSearchSetNewArrayHandle)showSearchControllerFromController:(UIViewController *)fromController withHotKeywordsArray:(NSArray *)hotArray historyKeywordsArray:(NSArray *)hisArray type:(AZXSearchControllerType)type callBack:(AZXSearchCallBack)callBack
{
    AZXSearchController *controller = [[AZXSearchController alloc] init];
    controller.callBack = callBack;
    controller.type = type;
    controller.hotKeywordsArray = hotArray;
    controller.historyKeywordsArray = hisArray;
    [fromController.navigationController pushViewController:controller animated:YES];
    return controller.setNewArrayHandle;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBasic];
    [self setupNav];
}

#pragma mark - 初始化
- (void)setupBasic
{
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.searching = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}
- (void)setupNav
{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnDidClick:)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]} forState:UIControlStateNormal];
    [self.searchBar becomeFirstResponder];
}

#pragma mark - 监听
- (void)setResultArray:(NSArray *)resultArray
{
    //  设置数据
    _resultArray = resultArray;
    //  更改状态
    self.result = resultArray.count;
    //  刷新表格
    [self.tableView reloadData];
    //  停掉菊花
//    [self hideHud];
}
- (void)rightBtnDidClick :(UIBarButtonItem *)item
{
    if ([item.title isEqualToString:@"搜索"]) {
        NSLog(@"搜索");
        item.title = @"取消";
        //  标识替换
        self.searching = YES;
        //  传递数据
        self.callBack(AZXSearchFunctionTypeSearch , 0 ,self.searchBar.text);
        //  转菊花等待搜索结果重新赋值
//        [self showHud];
        return;
    }
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@ --textDidChange-- %@",searchText,self.searchBar.text);
    if ([searchText isEqualToString:@""]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"取消"];
        return;
    }
    [self.navigationItem.rightBarButtonItem setTitle:@"搜索"];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //  标识替换
    self.searching = YES;
    //  传递数据
    self.callBack(AZXSearchFunctionTypeSearch , 0 ,self.searchBar.text);
    //  转菊花等待搜索结果重新赋值
//    [self showHud];
    return;
}
- (void)hotArrayBtnClick :(UIButton *)btn
{
    //  返回索引号
    if (self.callBack) {
        self.callBack(AZXSearchFunctionTypeHotArray , btn.tag ,btn.titleLabel.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)historyArrayBtnClick :(UIButton *)btn
{
    //  返回索引号
    if (self.callBack) {
        self.callBack(AZXSearchFunctionTypeHistoryArray , btn.tag , btn.titleLabel.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionNum = 0;
    if (self.isSearching)
    {
        sectionNum = 1;
    }
    else
    {
        if (self.type == AZXSearchControllerTypePartThree)
        {
            sectionNum = 0;
        }
        else
        {
            sectionNum = 2;
        }
    }
    return sectionNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.type == AZXSearchControllerTypePartTwo)
    {
        if (self.isSearching) {
            if (self.hasResult) return self.resultArray.count + 1; //返回数组长度 + 1（提示添加标签）
            else return 2;  //  没结果展示两行 - 第一行提示没结果，第二行提示添加标签
        }
        else
        {
            return 1;
        }
    }
    else if (self.type == AZXSearchControllerTypePartOne)
    {
        if (self.isSearching)
        {
            if (self.hasResult) return self.resultArray.count;
            else return 1;
        }
        else
        {
            return 1;
        }
    }
    else // 默认 - 不展示推荐标签
    {
        if (self.isSearching) {
            if (self.hasResult) return self.resultArray.count;
            else return 1;
        }
        else
        {
            return 0;
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching)   //  点击了搜索
    {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        if (!self.hasResult)    //  没结果，在第一行显示提示
        {
            if (indexPath.row == 0)
            {
                [self showNoneInCell :cell];
            }
            if (indexPath.row == 1) {
                [self showAddTagInCell:cell];
            }
            return cell;
        }
        // 有结果，展示结果
        cell.textLabel.text = self.resultArray[indexPath.row];
        return cell;
    }
    //  没点搜索，展示默认推荐界面
    if (indexPath.section == 0) //  热门搜索
    {
        UITableViewCell *cell = [self creatKeywordCubCellWithArray:self.hotKeywordsArray toArray :self.hotKeywordsBtnArray inTableView :tableView heightCallBack:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    //  历史搜索
    UITableViewCell *cell = [self creatKeywordCubCellWithArray:self.historyKeywordsArray toArray :self.historyKeywordsBtnArray inTableView :tableView heightCallBack:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching)   //  点击了搜索
    {
        return 44;
    }
    //  默认展现
    __block CGFloat cellHeight = 0;
    if (indexPath.row == 0)     //  热门搜索
    {
        UITableViewCell *cell = [self creatKeywordCubCellWithArray:self.hotKeywordsArray toArray:self.hotKeywordsBtnArray inTableView:tableView heightCallBack:^(CGFloat height) {
            cellHeight = height;
        }];
        cell.hidden = YES;
        return cellHeight + 20;
    }
    //  历史搜索计算高度
    UITableViewCell *cell = [self creatKeywordCubCellWithArray:self.historyKeywordsArray toArray :self.historyKeywordsBtnArray inTableView :tableView heightCallBack:^(CGFloat height){
        cellHeight = height;
    }];
    cell.hidden = YES;
    return cellHeight + 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.isSearching)
    {
        return nil;
    }
    if (section == 0) {
        UIView *header = [[UIView alloc] init]; //根据type 创建 @"热门话题" 或 @"热门目的地";
        header.backgroundColor = [UIColor redColor];
        return header;
    }
    if (section == 1) {
        UIView *header = [[UIView alloc] init]; //根据tyoe 创建 @"添加过的话题" 或 @"历史搜索";
        header.backgroundColor = [UIColor blueColor];
        return header;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isSearching) {
        return 0;
    }
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching)  //  点击了搜索
    {
        if (!self.hasResult)    //  没结果点击不处理
        {
            if (self.type == AZXSearchControllerTypePartTwo && indexPath.row == 1)  // 点击创建标签并返回
            {
                self.callBack(AZXSearchFunctionTypeCreatTagForDiscover,indexPath.row,self.searchBar.text);
                [self.navigationController popViewControllerAnimated:YES];
            }
            return;
        }
        //  有结果点击结果退出当前页并回调Block
        if (self.callBack) {
            self.callBack(AZXSearchFunctionTypeSearchArray ,indexPath.row ,self.resultArray[indexPath.row]);
        }
        [self.navigationController popViewControllerAnimated:NO];
        
    }
}

#pragma mark - Inner
- (UITableViewCell *)creatKeywordCubCellWithArray :(NSArray *)keywordArray toArray :(NSMutableArray *)mutableArray inTableView :(UITableView *)tableView heightCallBack :(AZXHeightCallBack)callBack
{
    [mutableArray removeAllObjects];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"keywordCubCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"keywordCubCell"];
    }
    //  创建子View
    UIView *cub = [[UIView alloc] init];
    cub.frame = CGRectMake(0, 0, tableView.bounds.size.width, 250);
    //  关键词组流水布局
    for (int i = 0; i < keywordArray.count; i++) {
        //  设置参数
        CGFloat kKeywordMargin = 10;  // 关键词Btn间距
        CGFloat kBtnLeftMarginToCub = 15; //  按钮距屏幕左边距
        CGFloat kBtnRightMarginToCub = 15; // 按钮距屏幕右边距
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:keywordArray[i] attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1] , NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        [btn setAttributedTitle:attributeString forState:UIControlStateNormal];
        
        if (mutableArray == self.hotKeywordsBtnArray)
        {
            [btn addTarget:self action:@selector(hotArrayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (mutableArray == self.historyKeywordsBtnArray)
        {
            [btn addTarget:self action:@selector(historyArrayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //  设置btn宽度和高度
        [btn sizeToFit];
        btn.width += 20;
        btn.height = 27;
        
        //  边框
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor colorWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:1].CGColor;
        btn.layer.cornerRadius = 3;
        btn.layer.masksToBounds = YES;
        
        btn.backgroundColor = [UIColor whiteColor];
        
        //    流水排布
        if (btn.width > cub.width - 2 * kKeywordMargin)  // 设置Btn最大宽度
        {
            btn.width = cub.width - 2 * kKeywordMargin;
        }
        //  计算Btn的frame
        UIButton *lastBtn = mutableArray.lastObject;
        if (lastBtn == nil)     //  第一个Btn位置
        {
            btn.left = kBtnLeftMarginToCub;
            btn.top = 0;
        }
        else
        {
            CGFloat widthPart = CGRectGetMaxX(lastBtn.frame) + kKeywordMargin;
            btn.left = cub.width - widthPart - kBtnRightMarginToCub > btn.width ? widthPart : kBtnLeftMarginToCub;
            btn.top = cub.width - widthPart - kBtnRightMarginToCub > btn.width ? lastBtn.frame.origin.y : CGRectGetMaxY(lastBtn.frame) + kKeywordMargin;
        }
        
        //  添加Btn
        [mutableArray addObject:btn];
        [cub addSubview:btn];
    }
    
    UIButton *btn = mutableArray.lastObject;
    cub.height = CGRectGetMaxY(btn.frame);
    if (callBack) {
        callBack(cub.height);
    }
    //  添加到cell
    [cell addSubview:cub];
    cell.bounds = cub.frame;
    return cell;
}

- (void)showNoneInCell :(UITableViewCell *)cell
{
    if (self.type & (AZXSearchControllerTypePartOne | AZXSearchControllerTypePartThree) ) {
        NSAttributedString *attributeStringPartOne = [[NSAttributedString alloc] initWithString:@"没有搜索到" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor] , NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        
        NSAttributedString *attributeStringPartTwo = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.searchBar.text] attributes:@{NSForegroundColorAttributeName : [UIColor orangeColor] , NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        
        NSAttributedString *attributeStringPartThree = [[NSAttributedString alloc] initWithString:@"相关的内容，换个关键字搜搜看" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor] , NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        
        NSMutableAttributedString *realResult = [[NSMutableAttributedString alloc] init];
        [realResult appendAttributedString:attributeStringPartOne];
        [realResult appendAttributedString:attributeStringPartTwo];
        [realResult appendAttributedString:attributeStringPartThree];
        
        [cell.textLabel setAttributedText:realResult];
    }
    else
    {
        [cell.textLabel setText:@"没有找到相关话题"];
    }
}

- (void)showAddTagInCell :(UITableViewCell *)cell
{
    if (self.type == AZXSearchControllerTypePartTwo)
    {
        NSAttributedString *attributeStringPartOne = [[NSAttributedString alloc] initWithString:@"创建新话题：" attributes:@{NSForegroundColorAttributeName : [UIColor orangeColor] , NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        
        NSAttributedString *attributeStringPartTwo = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.searchBar.text] attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:99.0/255.0 green:99.0/255.0 blue:99.0/255.0 alpha:1] , NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        
        NSMutableAttributedString *realResult = [[NSMutableAttributedString alloc] init];
        [realResult appendAttributedString:attributeStringPartOne];
        [realResult appendAttributedString:attributeStringPartTwo];
        
        [cell.textLabel setAttributedText:realResult];
    }
}

#pragma mark - Lazy

- (AZXSearchControllerType)type
{
    if (_type == 0) {
        _type = AZXSearchControllerTypePartOne;
    }
    return _type;
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
    }
    return _tableView;
}
- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 275, 30)];
        _searchBar.delegate = self;
        _searchBar.placeholder = self.placeHolder;
    }
    return _searchBar;
}
- (NSString *)placeHolder
{
    if (!_placeHolder) {
        switch (self.type) {
            case AZXSearchControllerTypePartOne: {
                _placeHolder = @"输入感兴趣的目的地";
                break;
            }
            case AZXSearchControllerTypePartTwo: {
                _placeHolder = @"搜索话题";
                break;
            }
            case AZXSearchControllerTypePartThree: {
                _placeHolder = @"请输入感兴趣的景点";
                break;
            }
        }
    }
    return _placeHolder;
}
- (AZXSearchSetNewArrayHandle)setNewArrayHandle
{
    __weak typeof(self) weakSelf = self;
    if (!_setNewArrayHandle) {
        _setNewArrayHandle = ^(NSArray *newArray){
            weakSelf.resultArray = newArray;
        };
    }
    return _setNewArrayHandle;
}
- (NSMutableArray *)hotKeywordsBtnArray
{
    if (!_hotKeywordsBtnArray) {
        _hotKeywordsBtnArray = @[].mutableCopy;
    }
    return _hotKeywordsBtnArray;
}
- (NSMutableArray *)historyKeywordsBtnArray
{
    if (!_historyKeywordsBtnArray) {
        _historyKeywordsBtnArray = @[].mutableCopy;
    }
    return _historyKeywordsBtnArray;
}
@end
