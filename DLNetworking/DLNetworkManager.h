//
//  DLNetworkManager.h
//  DLNetworking
//
//  Created by famulei on 05/05/2017.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface DLNetworkManager : NSObject

@property (nonatomic, assign) NSUInteger timeoutInterval;
@property (nonatomic, strong) AFURLSessionManager *afManager;


@property (nonatomic, strong) id<AFURLRequestSerialization> urlRequestSerialization;
@property (nonatomic, strong) id<AFURLRequestSerialization> jsonRequestSerialization;

+ (instancetype)manager;



@end
