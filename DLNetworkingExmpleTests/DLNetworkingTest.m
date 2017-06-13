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
        .then(^(id data, DLRequestContext *context) {
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
        .then(^(id data, DLRequestContext *context) {
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
        .then(^(id data, DLRequestContext *context) {
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
        .then(^(id data, DLRequestContext *context) {
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
        .then(^(id data, DLRequestContext *context) {
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
        .then(^(id data, DLRequestContext *context) {
            NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [self logName:@"testResponseSerialization" info:dataStr];
            XCTAssertTrue(dataStr.length != 0, @"");
            [expectation fulfill];
        });
    }];
}

- (void)testCancel
{
    [self networkTest:^(XCTestExpectation *expectation) {
       DLRequest *request = DLRequest.new
        .get(@"https://httpbin.org/delay/10")
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
            XCTAssertTrue(NO, @"");
            [expectation fulfill];
            
        }).failure(^(NSError *data, DLRequestContext *context) {
            XCTAssertTrue([data.userInfo[@"NSLocalizedDescription"] isEqualToString:@"cancelled"], @"");
            [expectation fulfill];

        });
        request.cancel();
    }];
}

- (void)testThenChain
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .sendRequest()
        .then(^(NSDictionary *data, DLRequestContext *context) {
            [context setReturnValue:data[@"args"]];
        })
        .then(^(NSDictionary *data, DLRequestContext *context) {
            XCTAssertTrue([data[@"a"] isEqualToString:@"b"], @"");
            [expectation fulfill];
        });
        
    }];
}

- (void)testFailureChain
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .get(@"https://httpbin.org/404")
        .sendRequest()
        .then(^(NSDictionary *data, DLRequestContext *context) {
            XCTAssertTrue(NO, @"");
            [expectation fulfill];
        })
        .failure(^(NSError *data, DLRequestContext *context) {
            [context setReturnValue:data.userInfo[@"NSLocalizedDescription"]];
        })
        .failure(^(NSString *data, DLRequestContext *context) {
            XCTAssertTrue([data isEqualToString:@"Request failed: not found (404)"], @"");
            [expectation fulfill];
        });
        
    }];
}

- (void)testThenStopPropagate
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .sendRequest()
        .then(^(NSDictionary *data, DLRequestContext *context) {
            // 如果没设置，那么将会断言失败。
            [context stopPropagate];
            XCTAssertTrue(YES, @"");
            [expectation fulfill];
        })
        .then(^(NSDictionary *data, DLRequestContext *context) {
        })
        .then(^(NSDictionary *data, DLRequestContext *context) {
            XCTAssertTrue(NO, @"");

        });
        
    }];
}


- (void)testChainRequest
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .sendRequest()
        .then(^(NSDictionary *data, DLRequestContext *context) {
            [self logName:@"testChainRequest --- 1" info:data];
            [context setReturnValue:DLRequest.new.get(@"https://httpbin.org/get").parameters(@{@"c":@"d"})];
        })
        .then(^(NSDictionary *data, DLRequestContext *context) {
            [self logName:@"testChainRequest --- 2" info:data];
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
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    }
}





@end
