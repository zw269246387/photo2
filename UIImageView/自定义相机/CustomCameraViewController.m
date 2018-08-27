//
//  CustomCameraViewController.m
//  UIImageView
//
//  Created by zheng on 2018/8/17.
//  Copyright © 2018年 zheng. All rights reserved.
//

#import "CustomCameraViewController.h"
#import <AVFoundation/AVFoundation.h>

#import <Masonry.h>
//裁剪
#import "ClipViewController.h"

#import "UIImage+Handler.h"
//获取屏幕 宽度、高度
#define MSScreenW ([UIScreen mainScreen].bounds.size.width)
#define MSScreenH ([UIScreen mainScreen].bounds.size.height)
#define MSScreenBounds [UIScreen mainScreen].bounds

//iphone6 高度比例
#define MSSCALE MSScreenH/667.0

// iPhone6下适配
#define MSAdaptedWidth(x) (x * MSScreenW/375.0f)
#define MSAdaptedHeight(x) (x * MSScreenH/667.0f)
@interface CustomCameraViewController ()

/**
  AVCaptureSession 对象来执行输入和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession *session;

/**
 AVCaptureInput：输入数据管理对象，经过 AVCaptureDevice 实现初始化，然后添加到 AVCaptureSession (发电机) 中进行相应的输出。
 子类：AVCaptureDeviceInput、AVCaptureScreenInput和AVCaptureMetadataInput。
 */
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;

/**
 AVCaptureOut：数据输出管理，通过 AVCaptureSession 中输出。可以通过相关的协议实对应的数据输出
 子类：AVCaptureFileOutput、AVCapturePhotoOutput、AVCaptureStillImageOutput、AVCaptureVideoDataOutput、AVCaptureAudioDataOutput、AVCaptureAudioPreviewOutput、AVCaptureDepthDataOutput和AVCaptureMetadataOutput。
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

/**
 AVCaptureVideoPreviewLayer：可以支持在拍摄过程中进行相关的预览，只需要在初始时实现对应的 AVCaptureSession 即可。
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

/**
 AVCaptureConnection设置input,output连接的重要属性
 在给AVCaptureSession添加input和output以后,就可以通过audio或者video的output生成AVCaptureConnection.通过connection设置output的视频或者音频的重要属性,比如ouput video的方向videoOrientation(这里注意videoOrientation并非DeviceOrientation,默认情况下录制的视频是90度转角的,这个是相机传感器导致的,请google)
 */
@property (nonatomic, strong) AVCaptureConnection *stillImageConnection;

//@property (nonatomic, strong) UIView *cetentView;
//
//@property (nonatomic, strong) UILabel *nameL;

@property (nonatomic, strong) UIButton *popBtn;

/**
 拍的图片数组
 */
@property (nonatomic, strong) NSMutableArray *imgs;

/**
 图片数量
 */
@property (nonatomic, strong) UILabel *numberL;

/**
 右下角的图片
 */
@property (nonatomic, strong) UIImageView *imgV;


@end

@implementation CustomCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        NSLog(@"%@",granted ? @"相机准许":@"相机不准许");
        
        
        if (!granted) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //跳转设置
                UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:@"相机访问权限已关闭" message:@"请到设置->隐私->照片->开启【中车购】服务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
                
                [alert2 show];
            });
        
            
            return;
            
        }
    }];
    
    [self initAVCaptureSession];
    
    [self createdTool];

/*
    
    [self.view addSubview:self.cetentView];
    [self.view addSubview:self.nameL];
    
    self.cetentView.frame = CGRectMake(0, 0 , 90, 90);

    self.cetentView.center = self.view.center;

    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
    
        make.top.equalTo(self.view).offset((MSScreenH/2) + MSAdaptedHeight(120));
        make.left.right.equalTo(self.view);
        make.height.offset(10);
 
    }];
 */

    [self.view addSubview:self.popBtn];
    
    [self.popBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.equalTo(self.view);
        make.width.height.offset(40);
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];

    }
    
}

- (void)popBtnClick {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createdTool {
    
    UIView *toolView = [[UIView alloc] init];
    toolView.backgroundColor = [UIColor blackColor];
    toolView.alpha = 0.8;
    [self.view addSubview:toolView];
    
    [toolView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.equalTo(self.view);
        make.height.offset(64);
        
    }];
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setImage:[UIImage imageNamed:@"相机_拍照"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(takePhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:cameraBtn];

    [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(toolView);
        make.centerY.equalTo(toolView);

    }];
    
    [toolView addSubview:self.imgV];
    [self.imgV addSubview:self.numberL];
    
    [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(toolView).offset(12);
        make.centerY.equalTo(toolView);
        make.width.height.offset(50);
    }];
    
    self.numberL.layer.masksToBounds = YES;
//    self.numberL.layer.cornerRadius = 8;
    self.numberL.backgroundColor = [UIColor greenColor];
    
    [self.numberL mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.right.equalTo(self.imgV);
//        make.height.offset(16);
//        make.width.offset(16);
        
    }];
    
    [self update];
}

