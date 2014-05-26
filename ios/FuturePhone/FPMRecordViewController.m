//
//  FPMViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 5/26/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "FPMRecordViewController.h"

#define FPM_MEDIA_URL_STRING (@"http://localhost:7076/media")
#define FPM_MEDIA_URL ([NSURL URLWithString:@"http://localhost:7076/media"])
#define FPM_MESSAGES_URL_STRING (@"http://localhost:7076/messages")
#define FPM_MESSAGES_URL ([NSURL URLWithString:@"http://localhost:7076/messages"])

@interface FPMRecordViewController ()

@property (nonatomic) AVAudioRecorder *recorder;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;

@end

@implementation FPMRecordViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.recorder = [self createAudioRecorder];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)recordButtonPressed:(id)sender {
  NSLog(@"record pressed");
  
  if (!self.recorder.recording) {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    
    // Start recording
    [self.recorder record];
    [self.recordButton setTitle:@"Done" forState:UIControlStateNormal];
    
  } else {
    
    // Pause recording
    [self.recorder stop];
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
  }
}

#pragma mark - AVAudioRecorder Delegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)success{
  [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
  
  if (success) {
    NSLog(@"sucess! url: %@", recorder.url);
    [self uploadMediaAtURL:recorder.url];
  } else {
    NSLog(@"recording audio failed");
  }
}

#pragma mark - Helpers

- (void)uploadMediaAtURL:(NSURL*)fileURL {
  NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:FPM_MEDIA_URL_STRING parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileURL:fileURL name:@"file" error:nil];
  } error:nil];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSDictionary* response = (NSDictionary *)responseObject;
    [self createMessageForMediaAtUrl: [response objectForKey:@"media_uri"]];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Fail");
  }];

  [operation start];
}

- (void)createMessageForMediaAtUrl:(NSURL*)mediaURL {
  NSDictionary *params = @{
    @"delivery_unit": @"seconds",
    @"delivery_magnitude": @10,
    @"media_uri": mediaURL,
    @"user_id": @"5383bb4491d059000013c4b1"
  };

//  NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:FPM_MESSAGES_URL_STRING parameters:params error:nil];
  NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:FPM_MESSAGES_URL_STRING parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
  } error:nil];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSDictionary* response = (NSDictionary *)responseObject;
    NSLog(@"Success %@", response);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Fail %@", error);
  }];
  
  [operation start];
}

- (AVAudioRecorder*)createAudioRecorder {
  // Recorded file path
  NSArray* pathComponents = @[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"message.m4a"];
  NSURL* outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
  
  // Setup audio session
  AVAudioSession* session = [AVAudioSession sharedInstance];
  [session setCategory:AVAudioSessionCategoryRecord error:nil];
  
  // Define the recorder setting
  NSMutableDictionary* recordSettings = [[NSMutableDictionary alloc] init];
  [recordSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
  [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
  [recordSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
  
  // Initiate and prepare the recorder
  AVAudioRecorder* recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSettings error:NULL];
  recorder.delegate = self;
  recorder.meteringEnabled = YES;
  [recorder prepareToRecord];
  return recorder;
}

@end
