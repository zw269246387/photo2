//
//  ObtainListViewController.m
//  UIImageView
//
//  Created by zheng on 2018/7/30.
//  Copyright © 2018年 zheng. All rights reserved.
//

#import "ObtainListViewController.h"

#import <Masonry.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
//相册 所有照片
#import "ObtainViewController.h"

#import "ZWPhotoDatas.h"
@interface ObtainListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *listTableView;

@property (nonatomic, strong) NSMutableArray *listArray;

@property (nonatomic, strong) UIButton *popBtn;

@property (nonatomic, strong) ZWPhotoDatas *datas;

@end

@implementation ObtainListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self loadData];
    
    //获取相册
    [self createUI];
    
    
    self.datas = [[ZWPhotoDatas alloc] init];
    
    self.datas.block = ^(BOOL isYes ) {
       
        NSLog(@"权限返回");
        if (isYes) {
            
            [self loadData];
        }
        
        
    };
    
    [self.datas isJurisdictionJudgment];
    
    
//
//    //相册权限判断
//    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//    if (status == PHAuthorizationStatusDenied) {
//        //相册权限未开启
//        //        [UIAlertView showAlertViewWithTitle:@"照片访问权限已关闭" message:@"请到设置->隐私->照片->开启【玩主】照片服务" cancelButtonTitle:@"取消" otherButtonTitles:@[@"设置"] onDismiss:^(long buttonIndex) {
//        //
//        //            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//        //            if([[UIApplication sharedApplication] canOpenURL:url]) {
//        //                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString]; [[UIApplication sharedApplication] openURL:url];
//        //            }
//        //        } onCancel:^{
//        //
//        //        }];
//
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"相册权限未开启？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//
//
//
//    }else if(status == PHAuthorizationStatusNotDetermined){
//        //相册进行授权
//        /* * * 第一次安装应用时直接进行这个判断进行授权 * * */
//        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
//            //授权后直接打开照片库
//            if (status == PHAuthorizationStatusAuthorized){
//
//                //获取相册数据
//                [self loadData];
//
//            }
//            else{
//
//
//            }
//        }];
//    }else if (status == PHAuthorizationStatusAuthorized){
//
//        //获取相册数据
//
//        [self loadData];
//    }


}

- (void)loadData {
    
    
    //获取到的是相册数
    NSMutableArray *dataArray = [NSMutableArray array];
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    
    
    if (!smartAlbumsFetchResult.count) {
        
        //        return dataArray;
        
        return;
    }
    [dataArray addObject:[smartAlbumsFetchResult objectAtIndex:0]];
    
    /*
     该方法用来获取处于图片app中根目录下的自己创建的相册（貌似自己创建的本身就在根目录下）
     
     */
    PHFetchResult *smartAlbumsFetchResult1 = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:fetchOptions];
    
    for (PHAssetCollection *sub in smartAlbumsFetchResult1)
    {
        [dataArray addObject:sub];
    }
    
    self.listArray = dataArray;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.listTableView reloadData];

    });
}

- (void)createUI {
    
    [self.view addSubview:self.listTableView];
    
    [self.listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    self.listTableView.rowHeight = 100;
    
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.edges.equalTo(self.view);
        
    }];
    
    [self.view addSubview:self.popBtn];
    
    [self.popBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.top.equalTo(self.view);
        make.width.height.offset(40);
    }];
    
}

- (void)popBtnClick {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tempCell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID" forIndexPath:indexPath];
    
    tempCell.selectionStyle = NO;
    UIImageView *tempImgV = [UIImageView new];
    
    [tempCell.contentView addSubview:tempImgV];
    [tempImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        
//        make.edges.equalTo(tempCell.contentView);
        make.left.equalTo(tempCell.contentView).offset(12);
        make.top.bottom.equalTo(tempCell.contentView);
        make.width.offset(100);
        
    }];
    
    [tempImgV setContentMode:UIViewContentModeScaleAspectFit];
    tempImgV.backgroundColor = [UIColor purpleColor];
    
    
    UILabel *nameL = [UILabel new];
    [tempCell.contentView addSubview:nameL];
    nameL.textColor = [UIColor whiteColor];
    nameL.backgroundColor = [UIColor orangeColor];
    
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(tempCell.contentView);
        make.left.equalTo(tempImgV.mas_right).offset(12);
        make.right.equalTo(tempCell.contentView).offset(-12);
        
    }];
    
    PHFetchResult *group = [PHAsset fetchAssetsInAssetCollection:self.listArray[indexPath.row] options:nil];
    
    
    [[PHImageManager defaultManager] requestImageForAsset:group.lastObject
                                               targetSize:CGSizeMake(200,200)
                                              contentMode:PHImageContentModeDefault
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                if (result == nil) {
                                                    tempImgV.image = [UIImage imageNamed:@"测试.jpg"];
                                                }else{
                                                    tempImgV.image = result;
                                                }
                                                
                                                
                                            }];
    
    
    PHAssetCollection *titleAsset = self.listArray[indexPath.row];
    
    if ([titleAsset.localizedTitle isEqualToString:@"All Photos"]) {
        nameL.text = [NSString stringWithFormat:@"相机胶卷 -- %lu",(unsigned long)group.count];
    }else{
    
        nameL.text = [NSString stringWithFormat:@"%@ -- %lu",titleAsset.localizedTitle,(unsigned long)group.count];

    }
    
    
    return tempCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ObtainViewController *obtainVC = [[ObtainViewController alloc] init];
    obtainVC.pushType = @"1";
    obtainVC.phasset = self.listArray[indexPath.row];

    [self presentViewController:obtainVC animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

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

- (UIButton *)popBtn {
    
    if (!_popBtn) {
        
        _popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_popBtn setTitle:@"返回" forState:UIControlStateNormal];
        _popBtn.backgroundColor = [UIColor redColor];
        [_popBtn addTarget:self action:@selector(popBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _popBtn;
}

@end
