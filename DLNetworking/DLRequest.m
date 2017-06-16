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


typedef NS_ENUM(NSUInteger, DLRequestMethod) {
    DLRequestMethodGet,
    DLRequestMethodPost,
    
};

@implementation DLRequestBatchResponse

@end

@interface DLRequestContext ()
@property (nonatomic, strong) id data;
@property (nonatomic, assign) BOOL stop;
@end

@implementation DLRequestContext

- (void)stopPropagate
{
    self.stop = YES;
}

- (void)setReturnValue:(id)data
{
    self.data = data;
}
@end


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

@end

@implementation DLRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessionManage = [DLNetworkManager manager].jsonManager;
        self.requestTimeOut = 10;
        self.useRequestSerialization = [DLNetworkManager manager].urlRequestSerialization;
    }
    return self;
}


- (void)requestNetwork
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]];
    urlRequest.timeoutInterval = self.requestTimeOut;
    if (self.requestMethod == DLRequestMethodGet) {
        urlRequest.HTTPMethod = @"get";
    } else if (self.requestMethod == DLRequestMethodPost) {
        urlRequest.HTTPMethod = @"Post";
    }
    
    if (self.requestHeaders) {
        [urlRequest setAllHTTPHeaderFields:self.requestHeaders];
    }

   self.task = [self.sessionManage dataTaskWithRequest:[self.useRequestSerialization requestBySerializingRequest:urlRequest withParameters:self.requestParameters error:nil] uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
       if (error) {
           [self responseWithData:error isError:YES];
       } else {
            [self responseWithData:responseObject isError:NO];
       }
    }];
    [self.task resume];
}


# pragma mark - method

- (DLRequest *(^)(NSString *))get {
    return ^(NSString *url) {
        self.requestUrl = url;
        self.requestMethod = DLRequestMethodGet;
        return self;
    };
}

- (DLRequest *(^)(NSString *))post {
    return ^(NSString *url) {
        self.requestUrl = url;
        self.requestMethod = DLRequestMethodPost;
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

+ (DLRequest *)sendBatchRequests:(NSArray<DLRequest *> *)requests
{
    NSMutableArray *responseArray = [NSMutableArray array];
    dispatch_group_t g = dispatch_group_create();
    DLRequest *request = DLRequest.new;
    [requests enumerateObjectsUsingBlock:^(DLRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DLRequestBatchResponse *response = [DLRequestBatchResponse new];
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
