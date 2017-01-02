//
//  DLReqeustPromise.m
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import "DLPromise.h"

@interface DLPromise ()
@end

@implementation DLPromise

- (DLPromiseThenBlock)then
{
    return ^(DLPromiseHandleBlock fulfilled, DLPromiseHandleBlock rejected)
    {
        self.onFulfilled = fulfilled;
        self.onRejected = rejected;
        self.promise = [DLPromise new];
        return self.promise;
    };
}


- (DLPromiseSingleBlock)failed
{
    return ^(DLPromiseHandleBlock block)
    {
        self.onFulfilled = nil;
        self.onRejected = block;
        self.promise = [DLPromise new];
        return self.promise;
    };
}

- (DLPromiseSingleBlock)success
{
    return ^(DLPromiseHandleBlock block)
    {
        self.onFulfilled = block;
        self.onRejected = nil;
        self.promise = [DLPromise new];
        return self.promise;
    };
}


- (void)changeState:(DLPromiseState)state withValue:(id)value
{
    self.state = state;
    id returnValue = nil;
    if (_state == DLPromiseStateRejected) {
        if (self.onRejected) {
           returnValue = self.onRejected(value);
        }
    }
    else if (_state == DLPromiseStateFulfilled)
    {
        if (self.onFulfilled) {
            returnValue = self.onFulfilled(value);
        }
    }

    if ([returnValue isKindOfClass:[DLPromise class]]) {
        DLPromise *promise = returnValue;
        promise.promise = self.promise.promise;
        promise.onFulfilled = self.promise.onFulfilled;
        promise.onRejected = self.promise.onRejected;
        return;
    }
    else
    {
        if (self.promise) {
            if (returnValue == nil) {
                returnValue = value;
            }
            [self.promise changeState:self.state withValue:returnValue];
        }
    }
}


+ (DLPromiseHandleBlock)makeBlock:(DLPromiseHandleBlock)block
{
    return block;
}

- (void)dealloc
{
    NSLog(@"promise delloc");
}


@end
