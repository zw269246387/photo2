//
//  ClipViewController.m
//  UIImageView
//
//  Created by zheng on 2018/8/27.
//  Copyright © 2018年 zheng. All rights reserved.
//

#import "ClipViewController.h"
#import <Masonry.h>

//获取屏幕 宽度、高度
#define MSScreenW ([UIScreen mainScreen].bounds.size.width)
#define MSScreenH ([UIScreen mainScreen].bounds.size.height)
#define MSScreenBounds [UIScreen mainScreen].bounds

@interface ClipViewController ()

@property (nonatomic, strong) UIImageView *topImgV;

@end

@implementation ClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    [self createUI];
 
    UIButton *popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [popBtn setTitle:@"返回" forState:UIControlStateNormal];
    [popBtn addTarget:self action:@selector(popBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:popBtn];
}

- (void)popBtnClick {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)createUI {
    
    [self.view addSubview:self.topImgV];
    self.topImgV.image = self.img;
//    [self.topImgV mask]
    self.topImgV.frame = CGRectMake(0, 64, MSScreenW, MSScreenH-64);

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark get and set

- (UIImageView *)topImgV {
    
    if (!_topImgV) {
        
        _topImgV = [[UIImageView alloc] init];
        [_topImgV setContentMode:UIViewContentModeScaleAspectFit];
        
        
    }
    return _topImgV;
}
@end
