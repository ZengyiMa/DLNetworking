//
//  DLNetManager.m
//  DLNetworking
//
//  Created by famulei on 27/12/2016.
//
//

#import "DLNetManager.h"


@interface DLNetManager ()

@property (nonatomic, strong) NSMutableDictionary *requestDictionary;


@end



@implementation DLNetManager

+ (instancetype)manager
{
    static DLNetManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DLNetManager new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addRequest:(DLRequest *)request
{
    self.requestDictionary[@(request.taskID)] = request;
}

- (void)removeRequestWithTaskID:(NSUInteger)taskID
{
    [self.requestDictionary removeObjectForKey:@(taskID)];
}




@end
