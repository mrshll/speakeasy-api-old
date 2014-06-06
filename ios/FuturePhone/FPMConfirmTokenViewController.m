//
//  FPMConfirmAuthMessageViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/4/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>

#import "FPMConfirmTokenViewController.h"

@implementation FPMConfirmTokenViewController

#define FPM_CONFIRM_TOKEN_URL_STRING (@"http://localhost:7076/login/validate_token")
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
  
  // TODO: pass the phone number from the previous view in
  NSDictionary *params = @{
    @"phone_number": self.phoneNumber,
    @"token": token
  };
  
  NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:FPM_CONFIRM_TOKEN_URL_STRING parameters:params error:nil];
  AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFHTTPResponseSerializer serializer];
  operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
    NSLog(@"Token valid");
    [self performSegueWithIdentifier:@"authComplete" sender:self];
  } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
    NSLog(@"%@", error);
  }];
  
  [operation start];
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
