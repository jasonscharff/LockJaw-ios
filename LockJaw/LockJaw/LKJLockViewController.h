//
//  LKJLockViewController.h
//  LockJaw
//
//  Created by Jason Scharff on 7/25/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LKJTabViewController.h"

@interface LKJLockViewController : UIViewController

@property (nonatomic, weak)id<LKJTabViewControllerDelegate>delegate;

@end
