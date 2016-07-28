//
//  LKJDateFormatter.h
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKJDateFormatter : NSObject

+ (instancetype)sharedDateFormatter;
- (NSString *)historyDisplayFromDate : (NSDate *)date;

@end
