//
//  CustomPaopaoView.h
//  meituan
//
//  Created by lemo-wu on 2018/1/29.
//  Copyright © 2018年 jinzelu. All rights reserved.
//

#import "BMKAnnotation.h"
@interface CustomPaopaoView: UIView

@property(strong, nonatomic) NSString *title;
@property(strong, nonatomic) NSString *subtitle;

@property(strong, nonatomic) UIImageView *imageView;
@property(strong, nonatomic) id <BMKAnnotation> annotation;

@end
