//
//  DLRequest.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSUInteger, DLRequestSerializationType) {
    DLRequestSerializationTypeURL,
    DLRequestSerializationTypeJSON,
};

typedef NS_ENUM(NSUInteger, DLResponseSerializationType) {
    DLResponseSerializationTypeJSON,
    DLResponseSerializationTypeDATA,
};




@class DLRequest;
typedef DLRequest *(^DLRequestVoidBlock)(void);
typedef void (^DLRequestHandleBlock)(id data, id *returnValue);
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
@property (nonatomic, copy, readonly) DLRequest *(^then)(void(^block)(id data, id *returnValue));
@property (nonatomic, copy, readonly) DLRequest *(^failure)(void(^block)(id data, id *returnValue));







@end
