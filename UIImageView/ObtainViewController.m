//
//  ObtainViewController.m
//  UIImageView
//
//  Created by zheng on 2018/7/27.
//  Copyright © 2018年 zheng. All rights reserved.
//

#import "ObtainViewController.h"
#import <Masonry.h>


@interface ObtainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

/**
 列表
 */
@property (nonatomic, strong) UICollectionView *collectionV;

/**
 数据源
 */
@property (nonatomic, strong) NSMutableArray *imgs;

@property (nonatomic, strong) UIButton *popBtn;

@end

@implementation ObtainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //获取相册图片
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    
    
    if ([self.pushType isEqualToString:@"1"]) {
        
        //点击相册进来的
        PHFetchResult *fetch = [PHAsset fetchAssetsInAssetCollection:self.phasset options:nil];

        NSMutableArray *dataArray = [NSMutableArray array];
        for (PHAsset *asset in fetch) {
            //只添加图片类型资源，去除视频类型资源
            //当mediaType == 2时，这个资源则为视频资源
            if (asset.mediaType == 1) {
                [dataArray addObject:asset];
                NSLog(@"%@",[asset valueForKey:@"filename"]);
                
            }
        }
        
        self.imgs = dataArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 回到主线程，执行UI刷新操作
            [self.collectionV reloadData];
            
        });
        
    }else {
        
        //获取图片数据
        [self loadData];

    }
    
    [self.view addSubview:self.collectionV];
    [self.collectionV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCellID"];
    
    [self.collectionV mas_makeConstraints:^(MASConstraintMaker *make) {
       
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

- (void)loadData {

    //相册权限判断
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        //相册权限未开启
//        [UIAlertView showAlertViewWithTitle:@"照片访问权限已关闭" message:@"请到设置->隐私->照片->开启【玩主】照片服务" cancelButtonTitle:@"取消" otherButtonTitles:@[@"设置"] onDismiss:^(long buttonIndex) {
//
//            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//            if([[UIApplication sharedApplication] canOpenURL:url]) {
//                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString]; [[UIApplication sharedApplication] openURL:url];
//            }
//        } onCancel:^{
//
//        }];

         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"相册权限未开启？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alert show];
        
    
        
    }else if(status == PHAuthorizationStatusNotDetermined){
        //相册进行授权
        /* * * 第一次安装应用时直接进行这个判断进行授权 * * */
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
            //授权后直接打开照片库
            if (status == PHAuthorizationStatusAuthorized){
            
                //获取相册数据
                [self loadDataImgs];

            }
            else{
                
              
            }
        }];
    }else if (status == PHAuthorizationStatusAuthorized){

        //获取相册数据
        
        [self loadDataImgs];
    }

   
}

/**
 获图片列表
 */
