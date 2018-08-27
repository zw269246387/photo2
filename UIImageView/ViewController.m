//
//  ViewController.m
//  UIImageView
//
//  Created by zheng on 2018/4/26.
//  Copyright © 2018年 zheng. All rights reserved.
//

#import "ViewController.h"

#import <Masonry.h>
//相机图片列表
#import "ObtainViewController.h"
//所有相册
#import "ObtainListViewController.h"
//自定义相机
#import "CustomCameraViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

/**
 图片
 */
@property (nonatomic, strong) UIImageView *iconImgV;

/**
 列表
 */
@property (nonatomic, strong) UITableView *listTableView;

/**
 数据源
 */
@property (nonatomic, strong) NSMutableArray *listArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //各种 UIImageView 的属性学习
    /*
    UIViewContentModeScaleToFill,
    UIViewContentModeScaleAspectFit,      // contents scaled to fit with fixed aspect. remainder is transparent
    UIViewContentModeScaleAspectFill,     // contents scaled to fill with fixed aspect. some portion of content may be clipped.
    UIViewContentModeRedraw,              // redraw on bounds change (calls -setNeedsDisplay)
    UIViewContentModeCenter,              // contents remain same size. positioned adjusted.
    UIViewContentModeTop,
    UIViewContentModeBottom,
    UIViewContentModeLeft,
    UIViewContentModeRight,
    UIViewContentModeTopLeft,
    UIViewContentModeTopRight,
    UIViewContentModeBottomLeft,
    UIViewContentModeBottomRight,
    */
    
    [self.view addSubview:self.iconImgV];
    self.iconImgV.image = [UIImage imageNamed:@"测试.jpg"];
    self.iconImgV.backgroundColor = [UIColor orangeColor];

//默认属性   填充imgV  会拉伸和压缩
//    [self.iconImgV setContentMode:UIViewContentModeScaleToFill];
    
//图片拉伸至完全显示在UIImageView里面为止(图片不会变形)
//    [self.iconImgV setContentMode:UIViewContentModeScaleAspectFit];

    ////图片拉伸至图片的的宽度或者高度等于UIImageView的宽度或者高度为止.看图片的宽高哪一边最接近UIImageView的宽高,一个属性相等后另一个就停止拉伸.
    [self.iconImgV setContentMode:UIViewContentModeScaleAspectFill];
//    self.iconImgV.layer.masksToBounds = YES;

    
    //下面的属性都是不会拉伸图片的
//    [self.iconImgV setContentMode:UIViewContentModeRedraw];
    
//    [self.iconImgV setContentMode:UIViewContentModeCenter];

//    [self.iconImgV setContentMode:UIViewContentModeTop];

    
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.center.equalTo(self.view);
        make.width.height.offset(200);
        
    }];
    
    [self.listArray addObject:@"获取相机相册的图片"];
    [self.listArray addObject:@"获取全部相册列表"];
    [self.listArray addObject:@"自定义相机"];

    
    [self.view addSubview:self.listTableView];
    self.listTableView.rowHeight = 40;
    [self.listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.edges.equalTo(self.view);
        
    }];
    
}

#pragma mark UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID" forIndexPath:indexPath];
    
    cell.textLabel.text = self.listArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0:
            [self presentViewController:[ObtainViewController new] animated:YES completion:nil];
            
            break;
        case 1:
            [self presentViewController:[ObtainListViewController new] animated:YES completion:nil];
            
            break;
        case 2:
            [self presentViewController:[CustomCameraViewController new] animated:YES completion:nil];
            
            break;
            
        default:
            break;
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark get and set

- (UIImageView *)iconImgV {
    
    if (!_iconImgV) {
        
        _iconImgV = [UIImageView new];
    }
    return _iconImgV;
}


- (UITableView *)listTableView{
    
    if (!_listTableView) {
        
        _listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
    }
    
    return _listTableView;
}

- (NSMutableArray *)listArray{
    
    if (!_listArray) {
        
        _listArray = [NSMutableArray array];
    }
    
    return _listArray;
    
}

@end
