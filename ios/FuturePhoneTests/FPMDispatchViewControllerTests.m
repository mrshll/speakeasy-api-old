//
//  FPMDispatchViewControllerTests.m
//  FuturePhone
//
//  Created by alden on 5/29/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "FPMDispatchAuthMessageViewController.h"

@interface FPMDispatchViewControllerTests : XCTestCase

@property FPMDispatchAuthMessageViewController* vc;

@end

@implementation FPMDispatchViewControllerTests

- (void)setUp
{
  [super setUp];
  self.vc = [[FPMDispatchAuthMessageViewController alloc] init];
}

- (void)tearDown
{
  [super tearDown];
  self.vc = nil;
}

- (void)testRandomNumberFromTo
{
  for (int i = 0; i < 100; ++i) {
    NSNumber* r = [self.vc randomNumberFrom:2 to:10];
    int rand = [r intValue];
    XCTAssert(rand <= 10);
    XCTAssert(rand >= 2);
  }
}

@end
