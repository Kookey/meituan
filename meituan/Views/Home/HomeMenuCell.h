//
//  HomeMenuCell.h
//  meituan
//
//  Created by jinzelu on 15/6/30.
//  Copyright (c) 2015年 jinzelu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZMTBtnView.h"

extern NSInteger const HomeMenuCellMenuHeight;

@interface HomeMenuCell : UITableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier menuArray:(NSArray *)menus;

@end
