//
//  LKJTabView.m
//  LockJaw
//
//  Created by Jason Scharff on 7/26/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJTabView.h"

#import "UIColor+LKJColorPalette.h"

#import "LKJCaptionedButton.h"

@interface LKJTabView()

@property (nonatomic) UIStackView *stackView;

@end

@implementation LKJTabView


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
    self.backgroundColor = [UIColor lkj_goldColor];
    
    self.stackView = [[UIStackView alloc]init];
    self.stackView.axis = UILayoutConstraintAxisHorizontal;
    self.stackView.distribution = UIStackViewDistributionFillEqually;
}

- (void)setTabItems:(NSArray<LKJTabItem *> *)tabItems {
    _tabItems = tabItems;
    for (LKJTabItem *item in tabItems) {
        
    }
    
}

@end
