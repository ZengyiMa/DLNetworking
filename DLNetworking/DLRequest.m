//
//  DLRequest.m
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import "DLRequest.h"


typedef NS_ENUM(NSUInteger, DLRequestMethod) {
    DLRequestMethodGet,
    DLRequestMethodPost,
};



@interface DLRequest ()

@property (nonatomic, assign) DLRequestMethod method;
@property (nonatomic, strong) NSString *requestUrl;

@property (nonatomic, strong) id requestParameters;


@end

@implementation DLRequest


- (DLRequestSendBlock)send
{
    return ^()
    {
       AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        if (self.method == DLRequestMethodGet) {
            [manager GET:self.requestUrl parameters:self.requestParameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"done");
            } failure:nil];
        }
        return [DLReqeustPromise new];
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


- (DLRequestVoidBlock)get
{
    return ^()
    {
        self.method = DLRequestMethodGet;
        return self;
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


- (DLRequestVoidBlock)post
{
    return ^()
    {
        self.method = DLRequestMethodPost;
        return self;
    };
}


+ (DLRequestVoidBlock)start
{
    return ^()
    {
        return [DLRequest new];
    };
}


@end
