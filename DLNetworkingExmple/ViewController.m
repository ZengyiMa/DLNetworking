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
    
    
    DLRequest.get(@"https://httpbin.org/get")
    .parameters(@{@"a":@"b"})
    .send()
    .then(^id(id data) {
        NSLog(@"response = %@", data);
        return data[@"headers"];
    })
    .then(^id(id data){
        NSLog(@"header = %@", data);
        return nil;
    }).error(^id(id data) {
        NSLog(@"error = %@", data);
        return nil;
    });
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
