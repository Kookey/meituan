//
//  WXLToolbarItem.h
//  meituan
//
//  Created by lemo-wu on 2018/1/22.
//  Copyright © 2018年 jinzelu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXLToolbarItem : NSObject

@property(strong, nonatomic) UINavigationController *nav;

- (instancetype)initWith:(UIViewController *)nav title:(NSString *) title image:(NSString *)image selectImage:(NSString *)selectImage;

@end
