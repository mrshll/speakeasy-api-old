//
//  FPMOnboardViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/3/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <Lockbox/Lockbox.h>
#import <POP/POP.h>

#import "UIColor+CustomColors.h"
#import "FPMFlatButton.h"
#import "FPMPhoneNumberTextField.h"
#import "FPMNetworking.h"
#import "FPMAuthModalViewController.h"
#import "FPMConfirmTokenViewController.h"
#import "FPMLoginViewController.h"

@implementation FPMLoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.layer.cornerRadius = 8.f;
  self.view.backgroundColor = [UIColor customBlueColor];
  [self addPhoneNumberTextField];
  [self addLoginButton];
  [self addErrorLabel];
}

- (IBAction)logInPressed:(id)sender {
  [self requestAuthCodeForPhoneNumber:[self.phoneNumberTextField text]];
}

// TODO: have this accept an enum failure type and display appropriate message
- (void)showFailure {
  [self shakeButton];
  [self showErrorLabel];
}

- (void)requestAuthCodeForPhoneNumber:(NSString *)phoneNumber {
  NSLog(@"Loging in with phone number: %@", phoneNumber);

  [FPMNetworking requestAuthCodeForPhoneNumber:phoneNumber andSuccess: ^(AFHTTPRequestOperation* operation, id responseObject) {
      NSLog(@"Token request success");
      [Lockbox setString:phoneNumber forKey:@"phoneNumber"];

      [self dismissViewControllerAnimated:YES completion: ^{
          FPMAuthModalViewController* authModal = (FPMAuthModalViewController*)[self transitioningDelegate];
          [authModal presentConfirmTokenModal];
    }];
  } andFailure: ^(AFHTTPRequestOperation* operation, NSError* error) {
      NSLog(@"Log in failure: %@", error);
      [self showFailure];
  }];
}

#pragma mark - Private Instance methods

- (void)addPhoneNumberTextField {
  self.phoneNumberTextField = [FPMPhoneNumberTextField new];
  self.phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = NO;
  self.phoneNumberTextField.textAlignment = NSTextAlignmentCenter;
  self.phoneNumberTextField.keyboardType = UIKeyboardTypePhonePad;
  self.phoneNumberTextField.backgroundColor = [UIColor whiteColor];
  self.phoneNumberTextField.layer.cornerRadius = 2.f;
  self.phoneNumberTextField.placeholder = @"+1(123)-4567";

  [self.view addSubview:self.phoneNumberTextField];
  [self.phoneNumberTextField becomeFirstResponder];

  NSDictionary *views = NSDictionaryOfVariableBindings(_phoneNumberTextField);

  [self.view addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|-[_phoneNumberTextField]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];

  [self.view addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:|-(48)-[_phoneNumberTextField(==40)]"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
}

- (void)addLoginButton {
  self.logInButton = [FPMFlatButton button];
  self.logInButton.backgroundColor = [UIColor customYellowColor];
  self.logInButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.logInButton setTitle:@"Log in" forState:UIControlStateNormal];
  [self.view insertSubview:self.logInButton belowSubview:self.phoneNumberTextField];

  [self.logInButton addTarget:self action:@selector(logInPressed:) forControlEvents:UIControlEventTouchUpInside];

  [self.view addConstraint:[NSLayoutConstraint
                            constraintWithItem:self.logInButton
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.phoneNumberTextField
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.f
                                      constant:0.f]];

  [self.view addConstraint:[NSLayoutConstraint
                            constraintWithItem:self.logInButton
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.phoneNumberTextField
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.f
                                      constant:15.f]];
}

- (void)addErrorLabel {
  self.errorLabel = [UILabel new];
  self.errorLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
  self.errorLabel.textColor = [UIColor customYellowColor];
  self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.errorLabel.text = @"Invalid phone number";
  self.errorLabel.textAlignment = NSTextAlignmentCenter;
  [self.view insertSubview:self.errorLabel belowSubview:self.logInButton];

  [self.view addConstraint:[NSLayoutConstraint
                            constraintWithItem:self.errorLabel
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.logInButton
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.f
                                      constant:0.f]];

  [self.view addConstraint:[NSLayoutConstraint
                            constraintWithItem:self.errorLabel
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.logInButton
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.f
                                      constant:0.f]];

  self.errorLabel.layer.transform = CATransform3DMakeScale(0.5f, 0.5f, 1.f);
}

#pragma mark Animations

- (void)shakeButton {
  POPSpringAnimation* positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
  positionAnimation.velocity = @1000;
  positionAnimation.springBounciness = 20;
  [positionAnimation setCompletionBlock: ^(POPAnimation *animation, BOOL finished) {
      self.logInButton.userInteractionEnabled = YES;
  }];
  [self.logInButton.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
}

- (void)showErrorLabel {
  self.errorLabel.layer.opacity = 1.0;
  POPSpringAnimation* layerScaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
  layerScaleAnimation.springBounciness = 18;
  layerScaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
  [self.errorLabel.layer pop_addAnimation:layerScaleAnimation forKey:@"labelScaleAnimation"];

  POPSpringAnimation* layerPositionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
  layerPositionAnimation.toValue = @(self.logInButton.layer.position.y + self.logInButton.intrinsicContentSize.height);
  layerPositionAnimation.springBounciness = 12;
  [self.errorLabel.layer pop_addAnimation:layerPositionAnimation forKey:@"layerPositionAnimation"];

  [self performSelector:@selector(hideLabel) withObject:self afterDelay:3.f];
}

- (void)hideLabel {
  POPBasicAnimation* layerScaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
  layerScaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.5f, 0.5f)];
  [self.errorLabel.layer pop_addAnimation:layerScaleAnimation forKey:@"layerScaleAnimation"];

  POPBasicAnimation* layerPositionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
  layerPositionAnimation.toValue = @(self.logInButton.layer.position.y);
  [self.errorLabel.layer pop_addAnimation:layerPositionAnimation forKey:@"layerPositionAnimation"];
}

@end
