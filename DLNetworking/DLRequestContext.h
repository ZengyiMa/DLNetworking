//
//  DLRequestContext.h
//  DLNetworking
//
//  Created by famulei on 20/06/2017.
//
//

#import <Foundation/Foundation.h>

@interface DLRequestContext : NSObject

@property (nonatomic, assign, readonly, getter=isStop) BOOL stop;
@property (nonatomic, strong, readonly) id data;

- (void)stopPropagate; /// 停止 then 链的调研，直接结束
- (void)setReturnValue:(id)data; /// 设置下一个 then 使用的返回值
@end
