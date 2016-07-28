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
#import "LKJBluetoothTableViewCell.h"
#import "LKJLockViewController.h"
#import "LKJTabViewController.h"

@import CoreBluetooth;

static NSString * const kLKJConnectionCellIdentifier = @"com.locjkaw.ble.connection.cell";

@interface LKJConnectionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) NSInteger numberOfRowsInSectionZero;
@property (nonatomic) NSInteger numberofRowsInSectionOne;

@end

@implementation LKJConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.numberOfRowsInSectionZero = 0;
    self.numberofRowsInSectionOne = 0;

    self.tableView = [[UITableView alloc]init];
    [AutolayoutHelper configureView:self.view fillWithSubView:self.tableView];
    [self.tableView registerClass:[LKJBluetoothTableViewCell class] forCellReuseIdentifier:kLKJConnectionCellIdentifier];
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
    LKJBluetoothTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLKJConnectionCellIdentifier];
    CBPeripheral *peripheral =[[LKJBluetoothController sharedBluetoothController]peripheralAtIndex:indexPath.row];
    [cell configureWithPeripheral:peripheral andRSSI:@(-85)];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return self.numberOfRowsInSectionZero;
    } else if (section == 1) {
        return self.numberofRowsInSectionOne;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[LKJBluetoothController sharedBluetoothController]selectPeripheralAtIndex:indexPath.row];
    if(self.delegate) {
        [self.delegate viewController:self shouldTransitionToViewControllerOfClass:[LKJLockViewController class]];
    }
}

#pragma mark notification handling

- (void)newBluetoothDevice : (NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger section = ((NSNumber *)notification.object).integerValue;
        NSIndexPath *path;
        if(section == 0) {
            path = [NSIndexPath indexPathForRow:self.numberOfRowsInSectionZero inSection:section];
        } else if (section ==1) {
            path = [NSIndexPath indexPathForRow:self.numberofRowsInSectionOne inSection:section];
        }

        [self.tableView beginUpdates];
        if(section == 0) {
            self.numberOfRowsInSectionZero +=1;
        } else if (section == 1) {
            self.numberofRowsInSectionOne +=1;
        } //else would be error.
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    });
}

- (void)lostBluetoothDevice : (NSNotification *)notification {
    NSInteger section = ((NSNumber *)notification.object[@"section"]).intValue;
    NSInteger row = ((NSNumber *)notification.object[@"row"]).intValue;
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
    if(section == 0) {
        self.numberOfRowsInSectionZero--;
    } else {
        self.numberofRowsInSectionOne++;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
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
