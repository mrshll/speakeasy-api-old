//
//  FPMNetwork.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/10/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <Lockbox/Lockbox.h>
#import "FPMNetworking.h"

#define FPM_BASE_URL_STRING (@"http://31e2e89.ngrok.com")

#define FPM_LOGGED_IN_URL_STRING ([NSString stringWithFormat:@"%@/logged_in", FPM_BASE_URL_STRING])

#define FPM_MESSAGES_URL_STRING ([NSString stringWithFormat:@"%@/messages", FPM_BASE_URL_STRING])

#define FPM_REQUEST_CODE_URL_STRING ([NSString stringWithFormat:@"%@/login/phone_number", FPM_BASE_URL_STRING])

#define FPM_CONFIRM_TOKEN_URL_STRING ([NSString stringWithFormat:@"%@/login/validate_token", FPM_BASE_URL_STRING])

@implementation FPMNetworking

+ (void)saveCookies {
  NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
  
  NSMutableArray* allCookieParams = [[NSMutableArray alloc] init];
  for (NSHTTPCookie* cookie in cookies) {
    NSData* cookieData = [NSJSONSerialization dataWithJSONObject:[cookie properties] options:0 error:nil];
    NSString* cookieString = [[NSString alloc] initWithData:cookieData encoding:NSUTF8StringEncoding];
    [allCookieParams addObject:cookieString];
  }
  [Lockbox setArray:allCookieParams forKey:@"cookies"];
}

+ (BOOL)loadCookies {
  NSArray* allCookieParams = [Lockbox arrayForKey:@"cookies"];
  
  NSHTTPCookieStorage* sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  for (NSString* cookieString in allCookieParams) {
    NSData* cookieData = [cookieString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* cookieParams = [NSJSONSerialization JSONObjectWithData:cookieData options:0 error:nil];
    NSHTTPCookie* cookie = [[NSHTTPCookie alloc] initWithProperties:cookieParams];
    [sharedCookieStorage setCookie:cookie];
  }
  
  return [allCookieParams count];
}

+ (void)isLoggedInWithCompletion:(void (^)(BOOL loggedIn))completion {
  if([self loadCookies]){
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:FPM_LOGGED_IN_URL_STRING parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog(@"User is logged in");
      completion(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"User is NOT logged in with error: %@", error);
      completion(NO);
    }];
  } else {
    completion(NO);
  }
}

+ (void)createMessageWithFileAtURL:(NSURL *)fileURL andParams:(NSDictionary*)params
                        andSuccess:(void (^)(AFHTTPRequestOperation*, id))success
                        andFailure:(void (^)(AFHTTPRequestOperation*, NSError*))failure {
  [self loadCookies];
  NSMutableURLRequest* request =
      [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:FPM_MESSAGES_URL_STRING parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
      [formData appendPartWithFileURL:fileURL name:@"file" error:nil];
  } error:nil];

  AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFHTTPResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:success failure:failure];

  [operation start];
}

+ (void)requestAuthCodeForPhoneNumber:(NSString *)phoneNumber
                           andSuccess:(void (^)(AFHTTPRequestOperation *, id))success
                           andFailure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
  NSDictionary* params = @{ @"phone_number": phoneNumber };

  NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:FPM_REQUEST_CODE_URL_STRING parameters:params error:nil];

  AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFHTTPResponseSerializer serializer];
  operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
  [operation setCompletionBlockWithSuccess:success failure:failure];

  [operation start];
}

+ (void)requestTokenConfirmationForPhoneNumber:(NSString*)phoneNumber token:(NSString *)token
                                    andSuccess:(void (^)(AFHTTPRequestOperation*, id))success
                                    andFailure:(void (^)(AFHTTPRequestOperation*, NSError*))failure {
  NSDictionary* params = @{ @"phone_number": phoneNumber, @"token": token };

  NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:FPM_CONFIRM_TOKEN_URL_STRING parameters:params error:nil];

  AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFHTTPResponseSerializer serializer];
  operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
  [operation setCompletionBlockWithSuccess:success failure:failure];

  [operation start];
}

@end
