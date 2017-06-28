//
//  DLRequest.m
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import "DLRequest.h"
#import <objc/runtime.h>


typedef NS_ENUM(NSUInteger, DLRequestMethod) {
    DLRequestMethodGet,
    DLRequestMethodPost,
    
};


typedef NS_ENUM(NSUInteger, DLRequestType) {
    DLRequestTypeNormal,
    DLRequestTypeDownload,
    DLRequestTypeUploadFile,
    DLRequestTypeUploadData,
    DLRequestTypeUploadBlock,
};





#pragma mark - manager
@interface DLNetworkManager : NSObject
@property (nonatomic, strong) AFURLSessionManager *httpManager;
@property (nonatomic, strong) AFURLSessionManager *jsonManager;
@property (nonatomic, strong) id<AFURLRequestSerialization> urlRequestSerialization;
@property (nonatomic, strong) id<AFURLRequestSerialization> jsonRequestSerialization;
+ (instancetype)manager;

@end
@implementation DLNetworkManager


+ (instancetype)manager
{
    static DLNetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (AFURLSessionManager *)httpManager
{
    if (!_httpManager ) {
        _httpManager = [[AFURLSessionManager alloc]init];
        [_httpManager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    }
    return _httpManager;
}

- (AFURLSessionManager *)jsonManager
{
    if (!_jsonManager) {
        _jsonManager = [[AFURLSessionManager alloc]init];
    }
    return _jsonManager;
}

- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)urlRequestSerialization
{
    if (!_urlRequestSerialization) {
        _urlRequestSerialization = [AFHTTPRequestSerializer serializer];
    }
    return _urlRequestSerialization;
}

- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)jsonRequestSerialization
{
    if (!_jsonRequestSerialization) {
        _jsonRequestSerialization = [AFJSONRequestSerializer serializer];
    }
    return _jsonRequestSerialization;
}


@end


@interface __DLRequestBlock : NSObject
@property (nonatomic, copy) DLRequestHandleBlock block;
@property (nonatomic, assign) BOOL isError;
@end
@implementation __DLRequestBlock
@end




@interface DLRequest ()
@property (nonatomic, strong) AFURLSessionManager *sessionManage;
@property (nonatomic, weak) NSURLSessionTask *task;
@property (nonatomic, assign) DLRequestMethod requestMethod;
@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic, strong) id requestParameters;
@property (nonatomic, strong) NSDictionary *requestHeaders;
@property (nonatomic, strong) NSMutableArray<__DLRequestBlock *> *blocks;
@property (nonatomic, strong) AFHTTPRequestSerializer<AFURLRequestSerialization> *useRequestSerialization;
@property (nonatomic, assign) NSTimeInterval requestTimeOut;

@property (nonatomic, assign) DLRequestType requestType;

@property (nonatomic, copy) NSString *dowloadDestination;

@property (nonatomic, copy) void (^willStartBlock)();
@property (nonatomic, copy) void (^didFinishedBlock)();
@property (nonatomic, copy) void (^progressBlock)(NSProgress *progress);
@property (nonatomic, copy) void (^uploadprogressBlock)(NSProgress *progress);

// upload
@property (nonatomic, strong) id uploadUseData;

// part
@property (nonatomic, copy) void (^multipartFormDataBlock)();

@property (nonatomic, assign) BOOL isAbsoluteUrl;

@end

@implementation DLRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessionManage = [DLNetworkManager manager].jsonManager;
        self.requestTimeOut = [DLNetworkConfig sharedInstance].timeOut;
        self.useRequestSerialization = [DLNetworkManager manager].urlRequestSerialization;
    }
    return self;
}


- (void)requestNetwork
{
    
    if (self.willStartBlock) {
        self.willStartBlock();
    }
    
   self.task = [self sessionTaskWithCompletionHandler:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
       if (error) {
           [self responseWithData:error isError:YES];
       } else {
           [self responseWithData:responseObject isError:NO];
       }
   }];
    [self.task resume];
}


