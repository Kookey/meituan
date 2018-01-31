//
//  JZMerDetailImageCell.h
//  meituan
//
//  Created by jinzelu on 15/7/17.
//  Copyright (c) 2015年 jinzelu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JZMerDetailImageCell : UITableViewCell

@property(strong, nonatomic) NSString *BigImgUrl;
@property(strong, nonatomic) NSString *SmallImgUrl;
@property(strong, nonatomic) NSNumber *score;
@property(strong, nonatomic) NSNumber *avgPrice;
@property(strong, nonatomic) NSString *shopName;

@end
