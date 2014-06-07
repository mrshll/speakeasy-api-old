//
//  FPMOnboardViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/3/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <Lockbox/Lockbox.h>

#import "FPMConfirmTokenViewController.h"
#import "FPMOnboardViewController.h"

#define FPM_REQUEST_CODE_URL_STRING (@"http://localhost:7076/login/phone_number")

@implementation FPMOnboardViewController

- (IBAction)logInPressed:(id)sender {
  [self requestAuthCodeForPhoneNumber:[self.phoneNumberTextField text]];
}

- (void)requestAuthCodeForPhoneNumber:(NSString *)phoneNumber {
  NSLog(@"Loging in with phone number: %@", phoneNumber);
  
  NSDictionary *params = @{@"phone_number": phoneNumber};
  
  NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:FPM_REQUEST_CODE_URL_STRING parameters:params error:nil];
  AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFHTTPResponseSerializer serializer];
  operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
    NSLog(@"Token request success");
    [Lockbox setString:phoneNumber forKey:@"phoneNumber"];
  } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
    NSLog(@"%@", error);
  }];
  
  [operation start];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
