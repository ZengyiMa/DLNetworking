//
//  DLNetworkManager.m
//  DLNetworking
//
//  Created by famulei on 05/05/2017.
//
//

#import "DLNetworkManager.h"

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
        self.timeoutInterval = 10;
    }
    return self;
}

- (AFURLSessionManager *)afManager
{
    if (!_afManager ) {
        _afManager = [[AFURLSessionManager alloc]init];
    }
    return _afManager;
}

- (id<AFURLRequestSerialization>)urlRequestSerialization
{
    if (!_urlRequestSerialization) {
        _urlRequestSerialization = [AFHTTPRequestSerializer serializer];
    }
    return _urlRequestSerialization;
}

- (id<AFURLRequestSerialization>)jsonRequestSerialization
{
    if (!_jsonRequestSerialization) {
        _jsonRequestSerialization = [AFJSONRequestSerializer serializer];
    }
    return _jsonRequestSerialization;
}


@end
