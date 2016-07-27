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

static CGFloat const kLKJRotationAmount = M_PI_4;


@interface LKJLockView()

@property (nonatomic) UIImageView *topLock;
@property (nonatomic) UIImageView *bottomLock;
@property (nonatomic) UIView *encapsulatorView;


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
    self.backgroundColor = [UIColor lkj_lockedColor];
    
    UIImage *bottomLockImage = [UIImage imageNamed:@"bottomlock"];
    UIImage *topLockImage = [UIImage imageNamed:@"toplock"];
    self.isLocked = YES;
    
    self.topLock = [[UIImageView alloc]initWithImage:topLockImage];
    self.topLock.contentMode = UIViewContentModeScaleAspectFit;
    self.topLock.backgroundColor = [UIColor yellowColor];
    [self.topLock.layer setAnchorPoint:CGPointMake(1, 1)];
    
    self.bottomLock = [[UIImageView alloc]initWithImage:bottomLockImage];
    self.bottomLock.contentMode = UIViewContentModeScaleAspectFit;
    
    
    NSLayoutConstraint *aspectRatioBottom = [NSLayoutConstraint constraintWithItem:self.bottomLock
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomLock
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:bottomLockImage.size.height/bottomLockImage.size.width
                                                                          constant:0];
    
    NSLayoutConstraint *aspectRatioTop = [NSLayoutConstraint constraintWithItem:self.topLock
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.topLock
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:topLockImage.size.height/topLockImage.size.width
                                                                       constant:0];
    
    NSLayoutConstraint *vertical = [NSLayoutConstraint constraintWithItem:self.topLock
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomLock
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0];
    
    
    self.encapsulatorView = [UIView new];
    self.encapsulatorView.translatesAutoresizingMaskIntoConstraints = YES;
    self.encapsulatorView.backgroundColor = [UIColor redColor];
    [AutolayoutHelper configureView:_encapsulatorView
                           subViews:NSDictionaryOfVariableBindings(_topLock, _bottomLock)
                        constraints:@[@"V:|[_topLock][_bottomLock]|",
                                      @"X:_topLock.width==_bottomLock.width*0.8",
                                      @"H:|[_bottomLock]|",
                                      @"X:_topLock.centerX == _bottomLock.centerX"]];
    
    [_encapsulatorView addConstraints:@[aspectRatioTop, aspectRatioBottom]];
    
    
    [AutolayoutHelper configureView:self
                           subViews:NSDictionaryOfVariableBindings(_encapsulatorView)
                        constraints:@[@"X:_encapsulatorView.centerX == superview.centerX",
                                      @"X:_encapsulatorView.centerY == superview.centerY",
                                      @"X:_encapsulatorView.height == superview.height*0.67"]];
    
    
}

- (void)changeLockStatus {
    POPBasicAnimation *colorAnimation = [POPBasicAnimation animation];
    colorAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewBackgroundColor];
    colorAnimation.duration = 0.5;
    self.isLocked = !self.isLocked;
    if(!self.isLocked) {
        colorAnimation.toValue = (id)[UIColor lkJ_unlockedColor].CGColor;
        self.topLock.transform = CGAffineTransformRotate(self.topLock.transform, M_PI_4);
    } else {
        colorAnimation.toValue = (id)[UIColor lkj_lockedColor].CGColor;
        self.topLock.transform = CGAffineTransformRotate(self.topLock.transform, -M_PI_4);
    }
    
    [self pop_addAnimation:colorAnimation forKey:@"colorAnimation"];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height)/2;
    


}

@end
