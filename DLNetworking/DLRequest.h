//
//  DLRequest.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>

#import "DLNetworking.h"


@class DLRequest;
@class DLRequestContext;


typedef DLRequest *(^DLRequestVoidBlock)(void);
typedef void (^DLRequestHandleBlock)(id data, DLRequestContext *context);
typedef DLRequest *(^DLRequestBlock)(DLRequestHandleBlock block);

/// 请求序列化的类型
typedef NS_ENUM(NSUInteger, DLRequestSerializationType) {
    DLRequestSerializationTypeURL, /// 正常的初始化。
    DLRequestSerializationTypeJSON, /// 转换成 json 请求
};

/// 回应的序列化类型
typedef NS_ENUM(NSUInteger, DLResponseSerializationType) {
    DLResponseSerializationTypeJSON, /// 转化成 json 格式
    DLResponseSerializationTypeDATA, /// 原始的 data 格式
};

/// 请求对象
@interface DLRequest : NSObject

/// 请求网络对象的唯一标识
@property (nonatomic, assign, readonly) NSUInteger taskIdentifier;

/// 使用 get 方式
@property (nonatomic, copy, readonly) DLRequest *(^get)(NSString *url);

/// 使用 post 方式
@property (nonatomic, copy, readonly) DLRequest *(^post)(NSString *url);

/// 下载方法
@property (nonatomic, copy, readonly) DLRequest *(^download)(NSString *url, NSString *destination);

@property (nonatomic, copy, readonly) DLRequest *(^uploadFile)(NSString *fileUrl, NSString *toUrl);


/// 下载进度的回调
@property (nonatomic, copy, readonly) DLRequest *(^progress)(void (^block)(NSProgress *downloadProgress));

/// 上传进度
@property (nonatomic, copy, readonly) DLRequest *(^uploadProgress)(void (^block)(NSProgress *progress));


// 传递的参数
@property (nonatomic, copy, readonly) DLRequest *(^parameters)(id parameters);
/// 添加请求头
@property (nonatomic, copy, readonly) DLRequest *(^headers)(NSDictionary *parameters);
/// 超时时间
@property (nonatomic, copy, readonly) DLRequest *(^timeOut)(NSTimeInterval timeOut);
@property (nonatomic, copy, readonly) DLRequest *(^requestSerialization)(DLRequestSerializationType type);
@property (nonatomic, copy, readonly) DLRequest *(^responseSerialization)(DLResponseSerializationType type);
@property (nonatomic, copy, readonly) void (^cancel)();

/// 会在开始前被调用
@property (nonatomic, copy) DLRequest *(^willStartRequest)(void(^block)());

/// 会在结束的时候调用
@property (nonatomic, copy) DLRequest *(^didFinishedRequest)(void(^block)());


// 发起请求
- (DLRequestVoidBlock)sendRequest;


#pragma mark - promise
/// 成功的回调
@property (nonatomic, copy, readonly) DLRequest *(^then)(void(^block)(id data, DLRequestContext *context));

/// 失败的回调
@property (nonatomic, copy, readonly) DLRequest *(^failure)(void(^block)(id data, DLRequestContext *context));



// batch
+ (DLRequest *)sendBatchRequests:(NSArray<DLRequest *> *)requests;




@end
