//
//  FPMAuthModalViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/12/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import "FPMLoginViewController.h"
#import "FPMConfirmTokenViewController.h"
#import "FPMAuthModalViewController.h"

@implementation FPMAuthModalViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor clearColor];
}

- (void)presentLoginModal {
  FPMLoginViewController* loginViewController = [FPMLoginViewController new];
  [self present:loginViewController];
}

- (void)presentConfirmTokenModal {
  FPMConfirmTokenViewController* confirmTokenViewController = [FPMConfirmTokenViewController new];
  [self present:confirmTokenViewController];
}

@end
