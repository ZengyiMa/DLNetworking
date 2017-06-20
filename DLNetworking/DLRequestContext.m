//
//  DLRequestContext.m
//  DLNetworking
//
//  Created by famulei on 20/06/2017.
//
//

#import "DLRequestContext.h"

@interface DLRequestContext ()
@property (nonatomic, strong) id data;
@property (nonatomic, assign) BOOL stop;

@end

@implementation DLRequestContext

- (void)stopPropagate
{
    self.stop = YES;
}

- (void)setReturnValue:(id)data
{
    self.data = data;
}
@end
