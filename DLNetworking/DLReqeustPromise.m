//
//  DLReqeustPromise.m
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import "DLReqeustPromise.h"

@interface DLReqeustPromise ()
@property (nonatomic, strong) DLReqeustPromise *promise;
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
    
    if (self.promise) {
        [self.promise changeState:self.state withValue:returnValue];
    }
}


+ (DLReqeustPromiseHandleBlock)makeBlock:(DLReqeustPromiseHandleBlock)block
{
    return block;
}


@end
