//
//  LKJLockViewController.m
//  LockJaw
//
//  Created by Jason Scharff on 7/25/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJLockViewController.h"

#import "AutolayoutHelper.h"

#import <Realm/Realm.h>

#import "LKJBluetoothController.h"
#import "LKJLockView.h"
#import "LKJHistory.h"

@interface LKJLockViewController ()

@property (nonatomic) LKJLockView *lockView;


@end

@implementation LKJLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
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


- (void)changeLockStatus : (id)sender {
  //  [self.lockView changeLockStatus];
    if([[LKJBluetoothController sharedBluetoothController]isElgibleForLock]) {
        [self.lockView changeLockStatus];
        LKJHistory *historyObject = [[LKJHistory alloc]init];
        historyObject.activatedDate = [NSDate date];
        historyObject.lockName = [[LKJBluetoothController sharedBluetoothController]currentName];
        if([[LKJBluetoothController sharedBluetoothController]isLocked]) {
            historyObject.isLockAction = NO;
            [[LKJBluetoothController sharedBluetoothController]unlockDevice];
        } else {
            historyObject.isLockAction = YES;
            [[LKJBluetoothController sharedBluetoothController]lockDevice];
        }
        
        [[RLMRealm defaultRealm]beginWriteTransaction];
        [[RLMRealm defaultRealm]addObject:historyObject];
        [[RLMRealm defaultRealm]commitWriteTransaction];
    } else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Unable to reach lock."
                                                                         message:@"Please try again in a few seconds."
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:dismiss];
        
        [self presentViewController:alertVC animated:YES completion:nil];
        
    }
}


@end
