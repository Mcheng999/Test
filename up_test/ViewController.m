//
//  ViewController.m
//  up_test
//
//  Created by 张晗 on 2017/3/20.
//  Copyright © 2017年 张晗. All rights reserved.
//

#import "ViewController.h"
#import <Qiniu/QiniuSDK.h>
#import <QNResolver.h>
#import <QNNetworkInfo.h>
#import <QNDnsManager.h>

@interface ViewController () 
{
    NSString *token;
    NSString *file;
    __block BOOL flag;
    QNFileRecorder *recorder;
    QNUploadOption *opt;
    QNUploadManager *uploadManage;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    
    //声明
    flag = NO;
    //token
    token  = @"42dbN9SP8wCZYKwDOeHHUYLn0kp05cvxgdTvzytF:FT3J379b8NIvgRycqqRLuM5Wkag=:eyJzY29wZSI6IjEyMTIxMiIsImRlYWRsaW5lIjo4Nzg5MDAwNDYzMH0K";
    
    opt = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        NSLog(@"%f\n",percent);
        
    } params:nil checkCrc:NO cancellationSignal:^BOOL{
        return flag;
    }];
    
    //创建uploadManager
    uploadManage = [[QNUploadManager alloc] initWithConfiguration:[self setConfiguration]];
   
}

-(void)clickBtn:(UIButton *)btn{
    if (!btn.selected) {
        NSLog(@"暂停");
        btn.selected = !btn.selected;
        flag = YES;
    }else{
        NSLog(@"继续");
        btn.selected = !btn.selected;
        flag = NO;
        [self upload];
    }
    
}


-(void)setUI{
    UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 120, 80)];
    [startBtn setTitle:@"start" forState:UIControlStateNormal];
    startBtn.backgroundColor = [UIColor orangeColor];
    [startBtn addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    UIButton *pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 20, 120, 80)];
    [pauseBtn setTitle:@"pause" forState:UIControlStateNormal];
    [pauseBtn setTitle:@"resume" forState:UIControlStateSelected];
    pauseBtn.backgroundColor = [UIColor orangeColor];
    [pauseBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    pauseBtn.selected = NO;
    [self.view addSubview:pauseBtn];
    
}


-(QNConfiguration *)setConfiguration{
    QNConfiguration *config =[QNConfiguration build:^(QNConfigurationBuilder *builder) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[QNResolver systemResolver]];
        QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
        //是否选择  https  上传
        builder.zone = [[QNAutoZone alloc] initWithHttps:YES dns:dns];
        //设置断点续传
        //创建存储进度的文件夹
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        file = [document stringByAppendingPathComponent:@"up1"];
        //保存进度文件夹
        builder.recorder = [QNFileRecorder fileRecorderWithFolder:file encodeKey:YES error:nil];

    }];
    return config;
}

#pragma mark - 上传方法
-(void)upload{
    //选择上传的内容
    NSString *str = [[[NSBundle mainBundle] pathForResource:@"test" ofType:@"bundle"] stringByAppendingPathComponent:@"pili-ffmpeg-master.zip"];
    
    [uploadManage putFile:str key:@"0417" token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"%@\n",info);
        NSLog(@"%@\n",resp);
        
    } option:opt];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
