  //
  //  JZMerchantViewController.m
  //  meituan
  //
  //  Created by jinzelu on 15/7/9.
  //  Copyright (c) 2015年 jinzelu. All rights reserved.
  //

#import "JZMerchantViewController.h"
#import "NetworkSingleton.h"
#import "AppDelegate.h"
#import "MJExtension.h"
#import "JZMerchantModel.h"
#import "JZMerchantCell.h"
#import "MJRefresh.h"
#import "UIView+MJExtension.h"
#import "UITableView+WXLTableViewRefresh.h"

#import "JZMerchantFilterView.h"
#import "JZMerchantDetailViewController.h"


@interface JZMerchantViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,JZMerchantFilterDelegate>

@property(strong, nonatomic) NSMutableArray *merchants;
@property(strong, nonatomic) NSString *locationInfoStr;
@property(assign, nonatomic) NSInteger kindID;
@property(assign, nonatomic) NSInteger offset;
@property(strong, nonatomic) UIView *maskView;
@property(strong, nonatomic) JZMerchantFilterView *groupView;

@end

@implementation JZMerchantViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.navigationController.navigationBarHidden = YES;
  self.view.backgroundColor = [UIColor whiteColor];
  
  [self initData];
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  [self setNav];
  [self initViews];
  [self initMaskView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData{
  _merchants = [[NSMutableArray alloc] init];
  NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
  _locationInfoStr = [userD objectForKey:@"location"];
  
  self.offset = 0;
  self.kindID = -1;//默认-1
}

-(void)setNav{
  UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, NAVIGATIONBAR_HEIGHT)];
  backView.backgroundColor = RGB(250, 250, 250);
  [self.view addSubview:backView];
    //下划线
  UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5, screen_width, 0.5)];
  lineView.backgroundColor = RGB(192, 192, 192);
  [backView addSubview:lineView];
  
    //地图
  UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  mapBtn.frame = CGRectMake(10, 30, 23, 23);
  [mapBtn setImage:[UIImage imageNamed:@"icon_map"] forState:UIControlStateNormal];
  [mapBtn addTarget:self action:@selector(onMapAction:) forControlEvents:UIControlEventTouchUpInside];
  [backView addSubview:mapBtn];
    //搜索
  UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  searchBtn.frame = CGRectMake(screen_width-33, 30, 23, 23);
  [searchBtn setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
  [searchBtn addTarget:self action:@selector(onSearchAction:) forControlEvents:UIControlEventTouchUpInside];
  [backView addSubview:searchBtn];
  
    //segment
  UIButton *segBtn1 = [self buttonWithTitle:@"全部商家" atIndex:0];
  [backView addSubview:segBtn1];
  
  UIButton *segBtn2 = [self buttonWithTitle:@"优惠商家" atIndex:1];
  [backView addSubview:segBtn2];
    //默认选中第一个
  [self onSelectedAction:segBtn1];
}

- (UIButton *)buttonWithTitle:(NSString *)title atIndex:(NSInteger)index
{
  CGFloat width = 80;
  NSInteger tag = 20;
  UIButton *segBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  segBtn.frame = CGRectMake(screen_width/2-width + index * width, 30, width, 30);
  [segBtn setTitle:title forState:UIControlStateNormal];
  [segBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
  [segBtn setTitleColor:navigationBarColor forState:UIControlStateNormal];
  [segBtn setBackgroundColor:navigationBarColor];
  segBtn.titleLabel.font = [UIFont systemFontOfSize:15];
  segBtn.tag = tag + index;
  segBtn.layer.borderWidth = 1;
  segBtn.layer.borderColor = [navigationBarColor CGColor];
  [segBtn addTarget:self action:@selector(onSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
  return segBtn;
}

-(void)initViews{
    //筛选
  static CGFloat filterHeight = 40;
  UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATIONBAR_HEIGHT, screen_width, filterHeight)];
  filterView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:filterView];
  
  NSArray *filterName = @[@"全部",@"全部",@"智能排序"];
    //筛选
  for (int i = 0; i < filterName.count; i++) {
      //文字
    UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    filterBtn.frame = CGRectMake(i*screen_width/3, 0, screen_width/3-15, filterHeight);
    filterBtn.tag = 100+i;
    filterBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [filterBtn setTitle:filterName[i] forState:UIControlStateNormal];
    [filterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [filterBtn setTitleColor:navigationBarColor forState:UIControlStateSelected];
    [filterBtn addTarget:self action:@selector(onClickFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
    [filterView addSubview:filterBtn];
    
      //三角
    UIButton *sanjiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sanjiaoBtn.frame = CGRectMake((i+1)*screen_width/3-15, 16, 7.5, 7);
    sanjiaoBtn.tag = 120+i;
    [sanjiaoBtn setImage:[UIImage imageNamed:@"icon_arrow_dropdown_normal"] forState:UIControlStateNormal];
    [sanjiaoBtn setImage:[UIImage imageNamed:@"icon_arrow_dropdown_selected"] forState:UIControlStateSelected];
    [filterView addSubview:sanjiaoBtn];
  }
    //下划线
  UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, filterHeight - 0.5, screen_width, 0.5)];
  lineView.backgroundColor = RGB(192, 192, 192);
  [filterView addSubview:lineView];
  
    //tableview
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATIONBAR_HEIGHT+filterHeight, screen_width, screen_height-64-40-49) style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.view addSubview:self.tableView];
  [self setUpTableView];
}

  //遮罩页
