//
//  FPMLoaderView.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/16/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import "FPMClockView.h"
#import "FPMLoaderView.h"

@interface FPMLoaderView ()

@property FPMClockView* clockView;
@property UILabel* loadingLabel;
@property NSArray* loadingMessages;

@end

@implementation FPMLoaderView

- (id)init{
  CGRect frame = CGRectMake(0, 0, 120, 60);
  self = [super initWithFrame:frame];
  if (self) {
    self.loadingMessages = @[
      @"Making sense of time zones",
      @"Checking daylight savings time",
      @"Tracking the position of the sun",
      @"Building a time machine into a car",
      @"Accelerating to 88 miles per hour",
      @"Trying to understand singularity",
      @"Approaching the black hole",
      @"Realizing hypotheticals"
    ];
    
    [self addClock];
    [self addLabel];
  }
  return self;
}

- (void)addClock {
  _clockView = [FPMClockView new];
  [self addSubview:_clockView];
  CGPoint clockCenter = CGPointMake(self.center.x, self.center.y-20);
  _clockView.center = clockCenter;
  [_clockView start];
}

- (void)addLabel {
  NSString* loadingMessage = [self randomLoadingMessage];
  CGRect labelRect =
    [loadingMessage boundingRectWithSize:CGSizeMake(500, 0)
                                 options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Avenir" size:10] }
                                 context:nil];
  
  _loadingLabel = [[UILabel alloc] initWithFrame:labelRect];
  [_loadingLabel setFont:[UIFont fontWithName:@"Avenir" size:10]];
  
  _loadingLabel.text = [self randomLoadingMessage];
  _loadingLabel.textAlignment = NSTextAlignmentCenter;
  [self addSubview:_loadingLabel];
  _loadingLabel.center = self.center;
}

- (NSString*)randomLoadingMessage {
  return [self.loadingMessages objectAtIndex: arc4random() % [self.loadingMessages count]];
}

@end
