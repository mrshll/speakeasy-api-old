//
//  FPMDispatchMessageViewController.m
//  FuturePhone
//
//  Created by alden on 5/27/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Lockbox/Lockbox.h>

#import "FPMDispatchAuthMessageViewController.h"

#define FPM_MESSAGES_URL_STRING (@"http://localhost:7076/messages")

@interface FPMDispatchAuthMessageViewController ()

@end

@implementation FPMDispatchAuthMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Create Message

- (void)createMessageWithMediaAtURL:(NSURL*)fileURL withTimeUnit:(NSString*)timeUnit magnitude:(NSNumber*)magnitude {
  NSLog(@"uploading and creating message");

  NSString* phoneNumber = [Lockbox stringForKey:@"phoneNumber"];
  NSString* sessionKey = [Lockbox stringForKey:@"sessionKey"];
  NSDictionary* params = @{
    @"delivery_unit": timeUnit,
    @"delivery_magnitude": magnitude,
    @"phone_number": phoneNumber,
    @"session_key": sessionKey
  };

  NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:FPM_MESSAGES_URL_STRING parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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

#pragma mark - Dispatch Time Button Actions

- (IBAction)minutesButtonPressed:(id)sender {
  NSNumber* magnitude = [self randomNumberFrom:2 to:30];
  [self createMessageWithMediaAtURL:self.mediaURL withTimeUnit:@"minutes" magnitude:magnitude];
}

- (IBAction)hoursButtonPressed:(id)sender {
  NSNumber* magnitude = [self randomNumberFrom:1 to:12];
  [self createMessageWithMediaAtURL:self.mediaURL withTimeUnit:@"hours" magnitude:magnitude];
}

- (IBAction)daysButtonPressed:(id)sender {
  NSNumber* magnitude = [self randomNumberFrom:1 to:6];
  [self createMessageWithMediaAtURL:self.mediaURL withTimeUnit:@"days" magnitude:magnitude];
}

- (IBAction)weeksButtonPressed:(id)sender {
  NSNumber* magnitude = [self randomNumberFrom:1 to:4];
  [self createMessageWithMediaAtURL:self.mediaURL withTimeUnit:@"weeks" magnitude:magnitude];
}

- (IBAction)monthsButtonPressed:(id)sender {
  NSNumber* magnitude = [self randomNumberFrom:1 to:5];
  [self createMessageWithMediaAtURL:self.mediaURL withTimeUnit:@"months" magnitude:magnitude];
}

- (IBAction)yearsButtonPressed:(id)sender {
  NSNumber* magnitude = [self randomNumberFrom:1 to:2];
  [self createMessageWithMediaAtURL:self.mediaURL withTimeUnit:@"years" magnitude:magnitude];
}

#pragma mark - Helpers

- (NSNumber*)randomNumberFrom:(NSInteger)min to:(NSInteger)max {
  NSInteger delta = max - min;
  NSUInteger rand = arc4random_uniform(delta + 1);
  return [NSNumber numberWithInteger:min + rand];
}
@end
