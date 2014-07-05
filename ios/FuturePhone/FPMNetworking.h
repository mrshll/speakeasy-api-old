//
//  FPMNetwork.h
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/10/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface FPMNetworking : NSObject

+ (void)saveCookies;

+ (BOOL)loadCookies;

+ (void)isLoggedInWithCompletion:(void (^)(BOOL loggedIn))completion;

+ (void)createMessageWithFileAtURL:(NSURL*)fileURL andParams:(NSDictionary*)params
                        andSuccess:(void (^)(AFHTTPRequestOperation*, id))success
                        andFailure:(void (^)(AFHTTPRequestOperation*, NSError*))failure;

+ (void)requestAuthCodeForPhoneNumber:(NSString *)phoneNumber
                           andSuccess:(void (^)(AFHTTPRequestOperation*, id))success
                           andFailure:(void (^)(AFHTTPRequestOperation*, NSError*))failure;

+ (void)requestTokenConfirmationForPhoneNumber:(NSString *)phoneNumber token:(NSString *)token
                                    andSuccess:(void (^)(AFHTTPRequestOperation*, id))success
                                    andFailure:(void (^)(AFHTTPRequestOperation*, NSError*))failure;

@end
