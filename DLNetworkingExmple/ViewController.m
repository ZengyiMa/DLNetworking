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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
                [self basicGet];
                break;
            case 1:
                [self basicPost];
                break;
            default:
                break;
        }
    }

    
}

- (void)logName:(NSString *)name info:(id)info
{
    NSLog(@"\n === %@ === \n response = %@", name, info);
}

- (void)basicGet
{
    DLRequest.get
    .url(@"https://httpbin.org/get")
    .send()
    .then({
        [self logName:@"basicGet" info:data];
    });
}




- (void)basicPost
{
    DLRequest.post
    .url(@"https://httpbin.org/post")
    .send()
    .then({
        [self logName:@"basicPost" info:data];
    });
}




@end
