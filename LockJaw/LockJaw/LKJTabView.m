//
//  LKJTabView.m
//  LockJaw
//
//  Created by Jason Scharff on 7/26/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJTabView.h"

#import "AutolayoutHelper.h"

#import "UIColor+LKJColorPalette.h"

#import "LKJCaptionedButton.h"
#import "LKJTabItem.h"

@interface LKJTabView()

@property (nonatomic) UIStackView *stackView;
@property (nonatomic) NSMutableArray *buttonArray;

@end

@implementation LKJTabView

static CGFloat kLKJDefaultSpacing = 4.0f;


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
    [AutolayoutHelper configureView:self fillWithSubView:self.stackView];
    
}

- (void)setTabItems:(NSArray<LKJTabItem *> *)tabItems {
    _tabItems = tabItems;
    self.buttonArray = [[NSMutableArray alloc]initWithCapacity:tabItems.count];
    
    for (int i = 0; i < tabItems.count; i++) {
        LKJTabItem *item = tabItems[i];
        NSLog(@"item.caption = %@", item.caption); 
        LKJCaptionedButton *button = [[LKJCaptionedButton alloc]initWithImage:item.image
                                                                      caption:item.caption
                                                                      spacing:kLKJDefaultSpacing];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
        
        [self.stackView addArrangedSubview:button];
    }
    
}

- (IBAction)buttonClicked:(UIControl *)sender {
    if(self.actionBlock) {
        self.actionBlock(sender.tag);
    }
}

@end
