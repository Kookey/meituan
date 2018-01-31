//
//  UITableView+WXLTableViewRefresh.h
//  meituan
//
//  Created by lemo-wu on 2018/1/30.
//  Copyright © 2018年 jinzelu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (WXLTableViewRefresh)


/**
 添加下拉刷新头

 @param target
 @param action
 */
- (void)wxl_addGifHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

/**
 添加加载更多尾

 @param target
 @param action
 */
-(void) wxl_addGifFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

@end
