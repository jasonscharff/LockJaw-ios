//
//  LKJBluetoothController.m
//  LockJaw
//
//  Created by Jason Scharff on 7/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJBluetoothController.h"

#import "CBPeripheral+ExpirationDate.h"

@import CoreBluetooth;

static NSString * const kLKJPeripheralUUIDKey = @"com.lockjaw.ble.uuid";
static const int kLKJExpirationTimeInterval = 30;

@interface LKJBluetoothController() <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *peripheralBLE;
@property (strong, nonatomic) NSUUID *deviceID;

@property (nonatomic, strong) NSMutableDictionary *discoveredDevices;
@property (nonatomic, strong) NSMutableArray *discoveredDevicesArray;

@property (nonatomic, strong) NSTimer *expirationTimer;

@property (nonatomic) BOOL isOnline;

@property (nonatomic) dispatch_queue_t notificationQueue;


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
        
        self.deviceID = [[NSUserDefaults standardUserDefaults]objectForKey:kLKJPeripheralUUIDKey];
        self.expirationTimer = [NSTimer timerWithTimeInterval:kLKJExpirationTimeInterval
                                                       target:self
                                                     selector:@selector(removeExpiredDevices:)
                                                     userInfo:nil
                                                      repeats:YES];
        
        self.discoveredDevicesArray = [[NSMutableArray alloc]init];
        self.discoveredDevices = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)beginScanning {
    if(_isOnline) {
      [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)clearDevices {
    self.peripheralBLE = nil;
}

- (void)removeExpiredDevices : (NSTimer *)timer {
    NSMutableArray *keysToRemove = [[NSMutableArray alloc]init];
    NSDate *currentDate = [NSDate date];
    for (id key in _discoveredDevices) {
        CBPeripheral *peripheral = _discoveredDevices[key];
        if([peripheral.discoveryDate dateByAddingTimeInterval:kLKJExpirationTimeInterval] < currentDate) {
            [keysToRemove addObject:key];
        }
    }
    for (id key in keysToRemove) {
        NSObject *object = _discoveredDevices[key];
        NSInteger index = [_discoveredDevicesArray indexOfObject:object];
        [_discoveredDevices removeObjectForKey:key];
        [_discoveredDevicesArray removeObject:object];
        dispatch_async(self.notificationQueue, ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kLKJBluetoothDeviceLostNotification
                                                               object:@(index)];
        });
    }
}

- (void)dealloc {
    [self.expirationTimer invalidate];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if(!peripheral.name) {
        return;
    }
    if(peripheral.identifier == self.deviceID) {
        self.peripheralBLE = peripheral;
        [self.centralManager connectPeripheral:self.peripheralBLE options:nil];
    } else {
        peripheral.discoveryDate = [NSDate date];
        if(!self.discoveredDevices[peripheral.identifier]) {
            [self.discoveredDevicesArray addObject:peripheral];
            dispatch_async(self.notificationQueue, ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:kLKJNewBluetoothDeviceDiscoveredNotification object:nil];
            });
            
        }
        self.discoveredDevices[peripheral.identifier] = peripheral;
        
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self.expirationTimer invalidate];
    self.peripheralBLE.delegate = self;
    [self.peripheralBLE discoverServices:nil];
//    [[NSUserDefaults standardUserDefaults]setObject:peripheral.identifier forKey:kLKJPeripheralUUIDKey];
//    [[NSUserDefaults standardUserDefaults]synchronize];
    dispatch_async(self.notificationQueue, ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:kLKJBluetoothDeviceConnectedNotification object:nil];
    });
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //Send notification
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (self.centralManager.state) {
        //Because iOS 10 is unreleased we'll ignore deprecation warnings for now.
        case CBCentralManagerStatePoweredOff: {
            _isOnline = NO;
                [self clearDevices];
                
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
                
            case CBCentralManagerStateResetting:
            {
                [self clearDevices];
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

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"did discover service");
    NSLog(@"count = %lu", peripheral.services.count);
    for (CBService *service in peripheral.services) {
        [self.peripheralBLE discoverCharacteristics:nil forService:service];
    }
    
}


- (void)selectPeripheralAtIndex:(NSInteger)index {
    CBPeripheral *peripheral = self.discoveredDevicesArray[index];
    self.peripheralBLE = peripheral;
    [self.centralManager connectPeripheral:peripheral options:nil];
}


- (void)lockDevice {
//    NSString *character = @"L";
//    NSData *data = [NSData dataWithBytes:character.UTF8String length:character.length];
    
    NSData  *data	= nil;
    int16_t value	= (int16_t)12;
    
    data = [NSData dataWithBytes:&value length:sizeof (value)];
    
    [self writeData:data];

}

- (void)unlockDevice {
    NSString *character = @"U";
    NSData *data = [NSData dataWithBytes:character.UTF8String length:character.length];
    [self writeData:data];
}

- (void)writeData : (NSData *)data {
    for (CBService *service in self.peripheralBLE.services) {
        NSLog(@"services exist");
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"characteristics exist");
            if(characteristic.properties == CBCharacteristicPropertyWrite) {
                [self.peripheralBLE writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"did write value with error = %@", error);
    for (CBService *service in self.peripheralBLE.services) {
        for (CBCharacteristic *chars in service.characteristics) {
        //    [self.peripheralBLE readValueForCharacteristic:chars];
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error){
        NSLog(@"Update error!!! Characteristic: %@ with error: %@", characteristic.UUID, [error localizedDescription]);
    }else{
        NSData *data = characteristic.value;
        if(data && data.length > 0) {
            NSString *str = [NSString stringWithUTF8String:[data bytes]];
            NSLog(@"Characteristic: %@ -> with value: %@", characteristic.UUID, str);
        } else {
            NSLog(@"data length = 0");
        }

    }
}


@end
