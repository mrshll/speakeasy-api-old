//
//  FPMOnboardViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/3/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <Lockbox/Lockbox.h>

#import "FPMNetworking.h"
#import "FPMConfirmTokenViewController.h"
#import "FPMOnboardViewController.h"

@implementation FPMOnboardViewController

- (IBAction)logInPressed:(id)sender {
  [self requestAuthCodeForPhoneNumber:[self.phoneNumberTextField text]];
}

- (void)requestAuthCodeForPhoneNumber:(NSString *)phoneNumber {
  NSLog(@"Loging in with phone number: %@", phoneNumber);

  [FPMNetworking requestAuthCodeForPhoneNumber:phoneNumber andSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
    NSLog(@"Token request success");
    [Lockbox setString:phoneNumber forKey:@"phoneNumber"];
  } andFailure:^(AFHTTPRequestOperation* operation, NSError* error) {
    NSLog(@"%@", error);
  }];
}

@end
