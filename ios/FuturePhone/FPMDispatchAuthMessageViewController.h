//
//  FPMDispatchMessageViewController.h
//  FuturePhone
//
//  Created by alden on 5/27/14.
//  Copyright (c) 2014 futurephone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPMDispatchAuthMessageViewController : UIViewController

@property (nonatomic) NSURL* mediaURL;
@property (nonatomic, copy) NSString* userId;

- (NSNumber*)randomNumberFrom:(NSInteger)min to:(NSInteger)max;

@end
