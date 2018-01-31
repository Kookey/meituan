//
//  UITableView+WXLTableViewRefresh.m
//  meituan
//
//  Created by lemo-wu on 2018/1/30.
//  Copyright © 2018年 jinzelu. All rights reserved.
//

#import "UITableView+WXLTableViewRefresh.h"
#import "MJRefresh.h"

@implementation UITableView (WXLTableViewRefresh)

- (void)wxl_addGifHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
  [self addGifHeaderWithRefreshingTarget:target refreshingAction:action];
  
    //设置普通状态的动画图片
  NSMutableArray *idleImages = [NSMutableArray array];
  for (NSUInteger i = 1; i<=60; ++i) {
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__000%zd",i]];
    [idleImages addObject:image];
  }
  [self.gifHeader setImages:idleImages forState:MJRefreshHeaderStateIdle];
  
    //设置即将刷新状态的动画图片
  
  [self.gifHeader setImages:[self p_refreshingImages] forState:MJRefreshHeaderStatePulling];
  
    //设置正在刷新是的动画图片
  [self.gifHeader setImages:[self p_refreshingImages] forState:MJRefreshHeaderStateRefreshing];
}

-(void) wxl_addGifFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
  [self addGifFooterWithRefreshingTarget:target refreshingAction:action];
  self.gifFooter.refreshingImages = [self p_refreshingImages];
}

#pragma mark - private method
- (NSArray *)p_refreshingImages
{
  NSMutableArray *refreshingImages = [NSMutableArray array];
  for (NSInteger i = 1; i<=3; i++) {
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_0%zd",i]];
    [refreshingImages addObject:image];
  }
  return refreshingImages;
}

@end
