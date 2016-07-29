//
//  LKJBluetoothController.m
//  LockJaw
//
//  Created by Jason Scharff on 7/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJBluetoothController.h"

#import <Realm/Realm.h>

#import "CBPeripheral+ExpirationDate.h"

#import "LKJPeripheral.h"

@import CoreBluetooth;


static NSString * const kLKJPeripheralUUIDKey = @"com.lockjaw.ble.uuid";
static const int kLKJExpirationTimeInterval = 30;

@interface LKJBluetoothController() <CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;


@property (strong, nonatomic) RLMResults *historicalDevices;
@property (strong, nonatomic) NSMutableArray<CBPeripheral *> *connectedPeripherals;

@property (nonatomic, strong) NSMutableDictionary *discoveredDevices;
@property (nonatomic, strong) NSMutableArray *discoveredDevicesArray;

@property (nonatomic, strong) NSTimer *expirationTimer;

@property (nonatomic) BOOL isOnline;

@property (nonatomic) dispatch_queue_t notificationQueue;

@property (nonatomic) NSInteger selectedBluetoothDeviceIndex;



@end

@implementation LKJBluetoothController

+ (instancetype)sharedBluetoothController {
    static dispatch_once_t once;
    static LKJBluetoothController *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        dispatch_queue_t centralQueue = dispatch_queue_create("com.lockjaw.ble", DISPATCH_QUEUE_SERIAL);
        self.notificationQueue = dispatch_queue_create("com.lockjaw.ble.notification", DISPATCH_QUEUE_SERIAL);
        
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self
                                                                  queue:centralQueue];
        
        self.expirationTimer = [NSTimer timerWithTimeInterval:kLKJExpirationTimeInterval
                                                       target:self
                                                     selector:@selector(removeExpiredDevices:)
                                                     userInfo:nil
                                                      repeats:YES];
        
        self.discoveredDevicesArray = [[NSMutableArray alloc]init];
        self.discoveredDevices = [[NSMutableDictionary alloc]init];
        
        self.connectedPeripherals = [[NSMutableArray alloc]init];

        
 //       self.historicalDevices = [LKJPeripheral allObjectsInRealm:[RLMRealm defaultRealm]];
 
        self.selectedBluetoothDeviceIndex = -1;
        
    }
    return self;
}

