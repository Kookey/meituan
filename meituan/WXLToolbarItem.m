//
//  WXLToolbarItem.m
//  meituan
//
//  Created by lemo-wu on 2018/1/22.
//  Copyright © 2018年 jinzelu. All rights reserved.
//

#import "WXLToolbarItem.h"

@interface WXLToolbarItem ()

@property(copy, nonatomic) NSString *title;
@property(strong, readonly, nonatomic) UIImage *selectedImage;
@property(strong, readonly, nonatomic) UIImage *image;

@end

@implementation WXLToolbarItem

- (instancetype)initWith:(UIViewController *)ctr title:(NSString *) title image:(NSString *)image selectImage:(NSString *)selectImage
{
  self = [super init];
  if (self) {
    _title = title;
    _image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _selectedImage = [[UIImage imageNamed:selectImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    ctr.title = title;
    _nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    _nav.tabBarItem =  [[UITabBarItem alloc] initWithTitle:title image:_image selectedImage:_selectedImage];
    
  }
  return self;
}



@end
