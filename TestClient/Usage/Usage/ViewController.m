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
    NSURL *url = [[NSURL alloc]init];
    id<AWIrmProvider>_Nullable j =  [registry provider:url];
    NSString *str = j.identifier;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
