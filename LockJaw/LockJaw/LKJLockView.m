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
    
    [self addSubview:self.topLock];
    [self addSubview:self.bottomLock];
    
    [self addConstraints:@[aspectRatioTop, aspectRatioBottom]];
     
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //Super sketchy due to rotations and lack of time
    //TODO: Make good.
    self.layer.cornerRadius = MIN(self.bounds.size.height, self.bounds.size.width)/2;
    if(self.isLocked) {
        CGFloat bodyXBottom = 20;
        CGFloat bodyWidthBottom = self.frame.size.width- 2 * bodyXBottom;
        CGFloat bodyHeightBottom = self.frame.size.height/3;
        CGFloat bodyYBottom = ((self.frame.size.height - self.frame.size.height/3 - self.frame.size.height/5)/ 2) + (self.frame.size.height/5);
        
        
        CGFloat bodyXTop = 30;
        CGFloat bodyWidthTop = self.frame.size.width - 2 * bodyXTop;
        CGFloat bodyHeightTop = self.frame.size.height/5;
        
        
        CGFloat bodyYTop = (self.frame.size.height - self.frame.size.height/3 - self.frame.size.height/5)/ 2;
        
        self.topLock.frame = CGRectMake(bodyXTop, bodyYTop, bodyWidthTop, bodyHeightTop);
        self.bottomLock.frame = CGRectMake(bodyXBottom, bodyYBottom, bodyWidthBottom, bodyHeightBottom);
        
    }
    
}

- (void)changeLockStatus {
    POPBasicAnimation *colorAnimation = [POPBasicAnimation animation];
    colorAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewBackgroundColor];
    colorAnimation.duration = 0.5;
    self.isLocked = !self.isLocked;
    if(!self.isLocked) {
        colorAnimation.toValue = (id)[UIColor lkJ_unlockedColor].CGColor;
        
        //This works. I don't know why. We'll move on for now.
        CGFloat bodyXTop = 100;
        CGFloat bodyWidthTop = self.frame.size.width - 2 * bodyXTop;
        CGFloat bodyHeightTop = self.frame.size.height/5;
        
        
        CGFloat bodyYTop = (self.frame.size.height - self.frame.size.height/3 - self.frame.size.height/5)/ 2 + 11;
        
        self.topLock.frame = CGRectMake(bodyXTop, bodyYTop, bodyWidthTop, bodyHeightTop);
        [self layoutSubviews];
        
        self.topLock.transform = CGAffineTransformMakeRotation(kLKJRotationAmount);
    } else {
        colorAnimation.toValue = (id)[UIColor lkj_lockedColor].CGColor;
        
        self.topLock.transform = CGAffineTransformRotate(self.topLock.transform, -kLKJRotationAmount);
    }
    [self layoutSubviews];
    
    [self pop_addAnimation:colorAnimation forKey:@"colorAnimation"];
}



@end
