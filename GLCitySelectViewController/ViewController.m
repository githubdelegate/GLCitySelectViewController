//
//  ViewController.m
//  GLSelectCity
//
//  Created by Glenn on 15/8/27.
//  Copyright (c) 2015年 Glenn. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD+Add.h"

#import "GLCitySelectViewController.h"
#import "GLGlobal.h"
#import "GLCityExampleModel.h"

@interface ViewController ()<GLCitySelectViewControllerDeleage>{
    
    NSString *_cityName;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initWelcomeLabel];
    
    [self initNavLeftButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self initNavLeftButton];
}

- (void)initNavLeftButton {
    
    if (!_cityName || [_cityName isEqualToString:@""]) {
        _cityName = @"城市";
    }
    
    UIButton *cityBtn = [[UIButton alloc] init];
    [cityBtn setTitle:_cityName forState:UIControlStateNormal];
    [cityBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cityBtn addTarget:self action:@selector(goSelectCityViewController) forControlEvents:UIControlEventTouchUpInside];
    cityBtn.frame = CGRectMake(0, 0, 44, 40);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cityBtn];
}

- (void)initWelcomeLabel {
    
    UILabel *welcomeLabel = [[UILabel alloc] init];
    welcomeLabel.text          = @"Welcome to Glenn's SelectCityViewController";
    welcomeLabel.font          = [UIFont boldSystemFontOfSize:30];
    welcomeLabel.textColor     = [UIColor blueColor];
    welcomeLabel.numberOfLines = 0;
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.frame         = self.view.bounds;
    [self.view addSubview:welcomeLabel];
    
}

- (void)goSelectCityViewController {
    
    GLCitySelectViewController *citySelectedVC = [[GLCitySelectViewController alloc] init];
    citySelectedVC.delegate = self;
    citySelectedVC.hidesBottomBarWhenPushed = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:citySelectedVC];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - UIGestureRecognizerDelegate
//城市选择控制器获取城市数据的代理方法
- (void)citySelectViewController:(GLCitySelectViewController *)citySelectViewController getDataWithCompletionHandler:(void (^)(GLCityModel *))completion{
    
    //创建城市列表数据
    NSString *path = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
    NSDictionary *city = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *hotCity = city[@"hotcity"];
    NSArray *allCity = city[@"allcity"];
    
    NSMutableArray *allCityDataArray = [NSMutableArray array];
    NSMutableArray *hotCityDataArray = [NSMutableArray array];
    
    //热门城市数据
    for (int i = 0; i < hotCity.count; i ++) {
        GLCityExampleModel *cityModel = [[GLCityExampleModel alloc] init];
        NSDictionary *cityDict = hotCity[i];
        [cityModel setValue:cityDict[@"name"] forKey:@"cityName"];
        [cityModel setValue:cityDict[@"pinyin"] forKey:@"pinyin"];
        [cityModel setValue:cityDict[@"province"] forKey:@"province"];
        [cityModel setValue:cityDict[@"centerx"] forKey:@"cityLng"];
        [cityModel setValue:cityDict[@"centery"] forKey:@"cityLat"];
        [cityModel setValue:cityDict[@"city_id"] forKey:@"cityId"];
        [hotCityDataArray addObject:cityModel];
    }
    
    //所有城市数据
    for (int i = 0; i < allCity.count; i ++) {
        GLCityExampleModel *cityModel = [[GLCityExampleModel alloc] init];
        NSDictionary *cityDict = allCity[i];
        [cityModel setValue:cityDict[@"name"] forKey:@"cityName"];
        [cityModel setValue:cityDict[@"pinyin"] forKey:@"pinyin"];
        [cityModel setValue:cityDict[@"province"] forKey:@"province"];
        [cityModel setValue:cityDict[@"centerx"] forKey:@"cityLng"];
        [cityModel setValue:cityDict[@"centery"] forKey:@"cityLat"];
        [cityModel setValue:cityDict[@"city_id"] forKey:@"cityId"];
        [allCityDataArray addObject:cityModel];
    }
    
    
    [MBProgressHUD showMessag:@"加载中..." toView:[UIApplication sharedApplication].keyWindow];

    //模拟网络请求的延时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GLCityModel *data = [[GLCityModel alloc] init];
        data.allcity = allCityDataArray;
        data.hotcity = hotCityDataArray;
        
        //调用block传入所有城市数据
        completion(data);
        
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:NO];
    });
}

//位置更新调用的代理方法
- (NSString *)locationCityDesCityOfSelectViewController:(GLCitySelectViewController *)citySelectViewController updateLocationWithLocationCity:(id)LocationCity {
    
    NSString  *cityName = [LocationCity valueForKeyPath:@"cityName"];
    
    NSString *des = @"";
    
    if ([cityName isEqualToString:@"北京"]) {//城市开通了业务
        des = @"(该城市未开通业务)";
    } else {
        des = @"";
    }
    return des;
}


//城市选择控制器点击城市的回调方法
- (BOOL)citySelectViewController:(GLCitySelectViewController *)citySelectViewController didSelectCity:(id)selectCity locationCity:(id)locationCity {
    
    _cityName = [selectCity valueForKeyPath:@"cityName"];
    
    if (![_cityName isEqualToString:@"上海"] && ![_cityName isEqualToString:@"广州"]) {//不是上海广州时可以跳转
        return YES;
    } else {//广州上海不能跳转
        [MBProgressHUD showError:@"该城市未开通" toView:[UIApplication sharedApplication].keyWindow];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:NO];
        });
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
