//
//  LKJBluetoothTableViewCell.h
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral;

@interface LKJBluetoothTableViewCell : UITableViewCell

- (void)configureWithPeripheral:(CBPeripheral *)peripheral andRSSI :(NSNumber *)RSSI;


@end