- (void)beginScanning {
    if(_isOnline) {
      [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}


- (void)removeExpiredDevices : (NSTimer *)timer {
    NSMutableArray *keysToRemove = [[NSMutableArray alloc]init];
    NSDate *currentDate = [NSDate date];
    CBPeripheral *currentPeripheral = self.connectedPeripherals[self.selectedBluetoothDeviceIndex];
    for (id key in _discoveredDevices) {
        CBPeripheral *peripheral = _discoveredDevices[key];
        if([peripheral.discoveryDate dateByAddingTimeInterval:kLKJExpirationTimeInterval] < currentDate) {
            [keysToRemove addObject:key];
        }
    }
    
    dispatch_async(self.notificationQueue, ^{
        NSNumber *shouldReset = @NO;
        if(self.selectedBluetoothDeviceIndex == NSNotFound) {
            shouldReset = @YES;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName: kLKJShouldRefreshConnectedBluetoothDevicesNotification object:shouldReset];
    });
    
    for (id key in keysToRemove) {
        CBPeripheral *object = _discoveredDevices[key];
        NSInteger index = [_discoveredDevicesArray indexOfObject:object];
        NSInteger section = 0;
        [_discoveredDevices removeObjectForKey:key];
        [_discoveredDevicesArray removeObject:object];
        if([self.connectedPeripherals containsObject:object]) {
            [self.connectedPeripherals removeObject:object];
            section = 1;
        }
        dispatch_async(self.notificationQueue, ^{
            NSDictionary *dictionary = @{@"index" : @(index),
                                         @"section" : @(section)};
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kLKJBluetoothDeviceLostNotification
                                                               object:dictionary];
        });
    }
    
    self.selectedBluetoothDeviceIndex = [self.connectedPeripherals indexOfObject:currentPeripheral];
    if(self.selectedBluetoothDeviceIndex == NSNotFound) {
        self.selectedBluetoothDeviceIndex = 0;
    }

}

- (void)dealloc {
    [self.expirationTimer invalidate];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    for (LKJPeripheral *existingPeripheral in self.historicalDevices) {
        if([existingPeripheral.uuid isEqualToString:peripheral.identifier.UUIDString]) {
            [self.connectedPeripherals addObject:peripheral];
            dispatch_async(self.notificationQueue, ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:kLKJNewBluetoothDeviceDiscoveredNotification object:@(0)];
            });
        }
    }
     if (peripheral.name){
        peripheral.discoveryDate = [NSDate date];
        if(!self.discoveredDevices[peripheral.identifier]) {
            [self.discoveredDevicesArray addObject:peripheral];
            dispatch_async(self.notificationQueue, ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:kLKJNewBluetoothDeviceDiscoveredNotification object:@(1)];
            });
            
        }
        self.discoveredDevices[peripheral.identifier] = peripheral;
        
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    dispatch_async(self.notificationQueue, ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:kLKJUnlockedNotification object:nil];
    });
    NSLog(@"connected");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    dispatch_async(self.notificationQueue, ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:kLKJLockedNotification object:nil];

    });
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (self.centralManager.state) {
        //Because iOS 10 is unreleased we'll ignore deprecation warnings for now.
        case CBCentralManagerStatePoweredOff: {
                
                break;
            }
                
            case CBCentralManagerStateUnauthorized: {
                // Indicate to user that the iOS device does not support BLE.
                break;
            }
                
            case CBCentralManagerStateUnknown: {
                // Wait for another event
                break;
            }
                
            case CBCentralManagerStatePoweredOn: {
                _isOnline = YES;
                [self beginScanning];
                break;
            }
                
            case CBCentralManagerStateResetting:{
                break;
            }
                
            case CBCentralManagerStateUnsupported: {
                break;
            }
                
            default:
                break;
        }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"discovered characteristic");
}

- (CBPeripheral *)peripheralAtIndex:(NSInteger)index {
    return self.discoveredDevicesArray[index];
}

- (NSInteger)numberOfDevices {
    return self.discoveredDevicesArray.count;
}

- (void)selectPeripheralAtIndex:(NSInteger)index {
    CBPeripheral *peripheral = self.discoveredDevicesArray[index];
    
    LKJPeripheral *peripheralPeristed = [[LKJPeripheral alloc]init];
    peripheralPeristed.uuid = peripheral.identifier.UUIDString;
    peripheralPeristed.name = peripheralPeristed.name;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
        
    [realm beginWriteTransaction];
    [realm addObject:peripheralPeristed];
    [realm commitWriteTransaction];

    
    [self.connectedPeripherals addObject:peripheral];
    self.selectedBluetoothDeviceIndex = self.connectedPeripherals.count - 1;
}


- (void)lockDevice {
    if(![self isLocked]) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripherals[self.selectedBluetoothDeviceIndex]];

    }
}

- (void)unlockDevice {
    if([self isLocked]) {
        [self.centralManager connectPeripheral:self.connectedPeripherals[self.selectedBluetoothDeviceIndex] options:nil];
    }
    
}

- (BOOL)isLocked {
    if(self.connectedPeripherals[self.selectedBluetoothDeviceIndex].state == CBPeripheralStateConnected) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)existsBluetoothDevice {
    return (self.connectedPeripherals.count > 0);
}

- (BOOL)isElgibleForLock {
    if(self.selectedBluetoothDeviceIndex < 0) {
        return NO;
    }
    else if(self.connectedPeripherals[self.selectedBluetoothDeviceIndex].state == CBPeripheralStateConnected) {
        return YES;
    }
    else if (self.connectedPeripherals[self.selectedBluetoothDeviceIndex].state == CBPeripheralStateDisconnected) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString *)currentName {
    return self.connectedPeripherals[self.selectedBluetoothDeviceIndex].name;
}

- (BOOL)existsCurrentPeripheral {
    return (self.selectedBluetoothDeviceIndex > 0);
}

- (BOOL)isConnectedToPeripheral : (CBPeripheral *)peripheral {
    return [self.connectedPeripherals containsObject:peripheral];
}

@end
