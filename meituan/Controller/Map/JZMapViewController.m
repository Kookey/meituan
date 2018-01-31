  //
  //  JZMapViewControlle.m
  //  meituan
  //
  //  Created by jinzelu on 15/7/14.
  //  Copyright (c) 2015年 jinzelu. All rights reserved.
  //

#import "JZMapViewController.h"
  //基础
#import "BMKBaseComponent.h"
  //地图View
#import "BMKMapView.h"
  //检索
#import "BMKSearchComponent.h"
#import "BMKLocationService.h"

#import "CustomAnnotationView.h"
#import "CustomPaopaoView.h"

#import "NetworkSingleton.h"
#import "JZMAAroundAnnotation.h"
#import "JZMAAroundModel.h"
#import "MJExtension.h"

#define kDefaultCalloutViewMargin       -8

@interface JZMapViewController ()<BMKMapViewDelegate, BMKPoiSearchDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

@property(strong, nonatomic) UIButton *locationBtn;
@property(strong, nonatomic) CLLocation *currentLocation;

  //百度地图相关
@property(strong, nonatomic) BMKMapView *mapView;
@property(strong, nonatomic) BMKPoiSearch *search;
@property(strong, nonatomic) BMKGeoCodeSearch *geoCodeSearch;
@property(strong, nonatomic) BMKLocationService *locService;

@property(copy, nonatomic) NSString *currentCity;

@property(strong, nonatomic) NSMutableArray *annotations;

@end

@implementation JZMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.hidesBottomBarWhenPushed = YES;
  }
  return self;
}

- (void)viewDidLoad {
  
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  [self.locService startUserLocationService];
  [self.view addSubview:self.mapView];
  
  [self setNav];
  [self initControls];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
  
  [self.mapView viewWillAppear];
  self.mapView.delegate = self;
  self.geoCodeSearch.delegate = self;
  self.search.delegate = self;
  self.locService.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
  
  [self.mapView viewWillDisappear];
  self.search.delegate = nil;
  self.geoCodeSearch.delegate = nil;
  self.mapView.delegate = nil;
  self.locService.delegate = self;
}

- (void)dealloc
{
  if (self.mapView) {
    self.mapView = nil;
  }
}


-(void)setNav{
  
  UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  backBtn.frame = CGRectMake(15, 20, 30, 30);
  [backBtn addTarget:self action:@selector(onBackBtn:) forControlEvents:UIControlEventTouchUpInside];
  [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
  [self.view addSubview:backBtn];
}

-(void)initControls{
  [self.mapView addSubview:self.locationBtn];
}

#pragma mark - lazy init

- (BMKLocationService *)locService
{
  if (!_locService) {
    _locService = [[BMKLocationService alloc]init];
  }
  return _locService;
}

- (UIButton *)locationBtn
{
  if (!_locationBtn) {
    _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _locationBtn.frame = CGRectMake(20, CGRectGetHeight(_mapView.bounds)-80, 40, 40);
    _locationBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;//
    _locationBtn.backgroundColor = [UIColor whiteColor];
    _locationBtn.layer.cornerRadius = 5;
    [_locationBtn setImage:[UIImage imageNamed:@"location_no"] forState:UIControlStateNormal];
    [_locationBtn addTarget:self action:@selector(locateAction) forControlEvents:UIControlEventTouchUpInside];
  }
  return _locationBtn;
}

- (BMKMapView *)mapView
{
  if (!_mapView) {
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.showMapScaleBar = YES;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    CGFloat offsetY = STATUS_BAR_HEIGHT + 20;
    _mapView.compassPosition = CGPointMake(self.view.bounds.size.width - _mapView.compassSize.width*2, offsetY);
    _mapView.mapScaleBarPosition = CGPointMake(_mapView.mapScaleBarPosition.x, offsetY);
  }
  return _mapView;
}

- (BMKPoiSearch *)search
{
  if (!_search) {
    _search = [[BMKPoiSearch alloc] init];
  }
  return _search;
}

- (BMKGeoCodeSearch *)geoCodeSearch
{
  if (!_geoCodeSearch) {
    _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
  }
  return _geoCodeSearch;
}

- (NSMutableArray *)annotations
{
  if (!_annotations) {
    _annotations = [NSMutableArray array];
  }
  return _annotations;
}

  //默认显示的是北京
-(void)updateUI{
  NSLog(@"个数:%lu",self.annotations.count);
  [self.mapView addAnnotations:self.annotations];
}



  //相应事件
-(void)onBackBtn:(UIButton *)sender{
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)locateAction{
  if (self.mapView.userTrackingMode != BMKUserTrackingModeFollow) {
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
  }
  self.mapView.centerCoordinate = self.currentLocation.coordinate;
  [self searchAction];
}





  //逆地理编码
  //发起搜索请求
-(void)reGeoAction{
  if (self.currentLocation) {
      //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude};
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.geoCodeSearch reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
      {
      NSLog(@"反geo检索发送成功");
      }
    else
      {
      NSLog(@"反geo检索发送失败");
      }
  }
}

  //poi 检索
-(void)searchAction{
  if (self.currentLocation == nil || self.search == nil) {
    NSLog(@"search failed");
    return;
  }
    //请求参数类BMKCitySearchOption
  BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
  citySearchOption.city= self.currentCity;
  citySearchOption.keyword = @"餐饮";
    //发起城市内POI检索
  BOOL flag = [self.search poiSearchInCity:citySearchOption];
  if(flag) {
    NSLog(@"城市内检索发送成功");
  }
  else {
    NSLog(@"城市内检索发送失败");
  }

}







#pragma mark - BMKLocationServiceDelegate

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
  self.currentLocation = [userLocation.location copy];
  [self reGeoAction];
  NSLog(@"currentLocaiton = %@", self.currentLocation);
  [self.mapView updateLocationData:userLocation];
}


