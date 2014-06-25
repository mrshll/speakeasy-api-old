//
//  FPMViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 5/26/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "UIColor+CustomColors.h"
#import "FPMFlatButton.h"
#import "FPMRecordViewController.h"
#import "FPMDispatchMessageViewController.h"

@interface FPMRecordViewController ()

@property (nonatomic) AVAudioRecorder* recorder;
@property (nonatomic) NSURL* mediaURL;
@property FPMFlatButton* recordButton;
@property UIImageView* logoImageView;

@end

@implementation FPMRecordViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self addRecordButton];
  [self addLogoImageView];
  
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

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)success {
  [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
  
  if (success) {
    NSLog(@"recorded file: %@", recorder.url);
    self.mediaURL = recorder.url;
    
    FPMDispatchMessageViewController* dispatchMessageViewController = [FPMDispatchMessageViewController new];
    dispatchMessageViewController.mediaURL = self.mediaURL;
    [self presentViewController:dispatchMessageViewController animated:YES completion:nil];
  } else {
    NSLog(@"recording audio failed");
  }
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
  FPMDispatchMessageViewController* dispatchViewController = [segue destinationViewController];
  [dispatchViewController setMediaURL: self.mediaURL];
}

#pragma mark - Helpers

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
//  [recorder prepareToRecord];
  return recorder;
}

- (void)addRecordButton {
  self.recordButton = [FPMFlatButton button];
  self.recordButton.backgroundColor = [UIColor customYellowColor];
  self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
  [self.view addSubview:self.recordButton];
  
  [self.recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.recordButton
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.f constant:0.f]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.recordButton
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.f constant:0.f]];
}

- (void)addLogoImageView {
  self.logoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Icon"]];
  self.logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view insertSubview:self.logoImageView belowSubview:self.recordButton];
  
  [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.logoImageView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.f constant:0.f]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImageView
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.recordButton
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.f constant:-15.f]];
}

@end
