//
//  CustomAnnotationView.h
//  meituan
//
//  Created by jinzelu on 15/7/15.
//  Copyright (c) 2015年 jinzelu. All rights reserved.
//

#import "BMKAnnotationView.h"
#import "CustomCalloutView.h"
#import "JZMAAroundAnnotation.h"

@interface CustomAnnotationView : BMKAnnotationView

@property(nonatomic, strong) CustomCalloutView *calloutView;


@end
