//
//  DLRequest.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>
#import "DLResponse.h"

@class DLRequest;
@class DLResponse;

typedef DLRequest *(^DLRequestVoidBlock)(void);
typedef DLRequest *(^DLRequestIdBlock)(id object);
typedef DLRequest *(^DLRequestStringBlock)(NSString *string);
typedef DLRequest *(^DLRequestDictionaryBlock)(NSDictionary *dict);
typedef DLResponse *(^DLResponseVoidBlock)(void);



@interface DLRequest : NSObject

@property (nonatomic, assign) NSUInteger taskID;
@property (nonatomic, strong, readonly) DLResponse *response;

// 发起请求
+ (DLRequestStringBlock)get;
+ (DLRequestStringBlock)post;

// 参数

// 发起请求
- (DLResponseVoidBlock)send;


// promise







@end