- (NSURLSessionTask *)sessionTaskWithCompletionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler
{
    NSURLSessionTask *sessionTask = nil;
    self.sessionManage.securityPolicy = [DLNetworkConfig sharedInstance].securityPolicy;
    switch (self.requestType) {
        case DLRequestTypeNormal:
        {
             sessionTask = [self.sessionManage dataTaskWithRequest:[self urlRequest] uploadProgress:self.uploadprogressBlock downloadProgress:self.progressBlock completionHandler:completionHandler];
        }
           
            break;
        case DLRequestTypeDownload:
        {
            sessionTask = [self.sessionManage downloadTaskWithRequest:[self urlRequest] progress:self.progressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [NSURL fileURLWithPath:self.dowloadDestination];
            } completionHandler:completionHandler];
        }
            break;
        case DLRequestTypeUploadData:
        {
            sessionTask = [self.sessionManage uploadTaskWithRequest:[self urlRequest] fromData:self.uploadUseData progress:self.uploadprogressBlock completionHandler:completionHandler];
        }
            break;
        case DLRequestTypeUploadFile:
        {
            sessionTask = [self.sessionManage uploadTaskWithRequest:[self urlRequest] fromFile:[NSURL fileURLWithPath:self.uploadUseData] progress:self.uploadprogressBlock completionHandler:completionHandler];
        }
                       break;
        case DLRequestTypeUploadBlock:
            break;
        default:
            break;
    }
    return sessionTask;
}

- (NSURLRequest *)urlRequest
{
    NSMutableURLRequest *request = nil;
    
    if (!self.isAbsoluteUrl && [DLNetworkConfig sharedInstance].baseUrl) {
        self.requestUrl = [self.requestUrl stringByAppendingString:[DLNetworkConfig sharedInstance].baseUrl];
    }
    
    
    if (self.multipartFormDataBlock) {
        request = [self.useRequestSerialization multipartFormRequestWithMethod:@"post" URLString:self.requestUrl parameters:self.requestParameters constructingBodyWithBlock:self.multipartFormDataBlock error:nil];
        [self setupUrlRequest:request];
        return request;
    } else {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]];
    }
    
    if (self.requestMethod == DLRequestMethodGet) {
        request.HTTPMethod = @"get";
    } else if (self.requestMethod == DLRequestMethodPost) {
        request.HTTPMethod = @"Post";
    }
    [self setupUrlRequest:request];
    return [self.useRequestSerialization requestBySerializingRequest:request withParameters:self.requestParameters error:nil];
}

- (NSMutableURLRequest *)setupUrlRequest:(NSMutableURLRequest *)urlRequest
{
    urlRequest.timeoutInterval = self.requestTimeOut;
    if (self.requestHeaders) {
        [urlRequest setAllHTTPHeaderFields:self.requestHeaders];
        if ([DLNetworkConfig sharedInstance].globalHeaders) {
            [urlRequest setAllHTTPHeaderFields:[DLNetworkConfig sharedInstance].globalHeaders];
        }
    }
    return urlRequest;
}

# pragma mark - method

- (DLRequest *(^)(NSString *))get {
    return ^(NSString *url) {
        self.requestUrl = url;
        self.requestMethod = DLRequestMethodGet;
        self.requestType = DLRequestTypeNormal;
        return self;
    };
}

- (DLRequest *(^)(NSString *))post {
    return ^(NSString *url) {
        self.requestUrl = url;
        self.requestMethod = DLRequestMethodPost;
        self.requestType = DLRequestTypeNormal;

        return self;
    };
}

- (DLRequest *(^)(NSString *, NSString *))download {
    return ^(NSString *url, NSString *destination) {
        self.requestUrl = url;
        self.dowloadDestination = destination;
        self.requestType = DLRequestTypeDownload;

        return self;
    };
}

- (DLRequest *(^)(NSString *, NSString *))uploadFile
{
    return ^(NSString *fileUrl, NSString *url) {
        self.requestUrl = url;
        self.requestMethod = DLRequestMethodPost;
        self.uploadUseData = fileUrl;
        self.requestType = DLRequestTypeUploadFile;
        return self;
    };
}

- (DLRequest *(^)(NSData *, NSString *))uploadData
{
    return ^(NSData *data, NSString *url) {
        self.requestUrl = url;
        self.requestMethod = DLRequestMethodPost;
        self.uploadUseData = data;
        self.requestType = DLRequestTypeUploadData;
        return self;
    };
}

- (DLRequest *(^)(id))parameters
{
    return ^(id parameters) {
        self.requestParameters = parameters;
        return self;
    };
}

