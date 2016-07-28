//
//  LKJDateFormatter.m
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJDateFormatter.h"

@implementation LKJDateFormatter


+ (instancetype)sharedDateFormatter {
    static dispatch_once_t once;
    static LKJDateFormatter *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[LKJDateFormatter alloc]init];
    });
    return _sharedInstance;
}

+ (NSDateFormatter *)sharedShortTimeFormatter {
    static dispatch_once_t once;
    static NSDateFormatter *_sharedInstance;
    dispatch_once(&once, ^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        _sharedInstance = dateFormatter;
    });
    
    return _sharedInstance;
}

+ (NSDateFormatter *)sharedShortDateFormatter {
    static dispatch_once_t once;
    static NSDateFormatter *_sharedInstance;
    dispatch_once(&once, ^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        _sharedInstance = dateFormatter;
    });
    
    return _sharedInstance;
}

- (NSString *)historyDisplayFromDate : (NSDate *)date {
    if([[NSCalendar currentCalendar] isDateInYesterday:date]) {
        return [[LKJDateFormatter sharedShortTimeFormatter]stringFromDate:date];
    } else {
        return [[LKJDateFormatter sharedShortDateFormatter]stringFromDate:date];
    }
}

@end
