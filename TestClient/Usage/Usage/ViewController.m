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
    
    NSString *filename = @"Generic";
    // NSString *filename = @"ETicket";
     NSString* newPath = [[NSBundle mainBundle] pathForResource:filename  ofType:@"pfile"];
    
     BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:newPath];
   // [self plainDataFromProtectedFile:newPath];
    
    ProviderRegistry* registry = [ProviderRegistry instance];
    NSURL *url = [NSURL fileURLWithPath:newPath];
     NSError* err=nil;
    
    id<AWIrmProvider>_Nullable irmOperation = [registry providerFor:url error:&err];
    NSString *str = irmOperation.identifier;
    
    irmOperation = [registry provider:str];
    NSString *userId = @"airwatchinboxdev2@airwatchpm.onmicrosoft.com";
    NSString *bundleId = @"com.airwatch.Usage";
    
    
    [irmOperation irmItemHandleForReading:url userId:userId clientId:bundleId completionBlock:^(id<AWIrmItemHandle> _Nullable itemHandle, NSError* _Nullable error) {
        long length = [itemHandle decryptedDataLength];
        Byte *byteData= (Byte*)malloc(length );
        NSError* err=nil;
        [itemHandle plainDataBytes:nil length:length+10 error:&error];
        
    }];

//    [irmOperation irmItemHandleForReading:url userId:userId bundleId:bundleId completionBlock:^(id<AWIrmItemHandle> _Nullable itemHandle, NSError* _Nullable error) {
//        NSData* plaindata = [itemHandle completePlainData];
//        long length = [itemHandle decryptedDataLength];
//         Byte *byteData= (Byte*)malloc(length + 1);
//        itemHandle plainDataBytes:<#(void * _Null_unspecified)#> length:<#(NSUInteger)#> error:<#(NSError *__autoreleasing  _Nullable * _Null_unspecified)#>
//        [itemHandle.irmDataProvider plainDataBytes:byteData range:fetchRange error:nil];
//        NSLog(@"");
//    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

//-(void)plainDataFromProtectedFile:(NSString *)filePath  {
//    
//    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray *cookiesArray = [storage cookies];
//    for (NSHTTPCookie *cookie in cookiesArray) { [storage deleteCookie:cookie];
//        // if ([[cookie name] isEqualToString:@"ESTSAUTHPERSISTENT"] || [[cookie name] isEqualToString:@"ESTSSSOTILES"] )
//        
//    }
//    
//    
//    AWIrmOperationFactory *factory = [AWIrmOperationFactory sharedInstance];
//    
//    // NSString *userId = @"adityaprasd@vmware.com" ;
//    NSString *userId =  @"airwatchinboxdev1@airwatchpm.onmicrosoft.com" ;
//    AWIrmProviderType type = [[AWIrmOperationFactory sharedInstance] irmProviderForContent:filePath];
//    //airwatchinboxdev1@airwatchpm.onmicrosoft.com
//    [[AWIrmOperationFactory sharedInstance] plainDataFromIRMFile:[NSURL fileURLWithPath:filePath] providerType:AWIrmProviderTypeAWIrmProviderTypeMicrosoft userId:userId appBundleId:@"com.airwatch.NewObjClient" completionBlock:^(AWIrmResponse * _Nullable irmResponse, NSError * _Nullable error) {
//        
//        if (irmResponse != nil) {
//            NSLog(@"Logged");
//        }
//        
//        //NSData *plainData = [irmResponse.irmDataProvider completePlainData];
//        
//        NSUInteger decryptedLength = [irmResponse.irmDataProvider decryptedDataLength];
//        
//        
//        
//        
//        if (decryptedLength == 0) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail"
//                                                                message:@"Fail."
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"OK"
//                                                      otherButtonTitles:nil];
//                [alert show];
//            });
//            
//            return ;
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
//                                                            message:@"Success."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//            
//        });
//        
//        
//        
//        NSData *plainDatas = [irmResponse.irmDataProvider completePlainData];
//        NSMutableData *plainData = [[NSMutableData alloc] init];
//        int chunkSize = 1024;
//        
//        int bufferLength = chunkSize;
//        int segments = decryptedLength/bufferLength;
//        int reminder = decryptedLength % bufferLength;
//        int startrange = 0;
//        Byte *byteData= (Byte*)malloc(bufferLength);
//        
//        for (int index = 0; index <= segments; index++) {
//            @autoreleasepool {
//                if (index == segments) {
//                    bufferLength = reminder;
//                    byteData= (Byte*)malloc(bufferLength);
//                }
//                //uint8_t buffer[chunkSize];
//                //Byte *byteData= (Byte*)malloc(bufferLength);
//                NSRange fetchRange =NSMakeRange(startrange,bufferLength);
//                [irmResponse.irmDataProvider plainDataBytes:byteData range:fetchRange error:nil];
//                [plainData appendBytes:byteData length:bufferLength];
//                startrange += bufferLength;
//            }
//        }
//    }];
//    
//    //    [MSProtectedData protectedDataWithProtectedFile:filePath userId:nil authenticationCallback:self.auth consentCallback:self.consentManager options:Default completionBlock:^(MSProtectedData *data, NSError *error) {
//    //
//    //        if(error)  {
//    //
//    //            return;
//    //        }
//    //      
//    //        
//    //    }];
//}

@end
