//
//  DLRequest.m
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import "DLRequest.h"
#import "AFHTTPSessionManager.h"
#import <objc/runtime.h>


typedef NS_ENUM(NSUInteger, DLRequestMethod) {
    DLRequestMethodGet,
    DLRequestMethodPost,
    
};

@interface DLRequest ()
@property (nonatomic, assign) DLRequestMethod requestMethod;
@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic, strong) id requestParameters;
@property (nonatomic, strong) NSDictionary *requestHeader;

@property (nonatomic, strong) DLResponse *response;

@end

@implementation DLRequest


- (void)requestNetwork
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionTask *task = nil;
    if (self.requestMethod == DLRequestMethodGet) {
        task = [manager GET:self.requestUrl parameters:self.requestParameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self.response responseThenWithData:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        }];
    }
    self.taskID = task.taskIdentifier;
}



# pragma mark - method
+ (DLRequestStringBlock)get
{
    return ^(NSString *url)
    {
        DLRequest *request = [self new];
        request.response = [DLResponse new];
        request.requestUrl = url;
        request.requestMethod = DLRequestMethodGet;
        return request;
    };
}


+ (DLRequestStringBlock)post
{
    return ^(NSString *url)
    {
        DLRequest *request = [self new];
        request.response = [DLResponse new];
        request.requestUrl = url;
        request.requestMethod = DLRequestMethodPost;
        return request;
    };
}

#pragma mark - request
- (DLResponseVoidBlock)send
{
    return ^()
    {
        
        [self requestNetwork];
        
        return self.response;
    };
}


- (void)dealloc
{
    NSLog(@"delloc request");
}


@end
