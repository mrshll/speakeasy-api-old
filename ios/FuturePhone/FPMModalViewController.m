//
//  FPMAuthModalViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/12/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "FPMLoginViewController.h"
#import "FPMModalViewController.h"

@implementation FPMModalViewController

- (void)viewDidLoad {
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
  return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
  return [DismissingAnimator new];
}

- (void)present:(UIViewController*)viewController {
  viewController.transitioningDelegate = self;
  viewController.modalPresentationStyle = UIModalPresentationCustom;
  
  [self presentViewController:viewController animated:YES completion:nil];
}

- (void)dismiss {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
