//
//  DLResponse.h
//  DLNetworking
//
//  Created by Damien on 12/04/2017.
//
//

#import <Foundation/Foundation.h>
#import "DLRequest.h";

@class DLRequest;
@class DLResponse;


typedef id (^DLResponseHandleBlock)(id data);
typedef DLResponse *(^DLResponseBlock)(DLResponseHandleBlock block);

@interface DLResponse : NSObject

- (DLResponseBlock)then;
- (DLResponseBlock)error;



- (void)responseThenWithData:(id )data;
- (void)responseErrorWithData:(id )data;

@end
