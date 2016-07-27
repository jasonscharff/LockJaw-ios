//
//  LKJLockView.m
//  LockJaw
//
//  Created by Jason Scharff on 7/27/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJLockView.h"

#import "UIColor+LKJColorPalette.h"

#import "AutolayoutHelper.h"

#import <pop/POP.h>

@interface LKJLockView()

@property (nonatomic) UIImageView *topLock;
@property (nonatomic) UIImageView *bottomLock;


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
    
    self.topLock = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"toplock"]];
    self.bottomLock = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bottomlock"]];
    
    UIView *encapsulator = [UIView new];
    [AutolayoutHelper configureView:encapsulator
                           subViews:NSDictionaryOfVariableBindings(_topLock, _bottomLock)
                        constraints:@[@"V:|[_topLock][_bottomLock]|",
                                      @"H:|[_bottomLock]|",
                                      @"X:_topLock.centerX == _bottomLock.centerX"]];
    
    
    [AutolayoutHelper configureView:self
                           subViews:NSDictionaryOfVariableBindings(encapsulator)
                        constraints:@[@"X:encapsulator.centerX == superivew.centerX",
                                      @"X:encapsulator.centerY == superview.centerY",
                                      @"X:encapsulator.height == superview.height * 0.67"]];
    
    
}

- (IBAction)switchLock:(id)sender {
    POPSpringAnimation *colorAnimation = [POPSpringAnimation animation];
    colorAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewBackgroundColor];
    if(self.isLocked) {
        colorAnimation.toValue = (id)[UIColor lkJ_unlockedColor].CGColor;
    } else {
        colorAnimation.toValue = (id)[UIColor lkj_lockedColor].CGColor;
    }
    [self pop_addAnimation:colorAnimation forKey:@"colorAnimation"];
    self.isLocked = !self.isLocked;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height)/2;
}

@end
