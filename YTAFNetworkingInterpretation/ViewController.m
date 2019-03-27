//
//  ViewController.m
//  YTAFNetworkingInterpretation
//
//  Created by july on 2019/3/27.
//  Copyright © 2019 july. All rights reserved.
//

/*
    这个项目只是想要去了解下AF框架的原理
    在了解af之前，先了解原生的请求方式会好理解点
 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self NSURLSessionGet1];
}

/*
    网络请求包括两种：1.NSURLSession 2.NSURLConnection
    苹果在ios9.0之后 推荐使用NSURLSession来替换NSURLConnection
 
 */

#pragma mark NSURLSession 的 get请求  简单了解下
-(void)NSURLSessionGet1{
    
    //1.请求路径  该路径是api工厂开放的公共的获取城市列表接口
    /*
     注意：若请求链接有中文字符是需要转码的，在ios9.0之前使用stringByAddingPercentEscapesUsingEncoding方式转码，之后使用stringByAddingPercentEncodingWithAllowedCharacters
        NSString *urlString = @"https://api.it120.cc/common/region/province";
        //ios9.0之前
        NSString *codSting1 = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //ios9.0之后
        NSString *codSting2 = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
     
        NSURL *url2 = [NSURL URLWithString:codSting2];
     */
    NSURL *url = [NSURL URLWithString:@"https://api.it120.cc/common/region/province"];

    
    //2.创建请求对象，请求对象内部默认已经包含了请求头和请求方法（GET）,参数 1.URL是请求链接 2.cachePolicy 缓存的策略 3.是超时时间
    //当然也可以省略策略和时间，默认策略是使用协议的缓存策略使用i协议的缓存策略 NSURLRequestUseProtocolCachePolicy 超时时间：60秒
    // NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:30];


    //3.获得会话对象 注意点：NSURLSession是一个全局的单例，这就意味着这个NSURLSession不能监控，我们要对session这个实例添加代理，使用它的代理方法进行网络监控
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    //4.根据会话对象创建一个Task(发送请求），NSURLSessionDataTask是NSURLSessionTask这个抽象类的子类，NSURLSessionTask是支持任务的暂停，取消和恢复的；默认任务运行在非主线程中
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            //6.解析服务器返回的数据
            //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSLog(@"%@",dict);
        }
    }];
    
    //5.执行任务
    [dataTask resume];
    
}

#pragma mark NSURLSessionGet2 去掉注释的版本的 NSURLSessionGet1
-(void)NSURLSessionGet2{
    
    NSURL *url = [NSURL URLWithString:@"https://api.it120.cc/common/region/province"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:30];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",dict);
        }
    }];

    [dataTask resume];
}



#pragma mark NSURLSessionGet3 同样是get请求 NSURLSessionDataTask 的 dataTaskWithURL 没有使用NSURLRequest
-(void)NSURLSessionGet3{
    
    NSURL *url = [NSURL URLWithString:@"https://api.it120.cc/common/region/province"];
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        
    }];
    [dataTask resume];

}

#pragma mark 文件下载
- (void)NSURLSessionDownloadTaskTest {
    
    // 1.创建url
    NSString *urlString = [NSString stringWithFormat:@"http://localhost/aaa.text"];
    // 2.创建请求
    NSURL *url = [NSURL URLWithString:urlString];
     // 3.创建会话，采用苹果提供全局的共享session
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 4.创建任务
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    // 5.使用NSURLSessionDownloadTask ，NSURLSessionTask的一个子类
    NSURLSessionDownloadTask *downloadTask = [sharedSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) { if (error == nil) {

        // location:下载任务完成之后,文件存储的位置，默认在tmp临时文件夹下，所以需要另存
            NSLog(@"location:%@",location.path);
        
            NSString *filePath = @"/Users/userName/Desktop/aaa.text";
            NSError *fileError;
            //NSFileManager使用这个文件管理 将文件路径cpcpoy到我们指定文件路径下
            [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:filePath error:&fileError]; if (fileError == nil) {
                NSLog(@"保存成功");
            }else{
                NSLog(@"保存错错误 error: %@",fileError);
            }
        } else {
            NSLog(@"下载错误 error:%@",error);
        }
    }];
    
    // 6.开启任务
    [downloadTask resume];
}

#pragma mark 文件上传
- (void) NSURLSessionBinaryUploadTaskTest {
    
    // 1.创建url  PHP是最好的语言！
    NSString *urlString = @"http://localhost/upload.php";
    NSURL *url = [NSURL URLWithString:urlString];
    // 2.创建请求。这个 NSMutableURLRequest 是  NSURLRequest 子类，可以根据需求设置：超时时间，请求方式，请求体，请求头
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 请求方式使用post 上传文件属于‘增’ get无法使用，增删改都用不了get
    request.HTTPMethod = @"POST";
    
    // 3.开始上传   request的body data将被忽略，由fromData提供
    [[[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:[NSData dataWithContentsOfFile:@"路径/aaa.jpg"]     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) { if (error == nil) {
        NSLog(@"upload success：%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    } else {
        NSLog(@"upload error:%@",error);
    }
    }] resume];
}



@end
