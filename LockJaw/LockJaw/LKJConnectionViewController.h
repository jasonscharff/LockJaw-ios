//
//  LKJConnectionViewController.h
//  LockJaw
//
//  Created by Jason Scharff on 7/24/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LKJTabViewController.h"

@interface LKJConnectionViewController : UIViewController

@property (nonatomic, weak)id<LKJTabViewControllerDelegate>delegate;


- (BOOL)existsBluetoothDevice;

@end
