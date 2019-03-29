//
//  YTAFNetworkActivityIndicatorManager.m
//  YTAFNetworkingInterpretation
//
//  Created by july on 2019/3/29.
//  Copyright © 2019 july. All rights reserved.
//

#import "YTAFNetworkActivityIndicatorManager.h"

@implementation YTAFNetworkActivityIndicatorManager

/*
 
 
 一、简单解读

    1.AF的这个AFNetworkActivityIndicatorManager类用来检测网络状态
 
    2.AFNetworkReachabilityStatus 枚举表示有4种状态
        ！值得注意的是这里的蜂窝是区分不了2g/3g/4g的，这里提供一种思路，可以根据状态栏的标志进行判断，状态栏子view UIStatusBarDataNetworkItemView 有个 dataNetworkType ：0 无网络，1 2g，2 3g，3 4g，5 wifi
        AFNetworkReachabilityStatusUnknown          = -1,  //未知的网络
        AFNetworkReachabilityStatusNotReachable     = 0,   //无网络
        AFNetworkReachabilityStatusReachableViaWWAN = 1,   //蜂窝网络
        AFNetworkReachabilityStatusReachableViaWiFi = 2,   //wifi
 
    3.使用单例 维护一份检测的管理者
        + (instancetype)sharedManager {
            static AFNetworkActivityIndicatorManager *_sharedManager = nil;
            static dispatch_once_t oncePredicate;
            dispatch_once(&oncePredicate, ^{
            _sharedManager = [[self alloc] init];
            });
            return _sharedManager;
        }
 
    4.AFNetworkActivityManagerState 管理者的活动状态
        AFNetworkActivityManagerStateNotActive,     // 未激活
        AFNetworkActivityManagerStateDelayingStart, // 激活前的延时阶段
        AFNetworkActivityManagerStateActive,        // 激活
        AFNetworkActivityManagerStateDelayingEnd    // 取消阶段
 
    5.
 
 
 
 
 
 
 
 
 

 
 
 */


- (void)getNetStatus{
    
    //当使用AF发送网络请求时,是否在状态栏显示菊花提示
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    //能够检测当前网络是wifi,蜂窝网络,没有网
    [[AFNetworkReachabilityManager sharedManager]
     setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
         // 网络发生变化时 会触发这里的代码
         switch (status) {
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 // NSLog(@"当前是wifi环境");
                 break;
                 
             case AFNetworkReachabilityStatusNotReachable:
                 // NSLog(@"当前无网络");
                 break;
                 
             case AFNetworkReachabilityStatusUnknown:
                 // NSLog(@"当前网络未知");
                 break;
                 
             case AFNetworkReachabilityStatusReachableViaWWAN:
                 // NSLog(@"当前是蜂窝网络");
                 break;
             default:
                 break;
         }
     }];
    
    //开启网络检测  需要时候使用
    //[[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //添加监听，网络活动发生变化时,会发送下方key（AFNetworkingReachabilityDidChangeNotification）的通知
    /*
     [[NSNotificationCenter defaultCenter] addObserver:nil selector:nil
     name:AFNetworkingReachabilityDidChangeNotification object:nil];
     */
}

@end


