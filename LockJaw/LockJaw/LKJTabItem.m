//
//  LKJTabItem.m
//  LockJaw
//
//  Created by Jason Scharff on 7/26/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJTabItem.h"

@implementation LKJTabItem

- (instancetype)initWithImage : (UIImage *)image andCaption : (NSString *)caption {
    self = [super init];
    
    self.image = image;
    self.caption = caption;
    
    return self;
}

@end
