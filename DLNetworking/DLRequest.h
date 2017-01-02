//
//  DLRequest.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "DLPromise.h"

@class DLRequest;

typedef DLRequest *(^DLRequestVoidBlock)(void);
typedef DLRequest *(^DLRequestIdBlock)(id object);
typedef DLRequest *(^DLRequestURLBlock)(NSString *url);
typedef DLRequest *(^DLRequestHeaderBlock)(NSDictionary *headers);

typedef DLPromise *(^DLRequestSendBlock)(void);


@interface DLRequest : NSObject

@property (nonatomic, assign) NSUInteger taskID;
@property (nonatomic, strong) DLPromise *promise;


+ (DLRequestVoidBlock)get;
+ (DLRequestVoidBlock)post;


- (DLRequestIdBlock)parameters;
- (DLRequestURLBlock)url;
- (DLRequestHeaderBlock)header;

- (DLRequestSendBlock)send;



@end
