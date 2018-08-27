//
//  ZWPhotoDatas.m
//  UIImageView
//
//  Created by zheng on 2018/8/16.
//  Copyright © 2018年 zheng. All rights reserved.
//

#import "ZWPhotoDatas.h"

@implementation ZWPhotoDatas

- (void)isJurisdictionJudgment {
    
    
    //相册权限判断
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusDenied) {
        //相册权限未开启
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"相册权限未开启？" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        self.block(NO);
    }else if(status == PHAuthorizationStatusNotDetermined){
        //相册进行授权
        /* * * 第一次安装应用时直接进行这个判断进行授权 * * */
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
            //授权后直接打开照片库
            if (status == PHAuthorizationStatusAuthorized){
                self.block(YES);

                
            }
            else{
                self.block(NO);

            }
            
            
        }];
        
    }else if (status == PHAuthorizationStatusAuthorized){
        
        //获取相册数据

        self.block(YES);
    }
    
}

+ (NSMutableArray *) GetPhotoListDatas {
    
    
    //获取到的是相册数
    NSMutableArray *dataArray = [NSMutableArray array];
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    
    
//    if (!smartAlbumsFetchResult.count) {
//
//        //        return dataArray;
//
//        return;
//    }
    [dataArray addObject:[smartAlbumsFetchResult objectAtIndex:0]];
    
    /*
     该方法用来获取处于图片app中根目录下的自己创建的相册（貌似自己创建的本身就在根目录下）
     
     */
    PHFetchResult *smartAlbumsFetchResult1 = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:fetchOptions];
    
    for (PHAssetCollection *sub in smartAlbumsFetchResult1)
    {
        [dataArray addObject:sub];
    }
    return dataArray;
    
}

+ (NSMutableArray *) GetFetchResult:(PHAssetCollection *)asset {
    
    //点击相册进来的
    PHFetchResult *fetch = [PHAsset fetchAssetsInAssetCollection:asset options:nil];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (PHAsset *asset in fetch) {
        //只添加图片类型资源，去除视频类型资源
        //当mediaType == 2时，这个资源则为视频资源
        if (asset.mediaType == 1) {
            [dataArray addObject:asset];
            NSLog(@"%@",[asset valueForKey:@"filename"]);
            
        }
    }
        return dataArray;
    
}

+ (NSMutableArray *)GetCameraRollFetchResul {
    
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
    
    return dataArray;
    
}
@end
