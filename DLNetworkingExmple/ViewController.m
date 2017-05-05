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

    DLRequest.get
    .url(@"https://httpbin.org/get")
    .parameters(@{@"a":@"b"})
    .send()
    .then({
        NSLog(@"\n === response = %@", data);
        returnValue = data[@"headers"];
    })
    .then({
        NSLog(@"\n === header = %@", data);
    })
   .error({
        NSLog(@"error = %@", data);
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
