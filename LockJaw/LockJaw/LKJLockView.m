//
//  LKJLockView.m
//  LockJaw
//
//  Created by Jason Scharff on 7/27/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJLockView.h"

#import "UIColor+LKJColorPalette.h"

@interface LKJLockView()


@end

@implementation LKJLockView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self addTarget:self action:@selector(switchLock:) forControlEvents:UIControlEventTouchDown];
    
}

- (IBAction)switchLock:(id)sender {
    if(self.isLocked) {
        self.backgroundColor = [UIColor lkJ_unlockedColor];
    } else {
        self.backgroundColor = [UIColor lkj_lockedColor];
    }
    self.isLocked = !self.isLocked;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height)/2;
}

@end
