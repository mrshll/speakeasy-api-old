//
//  FPMViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 5/26/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import "FPMRecordViewController.h"
#import <AFNetworking/AFNetworking.h>

#define FPM_MEDIA_URL_STRING (@"http://localhost:7076/media")
#define FPM_MEDIA_URL ([NSURL URLWithString:@"http://localhost:7076/media"])

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
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:FPM_MEDIA_URL];
  [request setHTTPMethod:@"POST"];
  
//  NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:FPM_MEDIA_URL_STRING parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//    [formData appendPartWithFileURL:fileURL name:@"file" error:nil];
//  } error:nil];
  
  NSURLSessionUploadTask* uploadTask = [manager uploadTaskWithRequest:request fromFile:fileURL progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Upload Media Error: %@", error);
    } else {
      NSLog(@"Upload Media Success: %@ %@", response, responseObject);
    }
  }];
  [uploadTask resume];
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
