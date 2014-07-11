//
//  FPMAddToContactViewController.m
//  FuturePhone
//
//  Created by Marshall Moutenot on 7/10/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import "FPMAddToContactViewController.h"

#import <AddressBook/AddressBook.h>
#import "UIColor+CustomColors.h"
#import "FPMFlatButton.h"

@interface FPMAddToContactViewController ()

@property FPMFlatButton* addContactButton;
@property UILabel* explaination;

@end

@implementation FPMAddToContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  [self showAddContactButton];
  [self showExplaination];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)showAddContactButton {
  self.addContactButton = [FPMFlatButton button];
  self.addContactButton.backgroundColor = [UIColor customYellowColor];
  self.addContactButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.addContactButton setTitle:@"Add to contacts" forState:UIControlStateNormal];
  [self.view addSubview:self.addContactButton];
  
  [self.addContactButton addTarget:self action:@selector(addContactButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.addContactButton
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.f constant:0.f]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addContactButton
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.f constant:0.f]];
}

- (void)showExplaination {
  self.explaination = [UILabel new];
  self.explaination.translatesAutoresizingMaskIntoConstraints = NO;
  self.explaination.font = [UIFont fontWithName:@"Avenir-Light" size:18];
  self.explaination.text = @"The universe is vast and \"you from the past\" exists in another dimension. Naturally, they have a different phone number.";
  self.explaination.lineBreakMode = NSLineBreakByWordWrapping;
  self.explaination.numberOfLines = 0;
  
  [self.view addSubview:self.explaination];
  
  [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.explaination
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.f constant:0.f]];
  
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.explaination
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.addContactButton
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.f constant:-20.f]];
  
  [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.explaination
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.f constant:20.f]];
  
  [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.explaination
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.view
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.f constant:-20.f]];
}
- (void)showContactsAuth {
  ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
  if (!addressBook) {
    [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
  }
  
  // Only prompt for access and add contact if user hasn't allowed us to already or said no.
  if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusNotDetermined) {
    [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
  }
  
  ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
    if (granted) {
      NSLog(@"granted address book access");
      CFErrorRef error = NULL;
      ABRecordRef contactRecord = ABPersonCreate();
      BOOL success = ABRecordSetValue(contactRecord, kABPersonFirstNameProperty, CFSTR("You from the past"), NULL);
      ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
      success = success && ABMultiValueAddValueAndLabel(phoneNumberMultiValue, @"6154900724", kABPersonPhoneMainLabel, NULL);
      success = success && ABRecordSetValue(contactRecord, kABPersonPhoneProperty, phoneNumberMultiValue, NULL);
      success = success && ABAddressBookAddRecord(addressBook, contactRecord, NULL);
      success = success && ABAddressBookSave(addressBook, &error);
      
      if (!success) {
        NSLog(@"Couldn't update address book");
      }
      
      CFRelease(phoneNumberMultiValue);
      CFRelease(contactRecord);
    }
    CFRelease(addressBook);
  });
  
  [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addContactButtonPressed:(id)sender {
  [self showContactsAuth];
}

@end
