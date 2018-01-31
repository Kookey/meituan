  //
  //  MineViewController.m
  //  meituan
  //
  //  Created by jinzelu on 15/7/6.
  //  Copyright (c) 2015年 jinzelu. All rights reserved.
  //

#import "MineViewController.h"

@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *items;

@end

@implementation MineViewController

- (void)viewDidLoad {
  
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  [self initData];
  [self initViews];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

-(void)initData{
  NSString *menuPath = [[NSBundle mainBundle] pathForResource:@"mine_menu" ofType:@"plist"];
  self.items =[[NSArray alloc] initWithContentsOfFile:menuPath];
}

-(void)initViews{
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height) style:UITableViewStyleGrouped];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.view addSubview:self.tableView];
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  if (section == 0) {
    return 1;
  }else{
    return 8;
  }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
  if (section == 0) {
    return 75;
  }else{
    return 5;
  }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
  return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  if (indexPath.section == 0) {
    return 60;
  }else{
    return 40;
  }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
  UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_height, 75)];
  footerView.backgroundColor = RGB(239, 239, 244);
  return footerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  if (section == 0) {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 55)];
      //        headerView.backgroundColor = [UIColor greenColor];
    headerView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"bg_login"]];
      //头像
    UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 55, 55)];
    userImage.layer.masksToBounds = YES;
    userImage.layer.cornerRadius = 27;
    [userImage setImage:[UIImage imageNamed:@"icon_mine_default_portrait"]];
    [headerView addSubview:userImage];
      //用户名
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+55+5, 15, 200, 30)];
    userNameLabel.font = [UIFont systemFontOfSize:13];
    userNameLabel.text = @"波雅.汉库克";
    [headerView addSubview:userNameLabel];
      //账户余额
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake([userNameLabel mj_x], 40, 200, 30)];
    moneyLabel.font = [UIFont systemFontOfSize:13];
    moneyLabel.text = @"账户余额：0.00元";
    [headerView addSubview:moneyLabel];
    
      //
    UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width-10-24, 30, 12, 24)];
    [arrowImg setImage:[UIImage imageNamed:@"icon_mine_accountViewRightArrow"]];
    [headerView addSubview: arrowImg];
    return headerView;
  }else{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 15)];
    headerView.backgroundColor = RGB(239, 239, 244);
    return headerView;
  }
  
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *cellIndentifier = @"mineCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
  }
  if (indexPath.section == 1) {
    cell.textLabel.text = self.items[indexPath.row][@"title"];
    NSString *imgStr = self.items[indexPath.row][@"image"];
    cell.imageView.image = [UIImage imageNamed:imgStr];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
  }else{
    cell.textLabel.text = @"我的标题";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return cell;
}

@end
