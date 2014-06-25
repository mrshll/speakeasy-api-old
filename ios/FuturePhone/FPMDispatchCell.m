//
//  FPMDispatchCell.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/20/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import "FPMDispatchCell.h"

@implementation FPMDispatchCell

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    CGRect buttonRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.button = [[FPMFlatButton alloc] initWithFrame:buttonRect];
    [self addSubview:self.button];
  }
  return self;
}

@end
