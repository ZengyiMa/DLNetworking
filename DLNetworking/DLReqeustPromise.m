//
//  DLReqeustPromise.m
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import "DLReqeustPromise.h"

@implementation DLReqeustPromise

- (DLReqeustPromiseThenBlock)then
{
    return ^(DLReqeustPromiseHandleBlock fulfilled, DLReqeustPromiseHandleBlock rejected)
    {
        NSLog(@"then");
        return [DLReqeustPromise new];
    };
}


+ (DLReqeustPromiseHandleBlock)makeBlock:(DLReqeustPromiseHandleBlock)block
{
    return block;
}


@end
