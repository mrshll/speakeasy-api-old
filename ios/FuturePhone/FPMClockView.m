//
//  FPMLoaderView.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/16/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import "UIColor+CustomColors.h"
#import "FPMClockView.h"

@interface FPMClockView()

@property NSNumber* position;
@property NSTimer* updateTimer;
@property CAShapeLayer* hourHand;
@property CAShapeLayer* minuteHand;
@property CAShapeLayer* secondHand;

@end

@implementation FPMClockView

- (id)init {
  CGRect frame = CGRectMake(0, 0, 20.0, 20.0);
  if ((self = [super initWithFrame:frame])) {
    [self setUpClock];
  }
  
  return self;
}

- (void)setUpClock {
  CAShapeLayer *face = [CAShapeLayer layer];
  
  // face
  face.bounds = CGRectMake(0, 0, 20.0, 20.0);
  face.position = CGPointMake(CGRectGetMidX(face.bounds), CGRectGetMidY(face.bounds));
  
  face.fillColor = [[UIColor whiteColor] CGColor];
  face.strokeColor = [[UIColor blackColor] CGColor];
  face.lineWidth = 1.2;
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddEllipseInRect(path, nil, self.bounds);
  face.path = path;
  
  [self.layer addSublayer:face];
  
  // second hand
  self.secondHand = [CAShapeLayer layer];
  
  path = CGPathCreateMutable();
  CGPathMoveToPoint(path, nil, 1.0, 0.0);
  CGPathAddLineToPoint(path, nil, 1.0, self.bounds.size.height / 2.0 + 2.0);
  
  self.secondHand.bounds = CGRectMake(0.0, 0.0, 3.0, self.bounds.size.height / 2.0 + 2.0);
  self.secondHand.anchorPoint = CGPointMake(0.5, 0.8);
  self.secondHand.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  self.secondHand.lineWidth = 1.0;
  self.secondHand.strokeColor = [[UIColor lightGrayColor] CGColor];
  self.secondHand.path = path;
  self.secondHand.lineCap = kCALineCapRound;
  
  [self.layer addSublayer:self.secondHand];
  
  // minute hand
  self.minuteHand = [CAShapeLayer layer];
  
  path = CGPathCreateMutable();
  CGPathMoveToPoint(path, nil, 2.0, 0.0);
  CGPathAddLineToPoint(path, nil, 2.0, self.bounds.size.height / 2.0);
  
  self.minuteHand.bounds = CGRectMake(0.0, 0.0, 5.0, self.bounds.size.height / 2.0);
  self.minuteHand.anchorPoint = CGPointMake(0.5, 0.8);
  self.minuteHand.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  self.minuteHand.lineWidth = 1.5;
  self.minuteHand.strokeColor = [[UIColor blackColor] CGColor];
  self.minuteHand.path = path;
  self.minuteHand.lineCap = kCALineCapRound;
  
  [self.layer addSublayer:self.minuteHand];
  
  // hour hand
  self.hourHand = [CAShapeLayer layer];
  
  path = CGPathCreateMutable();
  CGPathMoveToPoint(path, nil, 3, 0);
  CGPathAddLineToPoint(path, nil, 3.0, self.bounds.size.height / 3.0);
  
  self.hourHand.bounds = CGRectMake(0.0, 0.0, 7.0, self.bounds.size.height / 3.0);
  self.hourHand.anchorPoint = CGPointMake(0.5, 0.8);
  self.hourHand.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  self.hourHand.lineWidth = 2.0;
  self.hourHand.strokeColor = [[UIColor blackColor] CGColor];
  self.hourHand.path = path;
  self.hourHand.lineCap = kCALineCapRound;
  
  [self.layer addSublayer:self.hourHand];
  
  [self updateHands];
}

- (void)start {
  self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateHands) userInfo:nil repeats:YES];
}

- (void)stop {
  [self.updateTimer invalidate];
  self.updateTimer = nil;
}

- (void)updateHands {
  self.position = [NSNumber numberWithInt:[self.position intValue] + 1];
  
  float percentageMinutesIntoDay = [self.position intValue] / 600.0;
  float percentageMinutesIntoHour = (float)[self.position intValue] / 60.0;
  float percentageSecondsIntoMinute = (float)[self.position intValue] / 10.0;
  
  self.secondHand.transform = CATransform3DMakeRotation((M_PI * 2) * percentageSecondsIntoMinute, 0, 0, 1);
  self.minuteHand.transform = CATransform3DMakeRotation((M_PI * 2) * percentageMinutesIntoHour, 0, 0, 1);
  self.hourHand.transform = CATransform3DMakeRotation((M_PI * 2) * percentageMinutesIntoDay, 0, 0, 1);
}

@end
