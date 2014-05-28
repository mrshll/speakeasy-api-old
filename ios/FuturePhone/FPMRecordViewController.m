//
//  FPMViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 5/26/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "FPMRecordViewController.h"

#define FPM_MESSAGES_URL_STRING (@"http://localhost:7076/messages")
#define FPM_USER_ID_URL_STRING (@"http://localhost:7076/user_id")

@interface FPMRecordViewController ()

@property (nonatomic) AVAudioRecorder* recorder;
@property (nonatomic, weak) IBOutlet UIButton* recordButton;
@property (nonatomic, copy) NSString* userId;

@end

@implementation FPMRecordViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.recorder = [self createAudioRecorder];

  // TEMP: Get a user id from the server 
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  [manager GET:FPM_USER_ID_URL_STRING parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSDictionary* response = (NSDictionary*)responseObject;
    self.userId = response[@"user_id"];
  } failure:nil];
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
    AVAudioSession* session = [AVAudioSession sharedInstance];
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

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)success {
  [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
  
  if (success) {
    NSLog(@"success! url: %@", recorder.url);
    [self createMessageWithMediaAtURL:recorder.url];
  } else {
    NSLog(@"recording audio failed");
  }
}

#pragma mark - Helpers

- (void)createMessageWithMediaAtURL:(NSURL*)fileURL {
  NSLog(@"uploading and creating message");

  NSDictionary* params = @{
    @"delivery_unit": @"seconds",
    @"delivery_magnitude": @10,
    @"user_id": self.userId
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
