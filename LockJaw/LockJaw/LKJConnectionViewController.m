//
//  LKJConnectionViewController.m
//  LockJaw
//
//  Created by Jason Scharff on 7/24/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJConnectionViewController.h"

#import "AutolayoutHelper.h"

#import "LKJBluetoothController.h"
#import "LKJLockViewController.h"

@import CoreBluetooth;

static NSString * const kLKJConnectionCellIdentifier = @"com.locjkaw.ble.connection.cell";

@interface LKJConnectionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) NSInteger numberOfRows;

@end

@implementation LKJConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.numberOfRows = 0;
    self.tableView = [[UITableView alloc]init];
    [AutolayoutHelper configureView:self.view fillWithSubView:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kLKJConnectionCellIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [[LKJBluetoothController sharedBluetoothController]beginScanning];
}

- (void)registerForNotifications {
    NSDictionary *notifications = @{kLKJNewBluetoothDeviceDiscoveredNotification : @"newBluetoothDevice:",
                                    kLKJBluetoothDeviceLostNotification: @"lostBluetoothDevice:",
                                    kLKJBluetoothDeviceConnectedNotification : @"bluetoothConnected:"};
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterForNotifications];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLKJConnectionCellIdentifier];
    CBPeripheral *peripheral =[[LKJBluetoothController sharedBluetoothController]peripheralAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfRows;
    
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[LKJBluetoothController sharedBluetoothController]selectPeripheralAtIndex:indexPath.row];
    LKJLockViewController *lockVC = [[LKJLockViewController alloc]init];
    [self presentViewController:lockVC animated:YES completion:nil];
}

#pragma mark notification handling

- (void)newBluetoothDevice : (NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.numberOfRows inSection:0];
        [self.tableView beginUpdates];
        self.numberOfRows += 1;
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    });
}

- (void)lostBluetoothDevice : (NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        NSIndexPath *path = [NSIndexPath indexPathForRow:((NSNumber *)notification.object).intValue inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    });
}

- (void)bluetoothConnected : (NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
       //present next vc.
        NSLog(@"device connected");
    });
}


@end
