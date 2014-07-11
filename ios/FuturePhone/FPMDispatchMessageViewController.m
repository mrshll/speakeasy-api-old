//
//  FPMDispatchMessageViewController.m
//  FuturePhone
//
//  Created by alden on 5/27/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Lockbox/Lockbox.h>
#import <AddressBook/AddressBook.h>

#import "FPMNetworking.h"
#import "FPMDispatchCell.h"
#import "FPMDispatchMessageViewController.h"
#import "FPMAddToContactViewController.h"

#define DISPATCH_BUTTON_WIDTH 140
#define DISPATCH_BUTTON_HEIGHT 40

@interface FPMDispatchMessageViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property UILabel* dispatchLabel;
@property UICollectionView* dispatchActionCollectionView;
@property NSDictionary* dispatchActionMagnitudes;
@property NSArray* dispatchActionButtonTitles;

@end

@implementation FPMDispatchMessageViewController

- (id)init {
  self = [super init];
  if (self) {
    [self.view setBackgroundColor:[UIColor whiteColor]];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.dispatchActionButtonTitles = @[ @"Minutes", @"Hours", @"Days", @"Weeks", @"Months", @"Years" ];
  
  self.dispatchActionMagnitudes = @{
    @"Minutes": @{ @"from": @2, @"to": @30 },
    @"Hours": @{ @"from": @1, @"to": @12 },
    @"Days": @{ @"from": @1, @"to": @4 },
    @"Weeks": @{ @"from": @1, @"to": @5  },
    @"Months": @{ @"from": @1, @"to": @12 },
    @"Years": @{ @"from": @1, @"to": @2 }
  };
  
  [self addCollectionView];
  [self addDispatchLabel];
}

- (void)addCollectionView {
  UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
  [aFlowLayout setItemSize:CGSizeMake(DISPATCH_BUTTON_WIDTH, DISPATCH_BUTTON_HEIGHT)];
  [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
  
  CGRect frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height);
  self.dispatchActionCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:aFlowLayout];
  
  [self.dispatchActionCollectionView setBackgroundColor:[UIColor whiteColor]];
  [self.dispatchActionCollectionView setDelegate:self];
  [self.dispatchActionCollectionView setDataSource:self];
  [self.dispatchActionCollectionView registerClass:[FPMDispatchCell class] forCellWithReuseIdentifier:@"DispatchCell"];
  
  [self.view addSubview:self.dispatchActionCollectionView];
}

- (void)addDispatchLabel {
  self.dispatchLabel = [UILabel new];
  self.dispatchLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
  self.dispatchLabel.text = @"Call me in a few...";
  [self.dispatchLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self.view insertSubview:self.dispatchLabel aboveSubview:self.dispatchActionCollectionView];
  [self.view addConstraint:[NSLayoutConstraint
                            constraintWithItem:self.dispatchLabel
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.dispatchActionCollectionView
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.f
                                      constant:0.f]];

  [self.view addConstraint:[NSLayoutConstraint
                            constraintWithItem:self.dispatchLabel
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.dispatchActionCollectionView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.f
                                      constant:-10.f]];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - Create Message

- (void)createMessageWithMediaAtURL:(NSURL*)fileURL withTimeUnit:(NSString*)timeUnit magnitude:(NSNumber*)magnitude {
  NSLog(@"uploading and creating message");

  NSString* phoneNumber = [Lockbox stringForKey:@"phoneNumber"];
  NSDictionary* params = @{
    @"delivery_unit": timeUnit,
    @"delivery_magnitude": magnitude,
    @"phone_number": phoneNumber
  };
  
  [FPMNetworking createMessageWithFileAtURL:fileURL andParams:params andSuccess:^(AFHTTPRequestOperation* operation, id responseData) {
    NSLog(@"Create message success");
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
      FPMAddToContactViewController* addToContactViewController = [FPMAddToContactViewController new];
      [self presentViewController:addToContactViewController animated:YES completion:nil];
    } else {
      [self dismissViewControllerAnimated:YES completion:nil];
    }
  } andFailure:^(AFHTTPRequestOperation* operation, NSError* error) {
    NSLog(@"Create message failed with error: %@", error);
    [self dismissViewControllerAnimated:YES completion:nil];
  }];

}

#pragma mark - Dispatch Time Button Actions

- (IBAction)dispatchButtonPressed:(UIButton*)button {
  NSString* timeUnit = button.titleLabel.text;
  
  NSInteger magnitudeRangeFrom = [self.dispatchActionMagnitudes[timeUnit][@"from"] intValue];
  NSInteger magnitudeRangeTo = [self.dispatchActionMagnitudes[timeUnit][@"to"] intValue];
  
  NSNumber* magnitude = [self randomNumberFrom:magnitudeRangeFrom to:magnitudeRangeTo];
  [self createMessageWithMediaAtURL:self.mediaURL withTimeUnit:timeUnit magnitude:magnitude];
}

#pragma mark - Helpers

- (NSNumber*)randomNumberFrom:(NSInteger)min to:(NSInteger)max {
  uint32_t delta = (uint32_t)(max - min);
  NSUInteger rand = arc4random_uniform(delta + 1);
  return [NSNumber numberWithInteger:min + rand];
}

#pragma mark - UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self.dispatchActionMagnitudes count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *dispatchCellIdentifier=@"DispatchCell";
  FPMDispatchCell* dispatchCell = [self.dispatchActionCollectionView dequeueReusableCellWithReuseIdentifier:dispatchCellIdentifier forIndexPath:indexPath];
  NSString* timeUnit = [self.dispatchActionButtonTitles objectAtIndex:indexPath.item];
  [dispatchCell.button setTitle:timeUnit forState:UIControlStateNormal];
  
  [dispatchCell.button addTarget:self action:@selector(dispatchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

  return dispatchCell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
  
  NSInteger numberOfCells = self.view.frame.size.width / DISPATCH_BUTTON_WIDTH;
  NSInteger edgeInsets = (self.view.frame.size.width - (numberOfCells * DISPATCH_BUTTON_WIDTH)) / (numberOfCells + 1);
  
  return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
}

@end
