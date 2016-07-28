//
//  LKJCircleView.m
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJCircleView.h"

@implementation LKJCircleView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = MIN(self.bounds.size.height, self.bounds.size.width)/2;
}

@end
