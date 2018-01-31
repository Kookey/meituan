  //
  //  HomeMenuCell.m
  //  meituan
  //
  //  Created by jinzelu on 15/6/30.
  //  Copyright (c) 2015年 jinzelu. All rights reserved.
  //

#import "HomeMenuCell.h"

static NSInteger const kNumRow = 2;
static NSInteger const kNumCol = 4;

NSInteger const HomeMenuCellMenuHeight = 180;

@interface HomeMenuCell ()<UIScrollViewDelegate>
{
  UIPageControl *_pageControl;
}

@end

@implementation HomeMenuCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier menuArray:(NSArray *)menus{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 180)];
    
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    NSInteger numIcon = kNumCol * kNumRow;
    NSInteger count = menus.count;
    NSInteger pageNum = ceill(count * 1.0 / numIcon);
    scrollView.contentSize = CGSizeMake(pageNum*screen_width, 180);
    for (int i =0; i<pageNum; i++) {
      UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(i * screen_width, 0, screen_width, 160)];
      NSInteger max = (i+1) * numIcon >= count ? count : (i+1) * numIcon;
      NSInteger start = 0;
      for (NSInteger j = i * numIcon; j< max ; j++) {
        NSInteger column = start % kNumCol;
        NSInteger row = start / kNumCol;
        CGRect frame = CGRectMake(column*screen_width/4, row * 80, screen_width/4, 80);
        NSString *title = [menus[j] objectForKey:@"title"];
        NSString *imageStr = [menus[j] objectForKey:@"image"];
        JZMTBtnView *btnView = [[JZMTBtnView alloc] initWithFrame:frame title:title imageStr:imageStr];
        btnView.tag = 1000+j;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapBtnView:)];
        [btnView addGestureRecognizer:tap];
        [backView addSubview:btnView];
        start ++;
      }
      [scrollView addSubview:backView];
    }
    [self addSubview:scrollView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 160, self.bounds.size.width, 20)];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = pageNum;
    [self addSubview:_pageControl];
    _pageControl.currentPageIndicatorTintColor = navigationBarColor;
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.hidesForSinglePage = YES;
    _pageControl.userInteractionEnabled = NO;
    
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
    // Configure the view for the selected state
}

-(void)OnTapBtnView:(UITapGestureRecognizer *)sender{
  NSLog(@"tag:%ld",sender.view.tag);
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  CGFloat scrollViewW = scrollView.frame.size.width;
  CGFloat x = scrollView.contentOffset.x;
  int page = (x + scrollViewW/2)/scrollViewW;
  _pageControl.currentPage = page;
}


@end
