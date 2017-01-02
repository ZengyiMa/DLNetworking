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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DLRequest.start()
             .get()
             .url(@"https://httpbin.org/get")
             .send()
             .then([DLReqeustPromise makeBlock:^id(id value) {
                 return value[@"headers"];
             }], nil)
             .then([DLReqeustPromise makeBlock:^id(id value) {
                 NSLog(@"value = %@", value);
                 return nil;
             }],nil)
            .then([DLReqeustPromise makeBlock:^id(id value) {
                NSLog(@"开始第二个请求");
                return DLRequest.start().get().url(@"https://httpbin.org/get").send();
            }],nil)
            .then([DLReqeustPromise makeBlock:^id(id value) {
                NSLog(@"第二个结果");
                NSLog(@"value = %@", value);
                return nil;
            }],nil);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
