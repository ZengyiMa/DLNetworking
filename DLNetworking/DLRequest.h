//
//  DLRequest.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>


@class DLRequest;


typedef NS_ENUM(NSUInteger, DLRequestSerializationType) {
    DLRequestSerializationTypeURL,
    DLRequestSerializationTypeJSON,
};

typedef NS_ENUM(NSUInteger, DLResponseSerializationType) {
    DLResponseSerializationTypeJSON,
    DLResponseSerializationTypeDATA,
};






@interface DLRequestBatchResponse : NSObject
@property (nonatomic, strong) DLRequest *request;
@property (nonatomic, strong) id data;
@property (nonatomic, assign) BOOL isFailure;

@end


// 返回的操作上下文
@interface DLRequestContext : NSObject
- (void)stopPropagate;
- (void)setReturnValue:(id)data;
@end





typedef DLRequest *(^DLRequestVoidBlock)(void);
typedef void (^DLRequestHandleBlock)(id data, DLRequestContext *context);
typedef DLRequest *(^DLRequestBlock)(DLRequestHandleBlock block);


@interface DLRequest : NSObject
@property (nonatomic, assign, readonly) NSUInteger taskIdentifier;

@property (nonatomic, copy, readonly) DLRequest *(^get)(NSString *url);
@property (nonatomic, copy, readonly) DLRequest *(^post)(NSString *url);
@property (nonatomic, copy, readonly) DLRequest *(^parameters)(id parameters);
@property (nonatomic, copy, readonly) DLRequest *(^headers)(NSDictionary *parameters);
@property (nonatomic, copy, readonly) DLRequest *(^timeOut)(NSTimeInterval timeOut);
@property (nonatomic, copy, readonly) DLRequest *(^requestSerialization)(DLRequestSerializationType type);
@property (nonatomic, copy, readonly) DLRequest *(^responseSerialization)(DLResponseSerializationType type);
@property (nonatomic, copy, readonly) void (^cancel)();

// 发起请求
- (DLRequestVoidBlock)sendRequest;


// promise
@property (nonatomic, copy, readonly) DLRequest *(^then)(void(^block)(id data, DLRequestContext *context));
@property (nonatomic, copy, readonly) DLRequest *(^failure)(void(^block)(id data, DLRequestContext *context));



// batch
+ (DLRequest *)sendBatchRequests:(NSArray<DLRequest *> *)requests;




@end
