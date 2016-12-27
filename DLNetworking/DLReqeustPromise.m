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
        self.onFulfilled = fulfilled;
        self.onRejected = rejected;
        return [DLReqeustPromise new];
    };
}

- (void)setState:(DLReqeustPromiseState)state
{
    _state = state;
    if (_state == DLReqeustPromiseStateRejected) {
        if (self.onRejected) {
            self.onRejected(self.value);
        }
    }
    else if (_state == DLReqeustPromiseStateFulfilled)
    {
        if (self.onFulfilled) {
            self.onFulfilled(self.value);
        }
    }
}


+ (DLReqeustPromiseHandleBlock)makeBlock:(DLReqeustPromiseHandleBlock)block
{
    return block;
}


@end
