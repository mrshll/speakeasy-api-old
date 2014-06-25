//
//  FPMDispatchCell.h
//  FuturePhone
//
//  Created by Marshall Moutenot on 6/20/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FPMFlatButton.h"
#import "UIColor+CustomColors.h"

@interface FPMDispatchCell : UICollectionViewCell

@property FPMFlatButton* button;
@property NSString* timeUnit;

@end
