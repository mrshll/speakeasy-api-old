//
//  FPMConfirmAuthMessageViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/4/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <Lockbox/Lockbox.h>

#import "FPMNetworking.h"
#import "FPMConfirmTokenViewController.h"

@implementation FPMConfirmTokenViewController

#define TOKEN_LENGTH 6

- (IBAction)textEntered:(UITextField *)sender {
  NSString* token = sender.text;
  if (token.length == TOKEN_LENGTH){
    sender.enabled = NO;
    [self confirmToken:token];
  }
}

- (void)confirmToken:(NSString*)token {
  NSLog(@"Sending token: %@", token);
  
  NSString* phoneNumber = [Lockbox stringForKey:@"phoneNumber"];

  
  [FPMNetworking requestTokenConfirmationForPhoneNumber:phoneNumber token:token andSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
    
    NSLog(@"Token valid");
    
    [FPMNetworking saveCookies];
    
    [self performSegueWithIdentifier:@"authComplete" sender:self];
  } andFailure:^(AFHTTPRequestOperation* operation, NSError* error) {
    NSLog(@"%@", error);
  }];

  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
