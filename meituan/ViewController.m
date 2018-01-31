  //
  //  ViewController.m
  //  meituan
  //
  //  Created by jinzelu on 15/6/12.
  //  Copyright (c) 2015年 jinzelu. All rights reserved.
  //

#import "ViewController.h"
#import "HomeViewController.h"
#import "JZOnSiteViewController.h"
#import "MineViewController.h"
#import "MoreViewController.h"
#import "JZMerchantViewController.h"
#import "WXLToolbarItem.h"

@interface ViewController ()

@property(nonatomic, strong) NSMutableArray<WXLToolbarItem *> *items;

@end

@implementation ViewController

- (void)viewDidLoad {
  
  [super viewDidLoad];
  [self setViewControllers:[self.items valueForKeyPath:@"nav"]   animated:YES];
  //改变UITabBarItem选中时字体的颜色
  NSDictionary *attrs = @{NSForegroundColorAttributeName:RGB(54, 185, 175)};
  [[UITabBarItem appearance] setTitleTextAttributes:attrs forState:UIControlStateSelected];
}

#pragma mark - lazy init

- (NSArray<WXLToolbarItem *> *)items
{
  if (!_items) {
    _items = [NSMutableArray arrayWithCapacity:5];
    
    HomeViewController *home = [[HomeViewController alloc] init];
    WXLToolbarItem *item1 = [[WXLToolbarItem alloc] initWith:home
                                                       title:@"团购"
                                                       image:@"icon_tabbar_homepage"
                                                 selectImage:@"icon_tabbar_homepage_selected"];
    [_items addObject:item1];
    
    JZOnSiteViewController *site = [[JZOnSiteViewController alloc] init];
    WXLToolbarItem *item2 = [[WXLToolbarItem alloc] initWith:site
                                                       title:@"上门"
                                                       image:@"icon_tabbar_onsite"
                                                 selectImage:@"icon_tabbar_onsite_selected"];
    [_items addObject:item2];
    
    JZMerchantViewController *merchant = [[JZMerchantViewController alloc] init];
    WXLToolbarItem *item3 = [[WXLToolbarItem alloc] initWith:merchant
                                                       title:@"商家"
                                                       image:@"icon_tabbar_merchant_normal"
                                                 selectImage:@"icon_tabbar_merchant_selected"];
    [_items addObject:item3];
    
    MineViewController *mine = [[MineViewController alloc] init];
    WXLToolbarItem *item4 = [[WXLToolbarItem alloc] initWith:mine
                                                       title:@"我的"
                                                       image:@"icon_tabbar_mine"
                                                 selectImage:@"icon_tabbar_mine_selected"];
    [_items addObject:item4];
    
    MoreViewController *more = [[MoreViewController alloc] init];
    WXLToolbarItem *item5 = [[WXLToolbarItem alloc] initWith:more
                                                       title:@"更多"
                                                       image:@"icon_tabbar_misc"
                                                 selectImage:@"icon_tabbar_misc_selected"];
    [_items addObject:item5];
  }
  return _items;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
