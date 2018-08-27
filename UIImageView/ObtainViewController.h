//
//  ObtainViewController.h
//  UIImageView
//
//  Created by zheng on 2018/7/27.
//  Copyright © 2018年 zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ObtainViewController : UIViewController

@property (nonatomic, copy) NSString *pushType;

@property (nonatomic, strong) PHAssetCollection *phasset;

@end
