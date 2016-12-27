//
//  DLReqeustPromise.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>


@class DLReqeustPromise;


typedef id (^DLReqeustPromiseHandleBlock)(id value);

typedef DLReqeustPromise *(^DLReqeustPromiseThenBlock)(DLReqeustPromiseHandleBlock onFulfilled, DLReqeustPromiseHandleBlock onRejected);



typedef NS_ENUM(NSUInteger, DLReqeustPromiseState) {
    DLReqeustPromiseStatePending,
    DLReqeustPromiseStateFulfilled,
    DLReqeustPromiseStateRejected,
};



@interface DLReqeustPromise : NSObject

@property (nonatomic, copy) DLReqeustPromiseHandleBlock onFulfilled;
@property (nonatomic, copy) DLReqeustPromiseHandleBlock onRejected;
@property (nonatomic, assign) DLReqeustPromiseState state;
@property (nonatomic, strong) id value;


- (void)changeState:(DLReqeustPromiseState)state withValue:(id)value;

- (DLReqeustPromiseThenBlock)then;

+ (DLReqeustPromiseHandleBlock)makeBlock:(DLReqeustPromiseHandleBlock)block;

@end
