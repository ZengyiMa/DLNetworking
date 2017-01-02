//
//  DLRequest.m
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import "DLRequest.h"
#import "DLNetManager.h"


typedef NS_ENUM(NSUInteger, DLRequestMethod) {
    DLRequestMethodGet,
    DLRequestMethodPost,
};

@interface DLRequest ()
@property (nonatomic, assign) DLRequestMethod method;
@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic, strong) id requestParameters;
@property (nonatomic, strong) NSDictionary *requestHeader;
@end

@implementation DLRequest


- (DLRequestSendBlock)send
{
    return ^()
    {
       AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSURLSessionTask *task = nil;
        if (self.method == DLRequestMethodGet) {
           task = [manager GET:self.requestUrl parameters:self.requestParameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
               [self.promise changeState:DLReqeustPromiseStateFulfilled withValue:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self.promise changeState:DLReqeustPromiseStateRejected withValue:error];
            }];
        }
        self.taskID = task.taskIdentifier;
        
        self.promise = [DLReqeustPromise new];
        return self.promise;
    };
}

- (DLRequestURLBlock)url
{
    return ^(NSString *requestUrl)
    {
        self.requestUrl = requestUrl;
        return self;
    };
}


+ (DLRequestVoidBlock)get
{
    return ^()
    {
        DLRequest *request = [self new];
        request.method = DLRequestMethodGet;
        return request;
    };
}

- (DLRequestIdBlock)parameters
{
    return ^(NSString *requestParameters)
    {
        self.requestParameters = requestParameters;
        return self;
    };
}

- (DLRequestHeaderBlock)header
{
    return ^(NSDictionary *header)
    {
        self.requestHeader = header;
        return self;
    };
}



+ (DLRequestVoidBlock)post
{
    return ^()
    {
        DLRequest *request = [self new];
        request.method = DLRequestMethodPost;
        return request;
    };
}




- (void)dealloc
{
    NSLog(@"delloc request");
}


@end
