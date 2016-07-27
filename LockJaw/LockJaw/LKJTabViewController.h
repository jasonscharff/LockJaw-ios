//
//  LKJTabViewController.h
//  LockJaw
//
//  Created by Jason Scharff on 7/26/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LKJTabViewControllerDelegate <NSObject>

@required
- (void)viewController : (UIViewController *)viewController shouldTransitionToViewControllerOfClass: (Class)controllerClass;

@end

@interface LKJTabViewController : UIViewController


@end
