//
//  CBPeripheral+ExpirationDate.h
//  LockJaw
//
//  Created by Jason Scharff on 7/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;

@interface CBPeripheral(ExpirationDate)

@property (nonatomic, strong) NSDate *discoveryDate;

@end
