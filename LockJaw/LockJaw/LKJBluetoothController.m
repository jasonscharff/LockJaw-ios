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

@property (strong, nonatomic) NSMutableArray<CBPeripheral *> *connectedPeripherals;

@property (nonatomic, strong) NSMutableArray *discoveredDevicesArray;
@property (nonatomic, strong) NSMutableArray *knownDevicesArray;

@property (nonatomic, strong) NSMutableDictionary *discoveredDevicesDictionary;

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
        self.knownDevicesArray = [[NSMutableArray alloc]init];
        
        self.discoveredDevicesDictionary = [[NSMutableDictionary alloc]init];
        
        
        self.connectedPeripherals = [[NSMutableArray alloc]init];
 
        //in known devices because always know device if connected.
        //-1 to show nothing is selected.
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
    NSMutableArray *peripheralsToRemove = [[NSMutableArray alloc]init];
    for (CBPeripheral *peripheral in _discoveredDevicesArray) {
        if([peripheral.discoveryDate dateByAddingTimeInterval:kLKJExpirationTimeInterval] < currentDate) {
            [peripheralsToRemove addObject:peripheral];
        }
    }
    for (CBPeripheral *peripheral in peripheralsToRemove) {
        NSInteger index = [self.discoveredDevicesArray indexOfObject:peripheral];
        [self.discoveredDevicesArray removeObjectAtIndex:index];
        dispatch_async(self.notificationQueue, ^{
            NSDictionary *dictionary = @{@"index" : @(index),
                                         @"section" : @(0)};
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kLKJBluetoothDeviceLostNotification
                                                               object:dictionary];
        });
    }
    
    peripheralsToRemove = [[NSMutableArray alloc]init];
    for (CBPeripheral *peripheral in self.connectedPeripherals) {
        if([peripheral.discoveryDate dateByAddingTimeInterval:kLKJExpirationTimeInterval] < currentDate) {
            [peripheralsToRemove addObject:peripheral];
        }
    }
    
    for (CBPeripheral *peripheral in peripheralsToRemove) {
        NSInteger index = [self.discoveredDevicesArray indexOfObject:peripheral];
        [self.discoveredDevicesArray removeObjectAtIndex:index];
        dispatch_async(self.notificationQueue, ^{
            NSDictionary *dictionary = @{@"index" : @(index),
                                         @"section" : @(1)};
            
            [[NSNotificationCenter defaultCenter]postNotificationName:kLKJBluetoothDeviceLostNotification
                                                               object:dictionary];
        });
    }
    
    self.selectedBluetoothDeviceIndex = [self.connectedPeripherals indexOfObject:currentPeripheral];
    
    dispatch_async(self.notificationQueue, ^{
        NSNumber *shouldReset = @NO;
        if(self.selectedBluetoothDeviceIndex == NSNotFound) {
            shouldReset = @YES;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName: kLKJShouldRefreshConnectedBluetoothDevicesNotification
                                                           object:shouldReset];
        
        if(self.selectedBluetoothDeviceIndex == NSNotFound) {
            self.selectedBluetoothDeviceIndex = -1;
        }
    });
    
}

- (void)dealloc {
    [self.expirationTimer invalidate];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    
     if (peripheral.name){
        peripheral.discoveryDate = [NSDate date];
        if(!self.discoveredDevicesDictionary[peripheral.identifier]) {
            LKJPeripheral *existingPeripheral = [[LKJPeripheral objectsWhere:[NSString stringWithFormat:@"uuid = '%@'", peripheral.identifier.UUIDString]]firstObject];
            
            
            
            if(existingPeripheral) {
                [self.connectedPeripherals addObject:peripheral];
                [self.knownDevicesArray addObject:peripheral];
                dispatch_async(self.notificationQueue, ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:kLKJNewBluetoothDeviceDiscoveredNotification object:@(0)];
                });
                
            } else {
                [self.discoveredDevicesArray addObject:peripheral];
                dispatch_async(self.notificationQueue, ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:kLKJNewBluetoothDeviceDiscoveredNotification object:@(1)];
                });
            }
        }
        self.discoveredDevicesDictionary[peripheral.identifier] = peripheral;
        
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

- (CBPeripheral *)peripheralAtIndex:(NSInteger)index inSection:(NSInteger)section {
    if(section==0) {
        return self.knownDevicesArray[index];
    } else if (section == 1) {
        return self.discoveredDevicesArray[index];
    } else {
        return nil;
    }
}

- (void)selectPeripheralAtIndex:(NSInteger)index inSection:(NSInteger)section {
    CBPeripheral *peripheral;
    if(section == 0) {
        peripheral = self.knownDevicesArray[index];
    } else if (section == 1) {
        peripheral = self.discoveredDevicesArray[index];
        [self.discoveredDevicesArray removeObjectAtIndex:index];
        [self.knownDevicesArray addObject:peripheral];
        LKJPeripheral *peripheralPeristed = [[LKJPeripheral alloc]init];
        peripheralPeristed.uuid = peripheral.identifier.UUIDString;
        peripheralPeristed.name = peripheralPeristed.name;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        [realm beginWriteTransaction];
        [realm addObject:peripheralPeristed];
        [realm commitWriteTransaction];
    } else {
        return;
    }
    
    if(![self.connectedPeripherals containsObject:peripheral]) {
        [self.connectedPeripherals addObject:peripheral];
        self.selectedBluetoothDeviceIndex = self.connectedPeripherals.count - 1;
    } else {
        self.selectedBluetoothDeviceIndex = [self.connectedPeripherals indexOfObject:peripheral];
    }
    

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

- (NSInteger)numberOfDevicesInSection : (NSInteger)section {
    if(section == 0) {
        return self.knownDevicesArray.count;
    } else {
        return self.discoveredDevicesArray.count;
    }
}

@end
