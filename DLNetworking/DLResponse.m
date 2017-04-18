//
//  DLResponse.m
//  DLNetworking
//
//  Created by Damien on 12/04/2017.
//
//

#import "DLResponse.h"



@interface __DLResponseBlock : NSObject
@property (nonatomic, copy) DLResponseBlock block;
@property (nonatomic, assign) BOOL isError;
@end

@implementation __DLResponseBlock

@end

@interface DLResponse ()
@property (nonatomic, strong) NSMutableArray<__DLResponseBlock *> *blocks;
@end


@implementation DLResponse




- (DLResponseBlock)then
{
    return ^(DLResponseHandleBlock block)
    {
        if (block) {
            __DLResponseBlock *_block = [__DLResponseBlock new];
            _block.block = block;
            [self.blocks addObject:_block];
        }
        return self;
    };
}

- (DLResponseBlock)error
{
    return ^(DLResponseHandleBlock block)
    {
        if (block) {
            
            __DLResponseBlock *_block = [__DLResponseBlock new];
            _block.block = block;
            _block.isError = YES;
            [self.blocks addObject:_block];
        }
        return self;
    };
}

- (void)responseWithData:(id)data isError:(BOOL)isError
{
    id returnValue = data;
    DLRequest *reqeust = nil;
    for (__DLResponseBlock *block in self.blocks) {
        
        if (reqeust == nil &&  [returnValue isKindOfClass:[DLRequest class]]) {
            // 是一个请求的
            reqeust = returnValue;
            if (block.isError) {
                reqeust.response.error(block.block);
            } else {
                reqeust.response.then(block.block);
            }
            
        }
        else if (reqeust) {
            if (block.isError) {
                reqeust.response.error(block.block);
            } else {
                reqeust.response.then(block.block);
            }
        }
        else {
            if (isError) {
                if (block.isError) {
                    returnValue = block.block(returnValue);
                } else {
                    continue;
                }
            } else {
                if (!block.isError) {
                    returnValue = block.block(returnValue);
                }
                else {
                    continue;
                }
            }
        }
    }
    if (reqeust) {
        reqeust.send();
    }

}

- (NSMutableArray *)blocks
{
    if (!_blocks) {
        _blocks = [NSMutableArray array];
    }
    return _blocks;
}

@end
