//
//  CBPeripheral+ExpirationDate.m
//  LockJaw
//
//  Created by Jason Scharff on 7/23/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "CBPeripheral+ExpirationDate.h"

#import <objc/runtime.h>


@implementation CBPeripheral(ExpirationDate)

@dynamic discoveryDate;

- (void)setDiscoveryDate:(NSDate *)discoveryDate {
    objc_setAssociatedObject(self, @selector(discoveryDate), discoveryDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)discoveryDate {
    return objc_getAssociatedObject(self, @selector(discoveryDate));
}

@end
