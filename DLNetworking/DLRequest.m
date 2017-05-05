//
//  DLRequest.m
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import "DLRequest.h"
#import "AFNetworking.h"
#import <objc/runtime.h>
#import "DLNetworkManager.h"


typedef NS_ENUM(NSUInteger, DLRequestMethod) {
    DLRequestMethodGet,
    DLRequestMethodPost,
    
};



@interface __DLRequestBlock : NSObject
@property (nonatomic, copy) DLRequestBlock block;
@property (nonatomic, assign) BOOL isError;
@end

@implementation __DLRequestBlock

@end




@interface DLRequest ()
@property (nonatomic, assign) DLRequestMethod requestMethod;
@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic, strong) NSDictionary *requestParameters;
@property (nonatomic, strong) NSDictionary *requestHeaders;
@property (nonatomic, strong) NSMutableArray<__DLRequestBlock *> *blocks;


@end

@implementation DLRequest



- (void)requestNetwork
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]];
    urlRequest.timeoutInterval = [DLNetworkManager manager].timeoutInterval;
    if (self.requestMethod == DLRequestMethodGet) {
        urlRequest.HTTPMethod = @"get";
    } else if (self.requestMethod == DLRequestMethodPost) {
        urlRequest.HTTPMethod = @"Post";
    }
    
    if (self.requestHeaders) {
        [urlRequest setAllHTTPHeaderFields:self.requestHeaders];
    }

   NSURLSessionDataTask *dataTask = [[DLNetworkManager manager].afManager dataTaskWithRequest:[[DLNetworkManager manager].requestSerialization requestBySerializingRequest:urlRequest withParameters:self.requestParameters error:nil] uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
       if (error) {
           [self responseWithData:error isError:YES];
       } else {
            [self responseWithData:responseObject isError:NO];
       }
    }];
    [dataTask resume];
   self.taskID = dataTask.taskIdentifier;
}






# pragma mark - method
+ (instancetype)get
{
    DLRequest *request = [self new];
    request.requestMethod = DLRequestMethodGet;
    return request;
}


+ (instancetype)post
{
    DLRequest *request = [self new];
    request.requestMethod = DLRequestMethodPost;
    return request;
}

- (DLRequest *(^)(NSString *))url {
    return ^(NSString *url) {
        self.requestUrl = url;
        return self;
    };
}

- (DLRequest *(^)(NSDictionary *))parameters
{
    return ^(NSDictionary *parameters) {
        self.requestParameters = parameters;
        return self;
    };
}

- (DLRequest *(^)(NSDictionary *))headers
{
    return ^(NSDictionary *headers) {
        self.requestHeaders = headers;
        return self;
    };
}

#pragma mark - request
- (DLRequestVoidBlock)send
{
    return ^()
    {
        [self requestNetwork];
        return self;
    };
}

- (DLRequestBlock)thenBlock
{
    return ^(DLRequestHandleBlock block)
    {
        if (block) {
            __DLRequestBlock *_block = [__DLRequestBlock new];
            _block.block = block;
            [self.blocks addObject:_block];
        }
        return self;
    };
}

- (DLRequestBlock)errorBlock
{
    return ^(DLRequestHandleBlock block)
    {
        if (block) {
            
            __DLRequestBlock *_block = [__DLRequestBlock new];
            _block.block = block;
            _block.isError = YES;
            [self.blocks addObject:_block];
        }
        return self;
    };
}

- (void)responseWithData:(id)data isError:(BOOL)isError
{
    id returnValue = data;
    DLRequest *reqeust = nil;
    for (__DLRequestBlock *block in self.blocks) {
        
        if (reqeust == nil &&  [returnValue isKindOfClass:[DLRequest class]]) {
            // 是一个请求的
            reqeust = returnValue;
            if (block.isError) {
                reqeust.errorBlock(block.block);
            } else {
                reqeust.thenBlock(block.block);
            }
            
        }
        else if (reqeust) {
            if (block.isError) {
                reqeust.errorBlock(block.block);
            } else {
                reqeust.thenBlock(block.block);
            }
        }
        else {
            if (isError) {
                if (block.isError) {
                    returnValue = block.block(returnValue);
                } else {
                    continue;
                }
            } else {
                if (!block.isError) {
                    returnValue = block.block(returnValue);
                }
                else {
                    continue;
                }
            }
        }
    }
    if (reqeust) {
        reqeust.send();
    }
    
}


- (NSMutableArray *)blocks
{
    if (!_blocks) {
        _blocks = [NSMutableArray array];
    }
    return _blocks;
}


- (void)dealloc
{
    NSLog(@"delloc request");
}


@end