- (DLRequest *(^)(void (^)(id<AFMultipartFormData>)))multipartFormData
{
    return ^(void(^block)(id<AFMultipartFormData>)){
        self.multipartFormDataBlock = block;
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

- (DLRequest *(^)(NSTimeInterval))timeOut
{
    return ^(NSTimeInterval timeOut) {
        self.requestTimeOut = timeOut;
        return self;
    };
}

- (DLRequest *(^)(DLRequestSerializationType))requestSerialization
{
    return ^(DLRequestSerializationType type) {
        if (type == DLRequestSerializationTypeURL) {
            self.useRequestSerialization = [DLNetworkManager manager].urlRequestSerialization;
        } else {
            self.useRequestSerialization = [DLNetworkManager manager].jsonRequestSerialization;
        }
        return self;
    };
}

- (DLRequest *(^)(DLResponseSerializationType))responseSerialization
{
    return ^(DLResponseSerializationType type) {
        if (type == DLResponseSerializationTypeDATA) {
            self.sessionManage = [DLNetworkManager manager].httpManager;
        } else if (type == DLResponseSerializationTypeJSON){
            self.sessionManage = [DLNetworkManager manager].jsonManager;
        }
        return self;
    };
}

- (NSUInteger)taskIdentifier
{
    return self.task.taskIdentifier;
}

- (void (^)())cancel
{
    return ^() {
        [self.task cancel];
    };
}

- (DLRequest *(^)())absoluteUrl
{
    return ^() {
        
        return self;
    };
}

+ (DLRequest *)sendBatchRequests:(NSArray<DLRequest *> *)requests
{
    NSMutableArray *responseArray = [NSMutableArray array];
    dispatch_group_t g = dispatch_group_create();
    DLRequest *request = DLRequest.new;
    [requests enumerateObjectsUsingBlock:^(DLRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DLNetworkBatchResponse *response = [DLNetworkBatchResponse new];
        [responseArray addObject:response];
        dispatch_group_enter(g);
        obj.sendRequest().then(^(id data, DLRequestContext *context) {
            response.data = data;
            dispatch_group_leave(g);
        })
        .failure(^(id data, DLRequestContext *context) {
            response.isFailure = YES;
            response.data = data;
            dispatch_group_leave(g);
        });
    }];
    dispatch_group_notify(g, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [request responseWithData:responseArray isError:NO];
    });
    return request;
}

#pragma mark - request
- (DLRequestVoidBlock)sendRequest
{
    return ^()
    {
        [self requestNetwork];
        return self;
    };
}

- (DLRequest *(^)(void (^)()))willStartRequest
{
    return ^(void(^block)()) {
        self.willStartBlock = block;
        return self;
    };
}

- (DLRequest *(^)(void (^)()))didFinishedRequest
{
    return ^(void(^block)()) {
        self.didFinishedBlock = block;
        return self;
    };
}

- (DLRequest *(^)(void (^)(NSProgress *)))progress
{
    return ^(void(^block)(NSProgress *)) {
        self.progressBlock = block;
        return self;
    };
}

- (DLRequest *(^)(void (^)(NSProgress *)))uploadProgress
{
    return ^(void(^block)(NSProgress *)) {
        self.uploadprogressBlock  = block;
        return self;
    };
}

- (DLRequestBlock)then
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

- (DLRequestBlock)failure
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
    
    __weak DLRequest *weakReq = self;
    if (self.didFinishedBlock) {
        if (isError) {
            self.failure(^(id data, DLRequestContext *context) {
                
                weakReq.didFinishedBlock();
            });
        } else {
           self.then(^(id data, DLRequestContext *context) {
               weakReq.didFinishedBlock();
           });
        }
    }
    
    for (__DLRequestBlock *block in self.blocks) {
        if (reqeust == nil &&  [returnValue isKindOfClass:[DLRequest class]]) {
            // 是一个请求的
            reqeust = returnValue;
            if (block.isError) {
                reqeust.failure(block.block);
            } else {
                reqeust.then(block.block);
            }
        }
        else if (reqeust) {
            if (block.isError) {
                reqeust.failure(block.block);
            } else {
                reqeust.then(block.block);
            }
        }
        else {
            if (isError) {
                if (block.isError) {
                    DLRequestContext *context = [DLRequestContext new];
                    block.block(returnValue, context);
                    if (context.stop) {
                        break;
                    }
                    returnValue = context.data == nil ? returnValue: context.data;
                } else {
                    continue;
                }
            } else {
                if (!block.isError) {
                    DLRequestContext *context = [DLRequestContext new];
                    block.block(returnValue, context);
                    if (context.stop) {
                        break;
                    }
                    returnValue = context.data == nil ? returnValue: context.data;
                }
                else {
                    continue;
                }
            }
        }
    }
    if (reqeust) {
        reqeust.sendRequest();
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
