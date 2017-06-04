//
//  DLNetworkingTest.m
//  DLNetworking
//
//  Created by famulei on 05/06/2017.
//
//

#import <XCTest/XCTest.h>

@interface DLNetworkingTest : XCTestCase

@end

@implementation DLNetworkingTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

- (void)logName:(NSString *)name info:(id)info
{
    NSLog(@"\n === %@ === \n response = %@", name, info);
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
