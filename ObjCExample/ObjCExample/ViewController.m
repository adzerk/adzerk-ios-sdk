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
