//
//  DLNetworkingTest.m
//  DLNetworking
//
//  Created by famulei on 05/06/2017.
//
//

#import <XCTest/XCTest.h>
#import "DLRequest.h"

@interface DLNetworkingTest : XCTestCase

@end

@implementation DLNetworkingTest

- (void)testBasicGet
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .get(@"https://httpbin.org/get")
        .sendRequest()
        .then(^(id data, id *retval) {
            [self logName:@"basicGet" info:data];
            XCTAssertTrue(YES, @"");
            [expectation fulfill];
        });
        
    }];
}

- (void)testBasicPost
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .post(@"https://httpbin.org/post")
        .sendRequest()
        .then(^(id data, id *retval) {
            [self logName:@"basicPost" info:data];
            XCTAssertTrue(YES, @"");
            [expectation fulfill];
        });
    }];
}

- (void)testHeader
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .get(@"https://httpbin.org/get")
        .headers(@{@"header":@"ok"})
        .sendRequest()
        .then(^(id data, id *retval) {
            [self logName:@"testHeader" info:data];
            XCTAssertTrue([data[@"headers"][@"Header"] isEqualToString:@"ok"], @"");
            [expectation fulfill];
        });
    }];
}

- (void)testParameters
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"p1":@"ok"})
        .sendRequest()
        .then(^(id data, id *retval) {
            [self logName:@"testParameters" info:data];
            XCTAssertTrue([data[@"args"][@"p1"] isEqualToString:@"ok"], @"");
            [expectation fulfill];
        });
    }];
}

- (void)testRequestSerialization
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .post(@"https://httpbin.org/post")
        .parameters(@[@"1",@"2"])
        .requestSerialization(DLRequestSerializationTypeJSON)
        .sendRequest()
        .then(^(id data, id *retval) {
            [self logName:@"testRequestSerialization" info:data];
            XCTAssertTrue([data[@"data"] isEqualToString:@"[\"1\",\"2\"]"], @"");
             [expectation fulfill];
        });
    }];
}

- (void)testResponseSerialization
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .post(@"https://httpbin.org/post")
        .responseSerialization(DLResponseSerializationTypeDATA)
        .sendRequest()
        .then(^(id data, id *retval) {
            NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [self logName:@"testResponseSerialization" info:dataStr];
            XCTAssertTrue(dataStr.length != 0, @"");
            [expectation fulfill];
        });
    }];
}





- (void)logName:(NSString *)name info:(id)info
{
    NSLog(@"\n\n\n === %@ === \n response = %@ \n\n\n", name, info);
}

- (void)networkTest:(void (^)(XCTestExpectation *expectation))testBlock {
    
    if (testBlock) {
        XCTestExpectation *exp = [self expectationWithDescription:@""];
        testBlock(exp);
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        }];
    }
}





@end
