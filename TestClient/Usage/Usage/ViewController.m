//
//  ViewController.m
//  Usage
//
//  Created by Aditya Prasad on 15/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

#import "ViewController.h"
@import AWIrmFramework;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AWIrmProviderRegistry* registry = [AWIrmProviderRegistry instance];
    id<AWIrmProvider>_Nullable j =  [registry provider: for:@"asd"];
    NSString *str = j.identifier;
    NSURL *url = [[NSURL alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    
    
    // Dispose of any resources that can be recreated.
}

@end
