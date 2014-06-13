//
//  FPMOnboardViewController.h
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/3/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlatButton.h"

@interface FPMLoginViewController : UIViewController

@property (strong) UITextField* phoneNumberTextField;
@property (strong) FlatButton* logInButton;
@property (strong) UILabel* errorLabel;

@end
