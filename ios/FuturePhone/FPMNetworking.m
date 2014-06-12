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

#define FPM_MESSAGES_URL_STRING (@"http://localhost:7076/messages")
#define FPM_REQUEST_CODE_URL_STRING (@"http://localhost:7076/login/phone_number")
#define FPM_CONFIRM_TOKEN_URL_STRING (@"http://localhost:7076/login/validate_token")

@implementation FPMNetworking

+ (void)saveCookies {
	NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	[Lockbox setArray:cookies forKey:@"cookies"];
}

+ (void)loadCookies {
	NSArray* cookies = [Lockbox arrayForKey:@"cookies"];

	for (NSHTTPCookie* cookie in cookies) {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
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
