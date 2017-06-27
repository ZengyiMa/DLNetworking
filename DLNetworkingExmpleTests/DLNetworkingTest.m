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

- (void)testBatchRequests
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest *r1 = DLRequest.new.get(@"https://httpbin.org/get");
        DLRequest *r2 = DLRequest.new.post(@"https://httpbin.org/post");
        [DLRequest sendBatchRequests:@[r1, r2]].then(^(NSArray *data, DLRequestContext *context) {
            if (data.count == 0) {
                XCTAssertTrue(NO, @"");
            }
            [expectation fulfill];
        });
    }];
}

- (void)testWillStart
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .willStartRequest(^{
            [expectation fulfill];
        })
        .sendRequest();
    }];
}

- (void)testDidFinish
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .get(@"https://httpbin.org/get")
        .parameters(@{@"a":@"b"})
        .sendRequest()
        .didFinishedRequest(^{
            [expectation fulfill];
        });
    }];
}

- (void)testDownload
{
    NSString *file = NSHomeDirectory();
    file = [file stringByAppendingPathComponent:@"1.jpg"];
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .download(@"https://httpbin.org/image/png", file)
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
            NSLog(@"download file path = %@", file);
            [expectation fulfill];
        });
    }];
}

- (void)testDownloadProgress
{
    NSString *file = NSHomeDirectory();
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .download(@"https://httpbin.org/range/102400", file)
        .progress(^(NSProgress *downloadProgress) {
            NSLog(@"completedUnitCount = %lld, totalUnitCount = %lld", downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            if (downloadProgress.completedUnitCount == downloadProgress.totalUnitCount) {
                [expectation fulfill];
            }
            
        })
        .sendRequest();
    }];
}

- (void)testUploadData
{
    NSString *file = [[NSBundle mainBundle]pathForResource:@"test_data" ofType:@"data"];
        [self networkTest:^(XCTestExpectation *expectation) {
            DLRequest.new
            .uploadData([NSData dataWithContentsOfFile:file], @"https://httpbin.org/post")
            .sendRequest()
            .then(^(id data, DLRequestContext *context) {
                [expectation fulfill];
            });
        }];
}

- (void)testUploadProgress
{
    NSString *file = [[NSBundle mainBundle]pathForResource:@"test_data" ofType:@"data"];
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .uploadData([NSData dataWithContentsOfFile:file], @"https://httpbin.org/post")
        .uploadProgress(^(NSProgress *progress) {
            NSLog(@"completedUnitCount = %lld, totalUnitCount = %lld", progress.completedUnitCount, progress.totalUnitCount);
            if (progress.completedUnitCount == progress.totalUnitCount) {
                [expectation fulfill];
            }
        })
        .sendRequest();
        
    }];
}

- (void)testUploadFile
{
    NSString *file = [[NSBundle mainBundle]pathForResource:@"test_data" ofType:@"data"];
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .uploadFile(file, @"https://httpbin.org/post")
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
            [expectation fulfill];
        });
    }];
}

- (void)testMultipartFormData
{
    [self networkTest:^(XCTestExpectation *expectation) {
        DLRequest.new
        .post(@"https://httpbin.org/post")
        .multipartFormData(^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFormData:[@"ok" dataUsingEncoding:NSUTF8StringEncoding] name:@"test"];
        })
        .sendRequest()
        .then(^(id data, DLRequestContext *context) {
            XCTAssertTrue([data[@"form"][@"test"] isEqualToString:@"ok"], @"");
            [expectation fulfill];
        })
        ;
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
