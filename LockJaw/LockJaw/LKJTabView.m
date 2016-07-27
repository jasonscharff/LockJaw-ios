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

@property (nonatomic) LKJCaptionedButton *selectedButton;

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
        UIImage *modifiedImage = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        LKJCaptionedButton *button = [[LKJCaptionedButton alloc]initWithImage:modifiedImage
                                                                      caption:item.caption
                                                                      spacing:kLKJDefaultSpacing];
        button.standardColor = [UIColor lkj_navyColor];
        button.selectedColor = [UIColor lkj_lightNavyColor];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
        
        [self.buttonArray addObject:button];
        
        [self.stackView addArrangedSubview:button];
    }
    
}

- (IBAction)buttonClicked:(LKJCaptionedButton *)sender {
    if(self.actionBlock) {
        if(self.selectedButton) {
            self.selectedButton.selected = NO;
        }
        sender.selected = YES;
        self.selectedButton = sender;
        self.actionBlock(sender.tag);
    }
}

- (void)selectButtonAtIndex : (NSInteger)index {
    [self buttonClicked:self.buttonArray[index]];
}

@end
