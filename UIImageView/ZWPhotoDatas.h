//
//  ZWPhotoDatas.h
//  UIImageView
//
//  Created by zheng on 2018/8/16.
//  Copyright © 2018年 zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

typedef void (^isJurisdictionBlock)(BOOL );

@interface ZWPhotoDatas : NSObject

@property (nonatomic, copy)isJurisdictionBlock block;


- (void)isJurisdictionJudgment;

/**
  获取全部相册

 @return <#return value description#>
 */
+ (NSMutableArray *) GetPhotoListDatas;
/**
 获取某一个相册的结果集

 @param asset <#asset description#>
 @return <#return value description#>
 */
+ (NSMutableArray *) GetFetchResult:(PHAssetCollection *)asset;

/**
 只获取相机胶卷结果集

 @return <#return value description#>
 */
+ (NSMutableArray *) GetCameraRollFetchResul;

@end
