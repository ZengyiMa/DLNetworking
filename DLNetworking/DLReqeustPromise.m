//
//  DLReqeustPromise.m
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import "DLReqeustPromise.h"

@interface DLReqeustPromise ()
@end

@implementation DLReqeustPromise

- (DLReqeustPromiseThenBlock)then
{
    return ^(DLReqeustPromiseHandleBlock fulfilled, DLReqeustPromiseHandleBlock rejected)
    {
        self.onFulfilled = fulfilled;
        self.onRejected = rejected;
        self.promise = [DLReqeustPromise new];
        return self.promise;
    };
}



- (void)changeState:(DLReqeustPromiseState)state withValue:(id)value
{
    self.state = state;
    id returnValue = nil;
    if (_state == DLReqeustPromiseStateRejected) {
        if (self.onRejected) {
           returnValue = self.onRejected(value);
        }
    }
    else if (_state == DLReqeustPromiseStateFulfilled)
    {
        if (self.onFulfilled) {
            returnValue = self.onFulfilled(value);
        }
    }
    
    if ([returnValue isKindOfClass:[DLReqeustPromise class]]) {
        DLReqeustPromise *promise = returnValue;
        promise.promise = self.promise.promise;
        promise.onFulfilled = self.promise.onFulfilled;
        promise.onRejected = self.promise.onRejected;
        return;
    }
    else
    {
        if (self.promise) {
            [self.promise changeState:self.state withValue:returnValue];
        }
    }
}


+ (DLReqeustPromiseHandleBlock)makeBlock:(DLReqeustPromiseHandleBlock)block
{
    return block;
}

- (void)dealloc
{
    NSLog(@"promise delloc");
}


@end
