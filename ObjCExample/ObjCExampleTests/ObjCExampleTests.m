//
//  ObjCExampleTests.m
//  ObjCExampleTests
//
//  Created by Ben Scheirman on 9/3/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
@import AdzerkSDK;

@interface ObjCExampleTests : XCTestCase

@end

@implementation ObjCExampleTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCanAccessPlacementDecisions {
    ADZPlacementDecision* dec = [[ADZPlacementDecision alloc] initWithName:@"myDiv" dictionary:nil];
    id data = dec.contents.firstObject.data;
    XCTAssertNotNil(dec);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
