//
//  DLNetManager.h
//  DLNetworking
//
//  Created by famulei on 27/12/2016.
//
//

#import <Foundation/Foundation.h>
#import "DLRequest.h"





@interface DLNetManager : NSObject


+ (instancetype)manager;

- (void)addRequest:(DLRequest *)request;


@end
