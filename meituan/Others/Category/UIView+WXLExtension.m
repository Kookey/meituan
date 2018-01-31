//
//  UIView+WXLExtension.m
//  meituan
//
//  Created by lemo-wu on 2018/1/31.
//  Copyright © 2018年 jinzelu. All rights reserved.
//

#import "UIView+WXLExtension.h"
#import "UIView+MJExtension.h"

@implementation UIView (WXLExtension)

-(CGFloat) wxl_r
{
  return [self mj_x] + [self mj_w];
}

- (CGFloat) wxl_b
{
  return [self mj_y] + [self mj_h];
}

@end
