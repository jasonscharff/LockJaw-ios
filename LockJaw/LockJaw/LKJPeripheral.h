//
//  LKJPeripheral.h
//  LockJaw
//
//  Created by Jason Scharff on 7/27/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Realm/Realm.h>

@interface LKJPeripheral : RLMObject

//Persist connected devices.
@property NSString *uuid;
@property NSString *name;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<LKJPeripheral>
RLM_ARRAY_TYPE(LKJPeripheral)
