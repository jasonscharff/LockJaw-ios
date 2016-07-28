//
//  LKJBluetoothController.h
//  LockJaw
//
//  Created by Jason Scharff on 7/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

static NSString * const kLKJNewBluetoothDeviceDiscoveredNotification = @"com.lockjaw.ble.device.discovered";
static NSString * const kLKJBluetoothDeviceLostNotification = @"com.lockjaw.ble.device.lost";
static NSString * const kLKJBluetoothDeviceConnectedNotification = @"com.lockjaw.ble.device.connected";
static NSString * const kLKJBluetoothDeviceDisconnectedNotification = @"com.lockjaw.ble.device.disconnected";
static NSString * const kLKJLockedNotification = @"com.lockjaw.lock.locked";
static NSString * const kLKJUnlockedNotification = @"com.lockjaw.lock.unlocked";

static NSString * const kLKJShouldRefreshConnectedBluetoothDevicesNotification = @"com.lockjaw.ble.connected.refresh";




@interface LKJBluetoothController : NSObject

+ (instancetype)sharedBluetoothController;

- (CBPeripheral *)peripheralAtIndex : (NSInteger)index;
- (void)selectPeripheralAtIndex : (NSInteger)index;
- (NSInteger)numberOfDevices;
- (void)beginScanning;

- (void)lockDevice;
- (void)unlockDevice;

- (BOOL)isLocked;

- (BOOL)existsBluetoothDevice;

- (BOOL)isElgibleForLock;

@end
