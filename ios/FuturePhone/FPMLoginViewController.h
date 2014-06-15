//
//  FPMOnboardViewController.h
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/3/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FPMFlatButton.h"

@interface FPMLoginViewController : UIViewController

@property (strong) UITextField* phoneNumberTextField;
@property (strong) FPMFlatButton* logInButton;
@property (strong) UILabel* errorLabel;

@end
