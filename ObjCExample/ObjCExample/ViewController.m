//
//  ViewController.m
//  ObjCExample
//
//  Created by Ben Scheirman on 9/3/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

#import "ViewController.h"
@import AdzerkSDK;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ADZPlacement *placement = [[ADZPlacement alloc] initWithDivName:@"div1" adTypes:@[@5]];
    placement.zoneIds = @[@1];
    
    id<ADZUserKeyStore> keyStore = [[ADZKeychainUserKeyStore alloc] init];
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    AdzerkSDK *sdkBackground = [[AdzerkSDK alloc] initWithUserKeyStore:keyStore queue:backgroundQueue];
    [sdkBackground requestPlacements:@[placement] options:nil success:^(ADZPlacementResponse * _Nonnull response) {
        NSLog(@"Background Response: %@", response);
    } failure:^(NSInteger statusCode, NSString * _Nullable body, NSError * _Nullable error) {
        NSLog(@"Background Failure:");
        NSLog(@"  Status Code: %d", (int)statusCode);
        NSLog(@"  Response Body: %@", body);
        NSLog(@"  Error: %@", error);
    }];
    
    AdzerkSDK *sdk = [[AdzerkSDK alloc] init];
    [sdk requestPlacements:@[placement] options:nil success: ^void(ADZPlacementResponse *response) {
        NSLog(@"Response: %@", response);
    } failure: ^void(NSInteger statusCode, NSString *body, NSError *error) {
        NSLog(@"Failure:");
        NSLog(@"  Status Code: %d", (int)statusCode);
        NSLog(@"  Response Body: %@", body);
        NSLog(@"  Error: %@", error);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
