//
//  DLReqeustPromise.h
//  DLNetworking
//
//  Created by Damien on 2016/12/27.
//
//

#import <Foundation/Foundation.h>

@class DLReqeustPromise;


typedef void(^DLReqeustPromiseHandleBlock)(id data);

typedef DLReqeustPromise *(^DLReqeustPromiseThenBlock)(DLReqeustPromiseHandleBlock onFulfilled, DLReqeustPromiseHandleBlock onRejected);



typedef NS_ENUM(NSUInteger, DLReqeustPromiseState) {
    DLReqeustPromiseStatePending,
    DLReqeustPromiseStateFulfilled,
    DLReqeustPromiseStateRejected,
};



@interface DLReqeustPromise : NSObject


- (DLReqeustPromiseThenBlock)then;

+ (DLReqeustPromiseHandleBlock)makeBlock:(DLReqeustPromiseHandleBlock)block;




@end
