//
//  DLNetworkConfig.m
//  DLNetworking
//
//  Created by famulei on 20/06/2017.
//
//

#import "DLNetworkConfig.h"

@implementation DLNetworkConfig

+ (DLNetworkConfig *)sharedInstance
{
    static DLNetworkConfig *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [self new];
    });
    return config;
}

@end