- (void)loadDataImgs {
    
    /*
    //获取到的是相册数
    NSMutableArray *dataArray = [NSMutableArray array];
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    
    
    if (!smartAlbumsFetchResult.count) {
        
//        return dataArray;
        
        return;
    }
    [dataArray addObject:[smartAlbumsFetchResult objectAtIndex:0]];
    
    PHFetchResult *smartAlbumsFetchResult1 = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:fetchOptions];
    
    for (PHAssetCollection *sub in smartAlbumsFetchResult1)
    {
        [dataArray addObject:sub];
    }
    
    self.imgs = dataArray;
    
    
    */
    
    
    /*
     
     PHAsset:单个资源
     PHAssetCollection：PHCollection的子类，单个资源的集合，如相册、时刻等
     PHCollectionList：PHCollection的子类，集合的集合，如相册文件夹
     PHPhotoLibrary：类似于总管理，负责注册通知、检查和请求获取权限
     PHImageManager：按照要求获取制定的图片
     PHCachingImageManager：PHImageManager的子类
     PHAssetChangeRequest：编辑相册，增删改查


     */
    
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    /*
    PHAssetCollection  一个该实例对象代表一个相册。是PHCollection的子类。它的所有属性都是只读的，另外有8个类方法，用来获取想要的结果。
     
    + (PHFetchResult<PHAssetCollection *> *)fetchAssetCollectionsWithType:(PHAssetCollectionType)type subtype:(PHAssetCollectionSubtype)subtype options:(nullable PHFetchOptions *)options;
     
    该方法是该类的主要访问方法，主要用于在未知相册的情况下，直接通过type和subtype从相册获取相应的相册。type和subtype如下所示：
    
     typedef NS_ENUM(NSInteger, PHAssetCollectionType) {
     PHAssetCollectionTypeAlbum      = 1,  相册，系统外的
     PHAssetCollectionTypeSmartAlbum = 2,  智能相册，系统自己分配和归纳的
     PHAssetCollectionTypeMoment     = 3,  时刻，系统自动通过时间和地点生成的分组
     } PHOTOS_ENUM_AVAILABLE_IOS_TVOS(8_0, 10_0);
     *
     * typedef NS_ENUM(NSInteger, PHAssetCollectionSubtype) {
     
     // PHAssetCollectionTypeAlbum regular subtypes
     PHAssetCollectionSubtypeAlbumRegular         = 2, // 在iPhone中自己创建的相册
     PHAssetCollectionSubtypeAlbumSyncedEvent     = 3, // 从iPhoto（就是现在的图片app）中导入图片到设备
     PHAssetCollectionSubtypeAlbumSyncedFaces     = 4, // 从图片app中导入的人物照片
     PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5, // 从图片app导入的相册
     PHAssetCollectionSubtypeAlbumImported        = 6, // 从其他的相机或者存储设备导入的相册
     
     // PHAssetCollectionTypeAlbum shared subtypes
     PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100,  // 照片流，照片流和iCloud有关，如果在设置里关闭了iCloud开关，就获取不到了
     PHAssetCollectionSubtypeAlbumCloudShared     = 101,  // iCloud的共享相册，点击照片上的共享tab创建后就能拿到了，但是前提是你要在设置中打开iCloud的共享开关（打开后才能看见共享tab）
     
     // PHAssetCollectionTypeSmartAlbum subtypes
     PHAssetCollectionSubtypeSmartAlbumGeneric    = 200,
     PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,  // 全景图、全景照片
     PHAssetCollectionSubtypeSmartAlbumVideos     = 202,  // 视频
     PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,  // 标记为喜欢、收藏
     PHAssetCollectionSubtypeSmartAlbumTimelapses = 204,  // 延时拍摄、定时拍摄
     PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205,  // 隐藏的
     PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,  // 最近添加的、近期添加
     PHAssetCollectionSubtypeSmartAlbumBursts     = 207,  // 连拍
     PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,  // Slow Motion,高速摄影慢动作（概念不懂）
     PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,  // 相机胶卷
     PHAssetCollectionSubtypeSmartAlbumSelfPortraits PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 210, // 使用前置摄像头拍摄的作品
     PHAssetCollectionSubtypeSmartAlbumScreenshots PHOTOS_AVAILABLE_IOS_TVOS(9_0, 10_0) = 211,  // 屏幕截图
     PHAssetCollectionSubtypeSmartAlbumDepthEffect PHOTOS_AVAILABLE_IOS_TVOS(10_2, 10_1) = 212,  // 在可兼容的设备上使用景深摄像模式拍的照片（概念不懂）
     PHAssetCollectionSubtypeSmartAlbumLivePhotos PHOTOS_AVAILABLE_IOS_TVOS(10_3, 10_2) = 213,  // Live Photo资源
     PHAssetCollectionSubtypeSmartAlbumAnimated PHOTOS_AVAILABLE_IOS_TVOS(11_0, 11_0) = 214,  // 没有解释
     PHAssetCollectionSubtypeSmartAlbumLongExposures PHOTOS_AVAILABLE_IOS_TVOS(11_0, 11_0) = 215,  // 没有解释
     // Used for fetching, if you don't care about the exact subtype
     PHAssetCollectionSubtypeAny = NSIntegerMax
     } PHOTOS_ENUM_AVAILABLE_IOS_TVOS(8_0, 10_0);
     
     
     
     */

    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    /*
     PHAsset
     该类表示具体的资源信息，如宽度、高度、时长、是否是收藏的等等。同上面提到的几个类一样，该类的属性也都是只读的，所以我们主要是用它的方法来获取资源。
     
     + (PHFetchResult<PHAsset *> *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection options:(nullable PHFetchOptions *)options;
     该方法是从相册中获取单个资源的主要途径：

     
     */
    
    PHFetchResult *fetch = [PHAsset fetchAssetsInAssetCollection:[smartAlbumsFetchResult objectAtIndex:0] options:nil];
    
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (PHAsset *asset in fetch) {
        //只添加图片类型资源，去除视频类型资源
        //当mediaType == 2时，这个资源则为视频资源
        if (asset.mediaType == 1) {
            [dataArray addObject:asset];
            NSLog(@"%@",[asset valueForKey:@"filename"]);
            
        }
        
    }
    
     self.imgs = dataArray;

    dispatch_async(dispatch_get_main_queue(), ^{
        // 回到主线程，执行UI刷新操作
        [self.collectionV reloadData];

    });

}

#pragma mark UICollectionViewDelegate,UICollectionViewDataSource

/**
 个数
 
 @param collectionView <#collectionView description#>
 @param section <#section description#>
 @return <#return value description#>
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.imgs.count;
}

/**
 cell
 
 @param collectionView <#collectionView description#>
 @param indexPath <#indexPath description#>
 @return <#return value description#>
 */
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //获取cell
    
    UICollectionViewCell *tempCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellID" forIndexPath:indexPath];
    
    UIImageView *tempImgV = [UIImageView new];
    
    [tempCell.contentView addSubview:tempImgV];
    [tempImgV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.edges.equalTo(tempCell.contentView);
    }];
    
    [tempImgV setContentMode:UIViewContentModeScaleAspectFit];
    tempImgV.backgroundColor = [UIColor purpleColor];
    /*
    ///////////////////
    //加载图片
    PHAssetCollection *collectionItem = self.imgs[indexPath.row];
    
    PHFetchResult *group = [PHAsset fetchAssetsInAssetCollection:collectionItem options:nil];
    
    
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
    
    
    PHAssetCollection *titleAsset = collectionItem;
    */
    
    PHAsset *phAsset = self.imgs[indexPath.row];
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
        
        tempImgV.image = result;
        
    }];
    
    return tempCell;
}

/**
 CGSize
 
 @param collectionView <#collectionView description#>
 @param collectionViewLayout <#collectionViewLayout description#>
 @param indexPath <#indexPath description#>
 @return <#return value description#>
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(100 , 100);
}


/**
 点击
 
 @param collectionView <#collectionView description#>
 @param indexPath <#indexPath description#>
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark get and set

/**
 列表
 
 @return <#return value description#>
 */
- (UICollectionView *)collectionV {
    
    if (!_collectionV) {
        
        //flowLayout
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumLineSpacing = 1 ;// 行间距
        flowLayout.minimumInteritemSpacing = 1 ;//列间距
        //初始化
        _collectionV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        //代理
        _collectionV.delegate = self;
        _collectionV.dataSource = self;
        
    }
    return _collectionV;
}

- (NSMutableArray *)imgs{
    
    if (!_imgs) {
        
        _imgs = [NSMutableArray array];
    }
    
    return _imgs;
    
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
