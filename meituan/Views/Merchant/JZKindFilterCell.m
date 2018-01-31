  //
  //  JZKindFilterCell.m
  //  meituan
  //
  //  Created by jinzelu on 15/7/13.
  //  Copyright (c) 2015年 jinzelu. All rights reserved.
  //

#import "JZKindFilterCell.h"
#import "UIView+MJExtension.h"

@interface JZKindFilterCell ()
{
  UIImageView *_imageView;
  UILabel *_nameLabel;
  UIButton *_numberBtn;
}

@end

@implementation JZKindFilterCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withFrame:(CGRect)frame{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.frame = frame;
      //
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_nameLabel];
    _numberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _numberBtn.frame = CGRectMake([self mj_w]-85, 12, 80, 15);
    _numberBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    [_numberBtn setBackgroundImage:[UIImage imageNamed:@"film"] forState:UIControlStateNormal];
    [_numberBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:_numberBtn];
    
      //下划线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, [self mj_h] - 0.5, [self mj_w], 0.5)];
    lineView.backgroundColor = RGB(192, 192, 192);
    [self.contentView addSubview:lineView];
  }
  return self;
}


-(void)setGroupM:(JZMerCateGroupModel *)groupM{
  _groupM = groupM;
  _nameLabel.text = groupM.name;
  NSString *titleFormat;
  if (!groupM.list) {
    titleFormat = @"%@";
  }else{
    titleFormat = @"%@>";
  }
  NSString *title = [NSString stringWithFormat:titleFormat,groupM.count];
  [_numberBtn setTitle:title forState:UIControlStateNormal];
  CGSize textSize = [title boundingRectWithSize:CGSizeMake(80, 15) withFont:11];
  _numberBtn.frame = CGRectMake(self.frame.size.width-10-textSize.width-10, 12, textSize.width+10, 15);
  
}


@end
