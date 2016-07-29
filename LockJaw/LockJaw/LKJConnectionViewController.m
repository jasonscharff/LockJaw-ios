//
//  LKJConnectionViewController.m
//  LockJaw
//
//  Created by Jason Scharff on 7/24/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJConnectionViewController.h"

#import "AutolayoutHelper.h"

#import "UIColor+LKJColorPalette.h"

#import "LKJBluetoothController.h"
#import "LKJBluetoothTableViewCell.h"
#import "LKJLockViewController.h"
#import "LKJSectionHeaderTableViewCell.h"
#import "LKJTabViewController.h"

@import CoreBluetooth;

static NSString * const kLKJConnectionCellIdentifier = @"com.locjkaw.ble.connection.cell";
static NSString * const kLKJHeaderCellIdentifier = @"com.lockjaw.tableview.header";

@interface LKJConnectionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) NSInteger numberOfRowsInSectionZero;
@property (nonatomic) NSInteger numberofRowsInSectionOne;
@property (nonnull) UILabel *noDevicesLabel;

@end

@implementation LKJConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];

    self.tableView = [[UITableView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.numberOfRowsInSectionZero = 0;
    self.numberofRowsInSectionOne = 0;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    
    [AutolayoutHelper configureView:self.view fillWithSubView:self.tableView];
    [self.tableView registerClass:[LKJBluetoothTableViewCell class] forCellReuseIdentifier:kLKJConnectionCellIdentifier];
    [self.tableView registerClass:[LKJSectionHeaderTableViewCell class] forCellReuseIdentifier:kLKJHeaderCellIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.backgroundView = backgroundView;
    UIView *footerView = [UIView new];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    self.tableView.tableHeaderView = nil;
    self.noDevicesLabel = [UILabel new];
    self.noDevicesLabel.font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightBold];
    self.noDevicesLabel.textColor = [UIColor lkj_goldColor];
    
    self.noDevicesLabel.text = @"No devices found.";
    _noDevicesLabel.hidden = YES;
    
    [AutolayoutHelper configureView:self.view
                           subViews:NSDictionaryOfVariableBindings(_noDevicesLabel)
                        constraints:@[@"X:_noDevicesLabel.centerX == superview.centerX",
                                      @"X:_noDevicesLabel.centerY == superview.centerY"]];
    
    
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
    if(indexPath.row == 0) {
        LKJSectionHeaderTableViewCell *header = [tableView dequeueReusableCellWithIdentifier:kLKJHeaderCellIdentifier];
        if(indexPath.section == 0) {
            header.text = @"My Devices";
        } else {
            header.text = @"Connect Device";
        }
        return header;
    } else {
        LKJBluetoothTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLKJConnectionCellIdentifier];
        CBPeripheral *peripheral =[[LKJBluetoothController sharedBluetoothController]peripheralAtIndex:indexPath.row-1];
        [cell configureWithPeripheral:peripheral andRSSI:@(-85)];
        return cell;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.numberofRowsInSectionOne == 0 && self.numberOfRowsInSectionZero == 0) {
        self.noDevicesLabel.hidden = NO;
    } else {
        self.noDevicesLabel.hidden = YES;
    }
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
    [[LKJBluetoothController sharedBluetoothController]selectPeripheralAtIndex:indexPath.row-1];
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
            if(self.numberOfRowsInSectionZero == 0) {
                path = [NSIndexPath indexPathForRow:self.numberOfRowsInSectionZero+1 inSection:section];
                NSIndexPath *headerPath = [NSIndexPath indexPathForRow:0 inSection:section];
                self.numberOfRowsInSectionZero += 1;
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[headerPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
                
            } else {
                path = [NSIndexPath indexPathForRow:self.numberOfRowsInSectionZero inSection:section];
            }
        } else if (section == 1) {
            if(self.numberofRowsInSectionOne == 0) {
                path = [NSIndexPath indexPathForRow:self.numberofRowsInSectionOne+1 inSection:section];
                NSIndexPath *headerPath = [NSIndexPath indexPathForRow:0 inSection:section];
                self.numberofRowsInSectionOne += 1;
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[headerPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            } else {
                path = [NSIndexPath indexPathForRow:self.numberofRowsInSectionOne inSection:section];
            }
        }

        if(section == 0) {
            self.numberOfRowsInSectionZero +=1;
        } else if (section == 1) {
            self.numberofRowsInSectionOne +=1;
        } //else would be error.
        [self.tableView beginUpdates];
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
