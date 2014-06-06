//
//  FPMOnboardViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/3/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>

#import "FPMOnboardViewController.h"

#define FPM_REQUEST_CODE_URL_STRING (@"http://7cdd5781.ngrok.com/code")

@implementation FPMOnboardViewController

- (void)requestAuthCodeForPhoneNumber:(NSString *)phoneNumber {
  NSLog(@"requesting auth code for %@", phoneNumber);
}

@end
