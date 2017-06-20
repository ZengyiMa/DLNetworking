//
//  DLRequestBatchResponse.h
//  DLNetworking
//
//  Created by famulei on 20/06/2017.
//
//

#import <Foundation/Foundation.h>

@interface DLNetworkBatchResponse : NSObject
@property (nonatomic, strong) id data; /// 返回值
@property (nonatomic, assign) BOOL isFailure; /// 是否错误
@end
