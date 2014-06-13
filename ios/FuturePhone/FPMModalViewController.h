//
//  FPMAuthModalViewController.h
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/12/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPMModalViewController : UIViewController <UIViewControllerTransitioningDelegate>

- (void)present:(UIViewController*)viewController;
- (void)dismiss;

@end