#pragma mark - BMKMapViewDelegate
  //替换定位图标
- (void)mapStatusDidChanged:(BMKMapView *)mapView{
  BMKMapStatus *status = [self.mapView getMapStatus];
  NSLog(@"latitude = %f, longitude = %f",status.targetGeoPt.latitude,status.targetGeoPt.longitude);
  NSString *image;
  NSString *geoLat = [NSString stringWithFormat:@"%0.6f",status.targetGeoPt.latitude];
  NSString *geoLong = [NSString stringWithFormat:@"%0.6f",status.targetGeoPt.longitude];
  NSString *currLat = [NSString stringWithFormat:@"%0.6f",self.currentLocation.coordinate.latitude];
  NSString *currLong = [NSString stringWithFormat:@"%0.6f",self.currentLocation.coordinate.longitude];
  if ([geoLat isEqualToString:currLat] && [geoLong isEqualToString:currLong]) {
    image = @"location_yes";
  }else{
    image = @"location_no";
  }
  [self.locationBtn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
}

/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
  [self doTap];
}


  //点击大头针时
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    // 调整自定义callout的位置，使其可以完全显示
  if ([view isKindOfClass:[CustomAnnotationView class]]) {
    CustomAnnotationView *cusView = (CustomAnnotationView *)view;
    CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:_mapView];
    
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin));
    
    if (!CGRectContainsRect(_mapView.frame, frame))
      {
      CGSize offset = [self offsetToContainRect:frame inRect:_mapView.frame];
      
      CGPoint theCenter = _mapView.center;
      theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
      
      CLLocationCoordinate2D coordinate = [_mapView convertPoint:theCenter toCoordinateFromView:_mapView];
      
      [self.mapView setCenterCoordinate:coordinate animated:YES];
      }
    
  }
  
}

  //根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    static NSString *reuseIndetifier = @"annotationReuseIndetifier";
    BMKAnnotationView *annotationView = (BMKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
    if (!annotationView) {
      annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
      
    }
  CustomPaopaoView *view =  [[CustomPaopaoView alloc] init];
  view.annotation = annotation;
  BMKActionPaopaoView *paopap = [[BMKActionPaopaoView alloc] initWithCustomView:view];
  annotationView.paopaoView = paopap;
  paopap.userInteractionEnabled = YES;
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap)];
  tap.numberOfTapsRequired = 1;
  tap.numberOfTouchesRequired = 1;
    annotationView.annotation = annotation;
//    annotationView.canShowCallout = NO;
    annotationView.image = [UIImage imageNamed:@"icon_map_cateid_1"];
      // 设置中⼼心点偏移,使得标注底部中间点成为经纬度对应点
      //        annotationView.centerOffset = CGPointMake(0, -18);
    return annotationView;
}


#pragma mark - BMKGeoCodeSearchDelegate
//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
  if (error == BMK_SEARCH_NO_ERROR) {
    NSString *title = result.addressDetail.city;
    if (!title || title.length == 0) {
      title = result.addressDetail.province;
    }
    self.currentCity = title;
    [self searchAction];
  }
  else {
    NSLog(@"抱歉，未找到结果");
  }
}


#pragma mark - BMKPoiSearchDelegate
  //地址搜索回调
  //实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
  if (error == BMK_SEARCH_NO_ERROR) {
      //清空
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    NSArray<BMKPoiInfo *> *poiInfos = poiResultList.poiInfoList;
    [poiInfos enumerateObjectsUsingBlock:^(BMKPoiInfo * _Nonnull poi, NSUInteger idx, BOOL * _Nonnull stop) {
      BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
      annotation.title = poi.name;
      annotation.subtitle = poi.address;
      annotation.coordinate = poi.pt;
      [self.annotations addObject:annotation];
      BMKPoiDetailSearchOption* option = [[BMKPoiDetailSearchOption alloc] init];
      option.poiUid = poi.uid;//POI搜索结果中获取的uid
      [self.search poiDetailSearch:option];
    }];
    [self.mapView addAnnotations:self.annotations];
  }
  else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
      //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
      // result.cityList;
    NSLog(@"起始点有歧义");
  } else {
    NSLog(@"抱歉，未找到结果");
  }
}

- (void)onGetPoiDetailResult:(BMKPoiSearch *)searcher result:(BMKPoiDetailResult *)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode
{
  NSLog(@"%@",poiDetailResult.detailUrl);
}

#pragma mark - callback
- (void)doTap
{
  NSLog(@"点击");
}

#pragma mark - Helpers

- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{
  CGFloat nudgeRight = fmaxf(0, CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect)));
  CGFloat nudgeLeft = fminf(0, CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect)));
  CGFloat nudgeTop = fmaxf(0, CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect)));
  CGFloat nudgeBottom = fminf(0, CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect)));
  return CGSizeMake(nudgeLeft ?: nudgeRight, nudgeTop ?: nudgeBottom);
}

@end
