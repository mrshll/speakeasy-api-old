//
//  FPMOnboardViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/3/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import "FPMOnboardViewController.h"

#define FPM_REQUEST_CODE_URL_STRING (@"http://7cdd5781.ngrok.com/code")

@implementation FPMOnboardViewController

- (void)requestAuthCodeForPhoneNumber:(NSString *)phoneNumber {
  NSLog(@"requesting auth code for %@", phoneNumber);
  
  NSDictionary* params = @{ @"phone_number": phoneNumber };
  
  NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:FPM_REQUEST_CODE_URL_STRING parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileURL:fileURL name:@"file" error:nil];
  } error:nil];
  
  AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFHTTPResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
    NSLog(@"Create message success");
  } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
    NSLog(@"Create message failed");
  }];
  
  [operation start];
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