-(void)initMaskView{
    //64为nav高度, 40为过滤查询View的高度, 49为底部tabbar的高度
  self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+40, screen_width, screen_height-64-40-49)];
  self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
  [self.view addSubview:self.maskView];
  self.maskView.hidden = YES;
  
    //添加手势
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickTapMask:)];
  tap.delegate = self;
  [_maskView addGestureRecognizer:tap];
  
  self.groupView = [[JZMerchantFilterView alloc] initWithFrame:CGRectMake(0, 0, screen_width, [self.maskView mj_h]-90)];
  self.groupView.delegate = self;
  [self.maskView addSubview:self.groupView];
}

-(void)setUpTableView{
    //添加下拉的动画图片
    //设置下拉刷新回调
  [self.tableView wxl_addGifHeaderWithRefreshingTarget:self refreshingAction:@selector(getFirstPageData)];
  
    //马上进入刷新状态
  [self.tableView.gifHeader beginRefreshing];
  
  
    //上拉加载更多
  [self.tableView wxl_addGifFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}


#pragma mark - 响应事件
-(void)onMapAction:(UIButton *)sender{
  NSLog(@"地图");
}

-(void)onSearchAction:(UIButton *)sender{
  NSLog(@"搜索");
}

-(void)onSelectedAction:(UIButton *)sender{
  NSInteger tag = sender.tag;
  UIButton *segBtn1 = (UIButton *)[self.view viewWithTag:20];
  UIButton *segBtn2 = (UIButton *)[self.view viewWithTag:21];
  [segBtn1 setBackgroundColor:[UIColor whiteColor]];
  [segBtn2 setBackgroundColor:[UIColor whiteColor]];
  segBtn1.selected = NO;
  segBtn2.selected = NO;
  sender.selected = YES;
  [sender setBackgroundColor:navigationBarColor];
  if (tag == 20) {
    NSLog(@"20");
  }else{
    NSLog(@"21");
  }
}

-(void)onClickFilterBtn:(UIButton *)sender{
  for (int i = 0; i < 3; i++) {
    UIButton *btn = (UIButton *)[self.view viewWithTag:100+i];
    UIButton *sanjiaoBtn = (UIButton *)[self.view viewWithTag:120+i];
    btn.selected = NO;
    sanjiaoBtn.selected = NO;
  }
  sender.selected = YES;
  UIButton *sjBtn = (UIButton *)[self.view viewWithTag:sender.tag+20];
  sjBtn.selected = YES;
  _maskView.hidden = NO;
}

-(void)onClickTapMask:(UITapGestureRecognizer *)sender{
  _maskView.hidden = YES;
}

#pragma mark - 请求数据

  //获取当前位置信息
-(void)onRefreshLocation:(UIButton *)sender{
  [self getPresentLocation];
}

-(void)getFirstPageData{
  _offset = 0;
  [self refreshData];
}

-(void)refreshData{
  [self getMerchantList];
}

-(void)loadMoreData{
  self.offset = self.offset + 20;
  [self refreshData];
}


  //获取商家列表
-(void)getMerchantList{
  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSString *str = @"%2C";
  
  NSString *hostStr = @"http://api.meituan.com/group/v1/poi/select/cate/";
  NSString *paramsStr = @"?__skck=40aaaf01c2fc4801b9c059efcd7aa146&__skcy=WOdaAXJTFxIjDdjmt1z%2FJRzB6Y0%3D&__skno=91D0095F-156B-4392-902A-A20975EB9696&__skts=1436408836.151516&__skua=bd6b6e8eadfad15571a15c3b9ef9199a&__vhost=api.mobile.meituan.com&areaId=-1&ci=1&cityId=1&client=iphone&coupon=all&limit=20&movieBundleVersion=100&msid=48E2B810-805D-4821-9CDD-D5C9E01BC98A2015-07-09-09-42570&mypos=";
  
  NSString *str1 = [NSString stringWithFormat:@"%@%ld%@",hostStr,(long)self.kindID,paramsStr];
  
  NSString *str2 = @"&sort=smart&userid=10086&utm_campaign=AgroupBgroupD100Fa20141120nanning__m1__leftflow___ab_pindaochangsha__a__leftflow___ab_gxtest__gd__leftflow___ab_gxhceshi__nostrategy__leftflow___ab_i550poi_ktv__d__j___ab_chunceshishuju__a__a___ab_gxh_82__nostrategy__leftflow___ab_i_group_5_3_poidetaildeallist__a__b___b1junglehomepagecatesort__b__leftflow___ab_gxhceshi0202__b__a___ab_pindaoshenyang__a__leftflow___ab_pindaoquxincelue0630__b__b1___ab_i_group_5_6_searchkuang__a__leftflow___i_group_5_2_deallist_poitype__d__d___ab_i550poi_xxyl__b__leftflow___ab_b_food_57_purepoilist_extinfo__a__a___ab_waimaiwending__a__a___ab_waimaizhanshi__b__b1___ab_i550poi_lr__d__leftflow___ab_i_group_5_5_onsite__b__b___ab_xinkeceshi__b__leftflowGmerchant&utm_content=4B8C0B46F5B0527D55EA292904FD7E12E48FB7BEA8DF50BFE7828AF7F20BB08D&utm_medium=iphone&utm_source=AppStore&utm_term=5.7&uuid=4B8C0B46F5B0527D55EA292904FD7E12E48FB7BEA8DF50BFE7828AF7F20BB08D&version_name=5.7";
  
  
  NSString *urlStr = [NSString stringWithFormat:@"%@%f%@%f&offset=%zd%@",str1, delegate.latitude, str, delegate.longitude, self.offset,str2];
  
  __weak typeof(self) weakself = self;
  [[NetworkSingleton sharedManager] getMerchantListResult:nil url:urlStr successBlock:^(id responseBody){
    NSLog(@"获取商家列表成功");
    NSMutableArray *dataArray = [responseBody objectForKey:@"data"];
    NSLog(@"%ld",(unsigned long)dataArray.count);
    NSLog(@"offset:%ld",(long)self.offset);
    if (self.offset == 0) {
      [self.merchants removeAllObjects];
    }
    if (dataArray.count>0) {
      NSArray *merchants = [JZMerchantModel mj_objectArrayWithKeyValuesArray:dataArray];
      [self.merchants addObjectsFromArray:merchants];
    }
    [weakself.tableView reloadData];
    
    if (self.offset == 0 && dataArray.count != 0) {
      [weakself.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [weakself.tableView.header endRefreshing];
    [weakself.tableView.footer endRefreshing];
    
  } failureBlock:^(NSString *error){
    [weakself.tableView.header endRefreshing];
    [weakself.tableView.footer endRefreshing];
  }];
  
}

  //获取当前位置
-(void)getPresentLocation{
  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSString *urlStr = @"http://api.meituan.com/group/v1/city/latlng/%f,%f?__skck=40aaaf01c2fc4801b9c059efcd7aa146&__skcy=dhdVkMoRTQge4RJQFlm2iIF2e5s%3D&__skno=9B646232-F7BF-4642-B9B0-9A6ED68003D2&__skts=1436408843.060582&__skua=bd6b6e8eadfad15571a15c3b9ef9199a&__vhost=api.mobile.meituan.com&ci=1&client=iphone&movieBundleVersion=100&msid=48E2B810-805D-4821-9CDD-D5C9E01BC98A2015-07-09-09-42570&tag=1&userid=10086&utm_campaign=AgroupBgroupD100Fa20141120nanning__m1__leftflow___ab_pindaochangsha__a__leftflow___ab_gxtest__gd__leftflow___ab_gxhceshi__nostrategy__leftflow___ab_i550poi_ktv__d__j___ab_chunceshishuju__a__a___ab_gxh_82__nostrategy__leftflow___ab_i_group_5_3_poidetaildeallist__a__b___b1junglehomepagecatesort__b__leftflow___ab_gxhceshi0202__b__a___ab_pindaoshenyang__a__leftflow___ab_pindaoquxincelue0630__b__b1___ab_i_group_5_6_searchkuang__a__leftflow___i_group_5_2_deallist_poitype__d__d___ab_i550poi_xxyl__b__leftflow___ab_b_food_57_purepoilist_extinfo__a__a___ab_waimaiwending__a__a___ab_waimaizhanshi__b__b1___ab_i550poi_lr__d__leftflow___ab_i_group_5_5_onsite__b__b___ab_xinkeceshi__b__leftflowGmerchant&utm_content=4B8C0B46F5B0527D55EA292904FD7E12E48FB7BEA8DF50BFE7828AF7F20BB08D&utm_medium=iphone&utm_source=AppStore&utm_term=5.7&uuid=4B8C0B46F5B0527D55EA292904FD7E12E48FB7BEA8DF50BFE7828AF7F20BB08D&version_name=5.7";
  urlStr = [NSString stringWithFormat:urlStr, delegate.latitude, delegate.longitude];
  _locationInfoStr = @"正在定位...";
  [self.tableView reloadData];
  __weak typeof(self) weakself = self;
  [[NetworkSingleton sharedManager] getPresentLocationResult:nil url:urlStr successBlock:^(id responseBody){
    NSLog(@"获取当前位置信息成功");
    NSDictionary *dataDic = [responseBody objectForKey:@"data"];
    _locationInfoStr = [dataDic objectForKey:@"detail"];
    
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    [userD setObject:_locationInfoStr forKey:@"location"];
    
    [weakself.tableView reloadData];
  } failureBlock:^(NSString *error){
    NSLog(@"获取当前位置信息失败:%@",error);
  }];
}



#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return self.merchants.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  return 92;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
  return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 30)];
  headerView.backgroundColor = RGB(240, 239, 237);
  
  UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, screen_width-10-30, 30)];
  locationLabel.font = [UIFont systemFontOfSize:13];
  locationLabel.text = [NSString stringWithFormat:@"当前位置：%@",_locationInfoStr];
  locationLabel.textColor = [UIColor lightGrayColor];
  [headerView addSubview:locationLabel];
  
  UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  refreshBtn.frame = CGRectMake(screen_width-30, 5, 20, 20);
  [refreshBtn setImage:[UIImage imageNamed:@"icon_dellist_locate_refresh"] forState:UIControlStateNormal];
  [refreshBtn addTarget:self action:@selector(onRefreshLocation:) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:refreshBtn];
  return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *cellIndentifier = @"merchantCell";
  JZMerchantCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
  if (cell == nil) {
    cell = [[JZMerchantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
  }
  JZMerchantModel *jzMerM = self.merchants[indexPath.row];
  cell.jzMerM = jzMerM;
  return cell;
}



#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  JZMerchantModel *jzMerM = self.merchants[indexPath.row];
  NSLog(@"poiid:%@",jzMerM.poiid);
  
  JZMerchantDetailViewController *jzMerchantDVC = [[JZMerchantDetailViewController alloc] init];
  jzMerchantDVC.poiid = jzMerM.poiid;
  [self.navigationController pushViewController:jzMerchantDVC animated:YES];
  
}





