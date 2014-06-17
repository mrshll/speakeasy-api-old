//
//  FPMPhoneNumberTextField.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/14/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import "FPMPhoneNumberTextField.h"

@implementation FPMPhoneNumberTextField


- (id)init {
  self = [super init];
  if (self) {
    self.delegate = self;
  }
  return self;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
  if (textField == self) {
    int length = [self getLength:textField.text];

    if (length == 10) {
      if (range.length == 0)
        return NO;
    }

    if (length == 3) {
      NSString *num = [self formatNumber:textField.text];
      textField.text = [NSString stringWithFormat:@"(%@) ", num];
      if (range.length > 0)
        textField.text = [NSString stringWithFormat:@"%@", [num substringToIndex:3]];
    }
    else if (length == 6) {
      NSString *num = [self formatNumber:textField.text];
      textField.text = [NSString stringWithFormat:@"(%@) %@-", [num substringToIndex:3], [num substringFromIndex:3]];
      if (range.length > 0)
        textField.text = [NSString stringWithFormat:@"(%@) %@", [num substringToIndex:3], [num substringFromIndex:3]];
    }
  }
  return YES;
}

- (NSString *)formatNumber:(NSString*)mobileNumber {
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

  int length = [mobileNumber length];
  if (length > 10) {
    mobileNumber = [mobileNumber substringFromIndex:length - 10];
  }
  return mobileNumber;
}

- (int)getLength:(NSString*)mobileNumber {
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
  mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

  int length = [mobileNumber length];
  return length;
}



@end
