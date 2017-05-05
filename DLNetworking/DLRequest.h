//
//  DLRequest.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>

@class DLRequest;



#define then(code)               \
thenBlock(^id(id data) {         \
   id returnValue = nil;         \
   code                          \
return returnValue;              \
})                               \

#define error(code)               \
errorBlock(^id(id data) {         \
id returnValue = nil;            \
code                             \
return returnValue;              \
})                               \






typedef DLRequest *(^DLRequestVoidBlock)(void);

typedef id (^DLRequestHandleBlock)(id data);
typedef DLRequest *(^DLRequestBlock)(DLRequestHandleBlock block);


@interface DLRequest : NSObject
@property (nonatomic, assign) NSUInteger taskID;

@property (nonatomic, copy, readonly) DLRequest *(^url)(NSString *url);
@property (nonatomic, copy, readonly) DLRequest *(^parameters)(NSDictionary *parameters);
@property (nonatomic, copy, readonly) DLRequest *(^headers)(NSDictionary *parameters);


// 请求方法
+ (instancetype)get;
+ (instancetype)post;

// 发起请求
- (DLRequestVoidBlock)send;




// promise
- (DLRequestBlock)thenBlock;
- (DLRequestBlock)errorBlock;







@end
