//
//  DLNetworkConfig.h
//  DLNetworking
//
//  Created by famulei on 20/06/2017.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface DLNetworkConfig : NSObject

+ (DLNetworkConfig *)sharedInstance;
@property (nonatomic, assign) NSTimeInterval timeOut;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSDictionary *globalHeaders;
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@property (nonatomic, assign) BOOL enableLog;
@end
