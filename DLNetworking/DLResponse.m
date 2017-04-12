//
//  DLResponse.m
//  DLNetworking
//
//  Created by Damien on 12/04/2017.
//
//

#import "DLResponse.h"



@interface DLResponse ()
@property (nonatomic, strong) NSMutableArray *thens;
@property (nonatomic, strong) NSMutableArray *errors;

@end


@implementation DLResponse




- (DLResponseBlock)then
{
    return ^(DLResponseHandleBlock block)
    {
        if (block) {
            [self.thens addObject:block];
        }
        return self;
    };
}


- (DLResponseBlock)error
{
    return ^(DLResponseHandleBlock block)
    {
        if (block) {
            [self.errors addObject:block];
        }
        return self;
    };
}

- (void)responseThenWithData:(id)data
{
    id returnValue = data;
    DLRequest *reqeust = nil;
    for (DLResponseHandleBlock block in self.thens) {
        if (reqeust == nil &&  [returnValue isKindOfClass:[DLRequest class]]) {
            // 是一个请求的
            reqeust = returnValue;
            reqeust.response.then(block);
        }
        else if (reqeust) {
            reqeust.response.then(block);
        }
        else {
            returnValue = block(returnValue);
        }
    }
    
    if (reqeust)
    {
        reqeust.send();
    }
    
}

- (NSMutableArray *)thens
{
    if (!_thens) {
        _thens = [NSMutableArray array];
    }
    return _thens;
}

- (NSMutableArray *)errors
{
    if (!_errors) {
        _errors = [NSMutableArray array];
    }
    return _errors;
}




@end
