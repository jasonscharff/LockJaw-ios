//
//  LKJLockViewController.m
//  LockJaw
//
//  Created by Jason Scharff on 7/25/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJLockViewController.h"

#import "AutolayoutHelper.h"

#import "LKJBluetoothController.h"
#import "LKJLockView.h"

@interface LKJLockViewController ()

@property (nonatomic) LKJLockView *lockView;


@end

@implementation LKJLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    UIButton *lockButton = [[UIButton alloc]init];
//    [lockButton addTarget:self action:@selector(lock:) forControlEvents:UIControlEventTouchDown];
//    [lockButton setTitle:@"Lock/Unlock" forState:UIControlStateNormal];
//    [lockButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    
//    
//    [AutolayoutHelper configureView:self.view
//                           subViews:NSDictionaryOfVariableBindings(lockButton)
//                        constraints:@[@"X:lockButton.centerX == superview.centerX",
//                                      @"X:lockButton.centerY == superview.centerY"]];
    
    self.lockView = [[LKJLockView alloc]init];
    [self.lockView addTarget:self action:@selector(changeLockStatus:) forControlEvents:UIControlEventTouchDown];
    [AutolayoutHelper configureView:self.view
                           subViews:NSDictionaryOfVariableBindings(_lockView)
                        constraints:@[@"X:_lockView.centerY == superview.centerY",
                                      @"H:|-10-[_lockView]-10-|",
                                      @"X:_lockView.width == _lockView.height"]];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)lock : (id)sender {
    if([[LKJBluetoothController sharedBluetoothController]isLocked]) {
        [[LKJBluetoothController sharedBluetoothController]unlockDevice];
    } else {
        [[LKJBluetoothController sharedBluetoothController]lockDevice];
    }
    
}

- (void)changeLockStatus : (id)sender {
    [self.lockView changeLockStatus];
}


@end
