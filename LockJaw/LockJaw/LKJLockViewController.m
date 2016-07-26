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

@interface LKJLockViewController ()



@end

@implementation LKJLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *lockButton = [[UIButton alloc]init];
    [lockButton addTarget:self action:@selector(lock:) forControlEvents:UIControlEventTouchDown];
    [lockButton setTitle:@"Lock/Unlock" forState:UIControlStateNormal];
    [lockButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    [AutolayoutHelper configureView:self.view
                           subViews:NSDictionaryOfVariableBindings(lockButton)
                        constraints:@[@"X:lockButton.centerX == superview.centerX",
                                      @"X:lockButton.centerY == superview.centerY"]];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)lock : (id)sender {
    [[LKJBluetoothController sharedBluetoothController]lockDevice];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
