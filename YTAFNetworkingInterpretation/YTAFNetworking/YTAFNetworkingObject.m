//
//  YTAFNetworkingObject.m
//  YTAFNetworkingInterpretation
//
//  Created by july on 2019/3/28.
//  Copyright © 2019 july. All rights reserved.
//

#import "YTAFNetworkingObject.h"

@implementation YTAFNetworkingObject

#pragma mark 单例维护一个管理者
/*
    值得注意的是：使用单例模式没毛病，在特殊时候需要用到非单例模式的时候要注意内存泄露问题，AFHTTPSessionManager 的父类 AFURLSessionManager，实现了NSURLSessionDelegate协议，而该协议是retain的
    仔细看AFURLSessionManager，会发现这么一个方法invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks用于取消挂起的任务，
    适当的时候（比如dealloc）使用[self.manager invalidateSessionCancelingTasks:YES]; 可以有效解决上述问题
    
    1. 我们所有的请求都是由这个管理者（AFHTTPSessionManager）发起的
    2. 默认提交请求的数据是二进制的,返回格式是JSON
 */

+ (AFHTTPSessionManager *)sharedAFManager {
    
    static AFHTTPSessionManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [AFHTTPSessionManager manager];

        /*
            请求格式
            格式有：AFHTTPRequestSerializer（二进制格式），AFJSONRequestSerializer（json格式），AFPropertyListRequestSerializer（pList格式）
            默认是：AFHTTPRequestSerializer格式
         
         */
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        /*
            响应格式
            格式有：AFHTTPResponseSerializer（二进制），AFJSONResponseSerializer（json），AFXMLParserResponseSerializer（XML）,AFXMLDocumentResponseSerializer（mac os XML）,AFPropertyListResponseSerializer（plist），AFImageResponseSerializer（image），AFCompoundResponseSerializer（组合）
            默认格式是：AFJSONResponseSerializer
         */
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        //超时时间设置，手动触发kvo
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 20.0f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"text/html", @"application/json", @"text/json",
         @"text/javascript", @"text/plain", nil];
    });
    return manager;
}


-(void)AFNetworkingGet{
    
}

@end


