//
//  DLRequest.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>

@class DLRequest;

typedef DLRequest *(^DLRequestVoidBlock)(void);
typedef DLRequest *(^DLRequestIdBlock)(id object);
typedef DLRequest *(^DLRequestStringBlock)(NSString *string);
typedef DLRequest *(^DLRequestDictionaryBlock)(NSDictionary *dict);
typedef DLRequest *(^DLRequestVoidBlock)(void);

typedef id (^DLRequestHandleBlock)(id data);
typedef DLRequest *(^DLRequestBlock)(DLRequestHandleBlock block);


@interface DLRequest : NSObject
@property (nonatomic, assign) NSUInteger taskID;

// 请求方法
+ (DLRequestStringBlock)get;
+ (DLRequestStringBlock)post;

// 参数
- (DLRequestDictionaryBlock)parameters;



// 发起请求
- (DLRequestVoidBlock)send;




// promise
- (DLRequestBlock)then;
- (DLRequestBlock)error;







@end
