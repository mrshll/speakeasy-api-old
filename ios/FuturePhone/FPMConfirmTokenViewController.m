//
//  FPMConfirmAuthMessageViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/4/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <Lockbox/Lockbox.h>

#import "UIColor+CustomColors.h"
#import "FPMNetworking.h"
#import "FPMAuthModalViewController.h"
#import "FPMConfirmTokenViewController.h"

@implementation FPMConfirmTokenViewController

#define TOKEN_LENGTH 6

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor customBlueColor];
  [self addTokenTextField];
}

- (IBAction)textEntered:(UITextField *)sender {
  NSString *token = sender.text;
  if (token.length == TOKEN_LENGTH) {
    sender.enabled = NO;
    [self confirmToken:token];
  }
}

- (void)confirmToken:(NSString *)token {
  NSLog(@"Sending token: %@", token);

  NSString *phoneNumber = [Lockbox stringForKey:@"phoneNumber"];


  [FPMNetworking requestTokenConfirmationForPhoneNumber:phoneNumber token:token andSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog(@"Token valid");

      [FPMNetworking saveCookies];

      [self dismissViewControllerAnimated:YES completion:nil];
      FPMAuthModalViewController *authModal = (FPMAuthModalViewController *)[self transitioningDelegate];
      [authModal dismiss];
  } andFailure: ^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"%@", error);
  }];

  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addTokenTextField {
  self.tokenTextField = [UITextField new];
  self.tokenTextField.translatesAutoresizingMaskIntoConstraints = NO;
  self.tokenTextField.textAlignment = NSTextAlignmentCenter;
  self.tokenTextField.keyboardType = UIKeyboardTypeNumberPad;
  self.tokenTextField.backgroundColor = [UIColor whiteColor];
  self.tokenTextField.layer.cornerRadius = 2.f;
  self.tokenTextField.placeholder = @"123456";

  [self.tokenTextField addTarget:self
                          action:@selector(textEntered:)
                forControlEvents:UIControlEventEditingChanged];

  [self.tokenTextField becomeFirstResponder];
  [self.view addSubview:self.tokenTextField];

  NSDictionary *views = NSDictionaryOfVariableBindings(_tokenTextField);

  [self.view addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|-(40)-[_tokenTextField]-(40)-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];

  [self.view addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:|-(88)-[_tokenTextField(==36)]"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
}

@end
