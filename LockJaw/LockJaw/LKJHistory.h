//
//  LKJHistory.h
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Realm/Realm.h>

@interface LKJHistory : RLMObject

@property NSDate *activatedDate;
@property BOOL isLockAction;
@property NSString *lockName;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<LKJHistory>
RLM_ARRAY_TYPE(LKJHistory)