- (void)update {
    
    if (self.imgs.count) {
        
        self.imgV.hidden = NO;
        
        self.numberL.text = [NSString stringWithFormat:@"%@%lu%@",@" ",(unsigned long)self.imgs.count,@" "];
//        self.numberL.text = @"100000";

        self.imgV.image = [self.imgs lastObject];

//        if (self.numberL.text.length > 1) {
        
            [self.numberL sizeToFit];
            self.numberL.layer.cornerRadius = self.numberL.frame.size.height/2;

            NSLog(@"%@",self.numberL);
            
//        }
    }else {
        
        self.imgV.hidden = YES;
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    if (self.session) {
        //开始运行
        [self.session startRunning];
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
    if (self.session) {
        
        [self.session stopRunning];
    }
}

- (void)initAVCaptureSession {
    
    self.session = [[AVCaptureSession alloc] init];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //更改这个设置的时候，必须先锁定设备，修改完成之后在解锁，否则崩溃
    [device lockForConfiguration:nil];
    
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];;
    
    if (error) {
        
        NSLog(@"%@",error);
    }
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置 AVVideoCodecJPEG  输出jpeg 个数的图片
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.session canSetSessionPreset:AVCaptureSessionPreset1920x1080];
    
    if ([self.session canAddInput:self.videoInput]) {
        
        [self.session addInput:self.videoInput];
    }
    
    if ([self.session canAddOutput:self.stillImageOutput]) {
        
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    /*
     最后查找到使用其中一个叫 videoGravity 的属性，默认设置了AVLayerVideoGravityResize，查看该属性以及相关的其他属性值发现有3种值可以设置，
     
     AVLayerVideoGravityResizeAspect
     
     AVLayerVideoGravityResizeAspectFill
     
     AVLayerVideoGravityResize
     
     1.保持纵横比；适合层范围内
     2.保持纵横比；填充层边界
     3.拉伸填充层边界
     */
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.previewLayer.frame = CGRectMake(0, 0, MSScreenW, MSScreenH - 100);
    
    self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
    
    //聚焦
    [self resetFocusAndExposureModes];
    
    
}

- (void)resetFocusAndExposureModes {
    
}

//获取设备方向
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
    
}
/**
 拍照
 */
- (void)takePhotoButtonClick {
    
    _stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [_stillImageConnection setVideoOrientation:avcaptureOrientation];
    [_stillImageConnection setVideoScaleAndCropFactor:1.0];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:_stillImageConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        UIImage *tempImg = [UIImage imageWithData:jpegData];
        //写入相册
//        UIImageWriteToSavedPhotosAlbum(tempImg, self, nil, nil);
        
        //需要把图片裁剪未 指定尺寸
        //需要把图片裁剪未 指定尺寸
        //扩展  UIImage
        //123456
        
        [tempImg imageAtRect:CGRectMake(0, 0, MSScreenW, 300)];
        
        //节点1 的修改
        [self.imgs addObject:tempImg];
        
        [self update];
        
        [self jumpImageView:jpegData];
    }];
    
}

/**
 拍照完成 调用

 @param data <#data description#>
 */
-(void)jumpImageView:(NSData*)data{
    ClipViewController *viewController = [[ClipViewController alloc] init];
    UIImage *image = [UIImage imageWithData:data];
    viewController.img = image;
    
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:viewController];
    [self presentViewController:nav animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark get and set
/*
- (UIView *)cetentView {
    
    if (!_cetentView) {
        
        _cetentView = [[UIView alloc] init];
        _cetentView.backgroundColor = [UIColor orangeColor];
        
    }
    return _cetentView;
}

- (UILabel *)nameL {
    
    if (!_nameL) {
        
        _nameL = [[UILabel alloc] init];
        _nameL.backgroundColor = [UIColor redColor];
        
    }
    return _nameL;
}
 */

- (UIButton *)popBtn {
    
    if (!_popBtn) {
        
        _popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_popBtn setTitle:@"返回" forState:UIControlStateNormal];
        _popBtn.backgroundColor = [UIColor redColor];
        [_popBtn addTarget:self action:@selector(popBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _popBtn;
}

- (NSMutableArray *)imgs{
    
    if (!_imgs) {
        
        _imgs = [NSMutableArray array];
    }
    
    return _imgs;
    
}

- (UILabel *)numberL {
    
    if (!_numberL) {
        
        _numberL = [[UILabel alloc] init];
        _numberL.font = [UIFont systemFontOfSize:9];
        _numberL.textColor = [UIColor redColor];
//        _numberL.textAlignment = NSTextAlignmentCenter;
    }
    return _numberL;
}

- (UIImageView *)imgV {
    
    if (!_imgV) {
        
        _imgV = [[UIImageView alloc] init];
        
    }
    return _imgV;
}
@end
