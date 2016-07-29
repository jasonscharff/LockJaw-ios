//
//  LKJLockViewController.m
//  LockJaw
//
//  Created by Jason Scharff on 7/25/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJLockViewController.h"

#import "AutolayoutHelper.h"

#import "UIColor+LKJColorPalette.h"

#import <Realm/Realm.h>

#import "LKJBluetoothController.h"
#import "LKJConnectionViewController.h"
#import "LKJLockView.h"
#import "LKJHistory.h"

@interface LKJLockViewController ()

@property (nonatomic) LKJLockView *lockView;
@property (nonatomic) UILabel *noCapsusLabel;


@end

@implementation LKJLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.lockView = [[LKJLockView alloc]init];
    [self.lockView addTarget:self action:@selector(changeLockStatus:) forControlEvents:UIControlEventTouchDown];
    
    self.noCapsusLabel = [UILabel new];
    self.noCapsusLabel.text = @"No Capsus connected.";
    self.noCapsusLabel.font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightBold];
    self.noCapsusLabel.textColor = [UIColor lkj_goldColor];
    
    [AutolayoutHelper configureView:self.view
                           subViews:NSDictionaryOfVariableBindings(_lockView, _noCapsusLabel)
                        constraints:@[@"X:_lockView.centerY == superview.centerY",
                                      @"H:|-10-[_lockView]-10-|",
                                      @"X:_lockView.width == _lockView.height",
                                      @"X:_noCapsusLabel.centerX == superview.centerX",
                                      @"X:_noCapsusLabel.centerY == superview.centerY"]];
    

    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([[LKJBluetoothController sharedBluetoothController]existsBluetoothDevice]) {
        self.lockView.hidden = NO;
        self.noCapsusLabel.hidden = YES;
    } else {
        self.lockView.hidden = YES;
        self.noCapsusLabel.hidden = NO;
    }
    [self registerForNotifications];
}

- (void)registerForNotifications {
    NSDictionary *notifications = @{kLKJShouldRefreshConnectedBluetoothDevicesNotification : @"lostConnected:"};
    [notifications enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:NSSelectorFromString(obj)
                                                     name:key
                                                   object:nil];
        
    }];
    
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterForNotifications];
}

- (void)dealloc {
    [self unregisterForNotifications];
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

#pragma mark notifications

- (void)lostConnected : (NSNotification *)notification {
    if(self.delegate) {
        [self.delegate viewController:self shouldTransitionToViewControllerOfClass:[LKJConnectionViewController class]];
    }
}


@end
