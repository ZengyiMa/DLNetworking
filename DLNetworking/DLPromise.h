//
//  DLReqeustPromise.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>


@class DLPromise;


typedef id (^DLPromiseHandleBlock)(id value);

typedef DLPromise *(^DLPromiseThenBlock)(DLPromiseHandleBlock onFulfilled, DLPromiseHandleBlock onRejected);

typedef DLPromise *(^DLPromiseSingleBlock)(DLPromiseHandleBlock block);



typedef NS_ENUM(NSUInteger, DLPromiseState) {
    DLPromiseStatePending,
    DLPromiseStateFulfilled,
    DLPromiseStateRejected,
};


@interface DLPromise : NSObject

@property (nonatomic, copy) DLPromiseHandleBlock onFulfilled;
@property (nonatomic, copy) DLPromiseHandleBlock onRejected;
@property (nonatomic, assign) DLPromiseState state;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) DLPromise *promise;


- (void)changeState:(DLPromiseState)state withValue:(id)value;

- (DLPromiseThenBlock)then;
- (DLPromiseSingleBlock)failed;
- (DLPromiseSingleBlock)success;



+ (DLPromiseHandleBlock)makeBlock:(DLPromiseHandleBlock)block;

@end
