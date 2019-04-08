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
    //初始化方法
    - (instancetype)init {
        self = [super init];
        if (!self) {
            return nil;
        }
        //设置未活跃状态
        self.currentState = AFNetworkActivityManagerStateNotActive;
        //开始通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingTaskDidResumeNotification object:nil];
        //挂起通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidSuspendNotification object:nil];
        //完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
        //这里添加了两个延时，用于优化加载的显示
        self.activationDelay = kDefaultAFNetworkActivityManagerActivationDelay;
        self.completionDelay = kDefaultAFNetworkActivityManagerCompletionDelay;
 
        return self;
    }
 
    6.
    //页面销毁
    - (void)dealloc {
        //移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //关闭两个定时器
        [_activationDelayTimer invalidate];
        [_completionDelayTimer invalidate];
    }

    7.
    //重写管理的状态的set方法
    - (void)setEnabled:(BOOL)enabled {
        _enabled = enabled;
        //如果是no，就设置管理者状态为 未活跃状态
        if (enabled == NO) {
            [self setCurrentState:AFNetworkActivityManagerStateNotActive];
        }
    }
 
    8.
    //block自己管理 可以回调开始结束等状态
    - (void)setNetworkingActivityActionWithBlock:(void (^)(BOOL networkActivityIndicatorVisible))block {
        self.networkActivityActionBlock = block;
    }
 
    9.
    //判断是否激活中，发现这里是根据activityCount来判断是否激活的
    - (BOOL)isNetworkActivityOccurring {
        //self 互斥锁
        @synchronized(self) {
            return self.activityCount > 0;
        }
    }
 
    10.
        似乎self.activityCount 像计数器，只要大于0 就是激活状态，可以看到下方两个方法incrementActivityCount 和 decrementActivityCount
        1.两个方法对 activityCount++ 或者 activityCount--
        2.手动触发kvo
        3.dispatch_async(dispatch_get_main_queue(), ^{});更新网络的活动状态

    
 
 

 
 
 */


- (void)getNetStatus{
    
    //当使用AF发送网络请求时,是否在状态栏显示菊花提示 
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
}

@end


