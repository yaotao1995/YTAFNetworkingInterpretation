//
//  YTAFNetworkReachabilityManager.m
//  YTAFNetworkingInterpretation
//
//  Created by july on 2019/4/8.
//  Copyright © 2019 july. All rights reserved.
//

#import "YTAFNetworkReachabilityManager.h"

@implementation YTAFNetworkReachabilityManager

/*
 
    1.AFNetworkReachabilityManager是用来监测网络的
 
    2.不难看出单例中最终调用了manager来初始化
     + (instancetype)sharedManager {
        static AFNetworkReachabilityManager *_sharedManager = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedManager = [self manager];
        });
        return _sharedManager;
     }
 
    来看看函数 manager ，先简单看下，条件成立与否都返回address 这个结构体 给函数managerForAddress，区别就在于条件成立 结构体类型是sockaddr_in6 ，不成立使用 sockaddr_in，以及结构体成员变量sin_family的赋值问题；至于bzero(）内存分配方法暂且先不管；
 
     + (instancetype)manager
     {
        #if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
            struct sockaddr_in6 address;
            bzero(&address, sizeof(address));
            address.sin6_len = sizeof(address);
            address.sin6_family = AF_INET6;
        #else
            struct sockaddr_in address;
            bzero(&address, sizeof(address));
            address.sin_len = sizeof(address);
            address.sin_family = AF_INET;
        #endif
            return [self managerForAddress:&address];
     }
 
        3. 先看下条件(defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
 
            其中两部分条件可以分为：MAC_OS的版本要求以及IPHONE_OS版本要求，这里暂且就看下IPHONE_OS 的版本要求，要求__IPHONE_OS_VERSION_MIN_REQUIRED 值大于等于 90000 即 版本大于等于ios9
 
        4. 两结构体看原文注释就知道了 sockaddr_in6：Socket address for IPv6；sockaddr_in：Socket address, internet style.也就是说
           在这里区分了ipv6 和 ipv4 的，这里存在一个ipv4和ipv6的转换问题有兴趣可以查资料看下
 
//             struct sockaddr_in6 {
//             __uint8_t    sin6_len;
//            sa_family_t    sin6_family;
//            in_port_t    sin6_port;
//            __uint32_t    sin6_flowinfo;
//            struct in6_addr    sin6_addr;
//            __uint32_t    sin6_scope_id;
//            };

//            struct sockaddr_in {
//                __uint8_t    sin_len;
//                sa_family_t    sin_family;
//                in_port_t    sin_port;
//                struct    in_addr sin_addr;
//                char        sin_zero[8];
//            };
 
        5.再往下走 得到区分ipv6的地址之后 managerForAddress：(const void *)address 函数
            这里我们可以较为清楚看到，af实际调用的就是 原生的 SCNetworkReachabilityRef
            SCNetworkReachabilityRef 来自 SystemConfiguration.framework ， 其中工具 SCNetworkReachability 就是用来监测网络状况的
            查看 SCNetworkReachabilityRef，它也是个结构体，官方解释为：网络地址或名字的句柄
 
            + (instancetype)managerForAddress:(const void *)address {
                SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
                AFNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
                
                CFRelease(reachability);
                
                return manager;
            }
 
        6. 这里我贴一段使用 SystemConfiguration.framework 反汇编出来的 SCNetworkReachabilityCreateWithAddress函数的伪代码 有兴趣的可以看下
             int _SCNetworkReachabilityCreateWithAddress(int arg0, int arg1) {
                r7 = (sp - 0x14) + 0xc;
                sp = sp - 0x24;
                r4 = arg0;
                var_1C = *0x3e5e5944;
                r5 = _is_valid_address(arg1);
                if (r5 == 0x0) goto loc_1b2278be;
 
        7. 到这里AFNetworkReachabilityManager还没创建好，CFRetain表示传入的reachability不为空，赋给本身的SCNetworkReachabilityRef，并且修改状态为 AFNetworkReachabilityStatusUnknown，至此初始化完成
             - (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
                self = [super init];
                if (!self) {
                    return nil;
                }
                _networkReachability = CFRetain(reachability);
                self.networkReachabilityStatus = AFNetworkReachabilityStatusUnknown;
                return self;
            }
 
        8. 创建好了，接下去要用了startMonitoring 函数是开启监测时候使用的
             - (void)startMonitoring {
                //启用之前先调用停止函数
                [self stopMonitoring];
                //判断上述的SCNetworkReachabilityRef是否存在
                if (!self.networkReachability) {
                    return;
                }
 
                //写好block，用来回调状态
                __weak __typeof(self)weakSelf = self;
                AFNetworkReachabilityStatusBlock callback = ^(AFNetworkReachabilityStatus status) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
             
                    strongSelf.networkReachabilityStatus = status;
                    if (strongSelf.networkReachabilityStatusBlock) {
                        strongSelf.networkReachabilityStatusBlock(status);
                    }
             
                };
 
                //SCNetworkReachabilityContext 这个结构体保存了用户的数据，以及SCNetworkReachabilitySetCallback回调的信息
                SCNetworkReachabilityContext context = {0, (__bridge void *)callback, AFNetworkReachabilityRetainCallback, AFNetworkReachabilityReleaseCallback, NULL};
 
                //只有SCNetworkReachabilitySetCallback设置了 上述SCNetworkReachabilityContext 结构体 ，才能生效
                SCNetworkReachabilitySetCallback(self.networkReachability, AFNetworkReachabilityCallback, &context);
 
                //SCNetworkReachabilityScheduleWithRunLoop 接收三个参数，创建的self.networkReachability，需要循环在哪个runloop上，以及runloop的模式，当网络状态发生变化时就会执行SCNetworkReachabilitySetCallback方法中的callout回调
                //也就是说，这里将创建的self.networkReachability 丢进去，在主线程上循环，runloop模式为 kCFRunLoopCommonModes
                SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
                // 异步
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                    //SCNetworkReachabilityFlags 状态标识
                    SCNetworkReachabilityFlags flags;
                    //SCNetworkReachabilityGetFlags 获取网络状态丢到 flags ，最后将网络状态callback
                    if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
                        AFPostReachabilityStatusChange(flags, callback);
                    }
                });
             }
        
 
 */

-(void)getNetStatus{
    
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
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //添加监听，网络活动发生变化时,会发送下方key（AFNetworkingReachabilityDidChangeNotification）的通知
    /*
     [[NSNotificationCenter defaultCenter] addObserver:nil selector:nil
     name:AFNetworkingReachabilityDidChangeNotification object:nil];
     */
    
}


@end