#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
  if ([touch.view isKindOfClass:[UITableView class]]) {
    return NO;
  }
  if ([touch.view.superview isKindOfClass:[UITableView class]]) {
    return NO;
  }
  if ([touch.view.superview.superview isKindOfClass:[UITableView class]]) {
    return NO;
  }
  if ([touch.view.superview.superview.superview isKindOfClass:[UITableView class]]) {
    return NO;
  }
  return YES;
}



#pragma mark - JZMerchantFilterDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withId:(NSNumber *)ID withName:(NSString *)name{
  NSLog(@"ID:%@  name:%@",ID,name);
  self.kindID = [ID integerValue];
  
  _maskView.hidden = YES;
  [self getFirstPageData];
}

  //动画-由大变小
-(void)zoomOut:(UIView *)view andAnimationDuration:(float)duration andWait:(BOOL)wait{
  __block BOOL done = wait;
  view.transform = CGAffineTransformIdentity;
  [UIView animateWithDuration:duration animations:^{
    view.transform = CGAffineTransformMakeScale(0, 0);
  } completion:^(BOOL finished){
    done = YES;
  }];
  
  while (done == NO) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
  }
}

  //动画-由小变大
-(void)zoomIn:(UIView *)view andAnimationDuration:(float)duration andWait:(BOOL)wait{
  __block BOOL done = wait;
    //    view.transform = CGAffineTransformIdentity;
  view.transform = CGAffineTransformMakeScale(0, 0);
  [UIView animateWithDuration:duration animations:^{
      //        view.transform = CGAffineTransformMakeScale(0, 0);
    view.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished){
    done = YES;
  }];
  
  while (done == NO) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
  }
}













/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
