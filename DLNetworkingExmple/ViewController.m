//
//  ViewController.m
//  DLNetworkingExmple
//
//  Created by Damien on 2016/12/27.
//
//

#import "ViewController.h"
#import "DLRequest.h"

@interface ViewController ()

@end

@implementation ViewController

//
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    DLRequest.get()
             .url(@"https://httpbin.org/get")
             .send()
             .success([DLPromise makeBlock:^id(id value) {
                 return value[@"headers"];
             }])
             .success([DLPromise makeBlock:^id(id value) {
                 NSLog(@"header value = %@", value);
                 return nil;
             }])
            .success([DLPromise makeBlock:^id(id value) {
                NSLog(@"开始第二个请求");
                return DLRequest.get().url(@"https://httpbin.org/get").send();
            }])
            .success([DLPromise makeBlock:^id(id value) {
                NSLog(@"第二个请求的返回值 value = %@", value);
                return nil;
            }])
            .failed([DLPromise makeBlock:^id(id value) {
                NSLog(@"error = %@", value);
                return nil;
            }]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
