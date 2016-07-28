//
//  LKJHistoryTableViewCell.m
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJHistoryTableViewCell.h"

#import "AutolayoutHelper.h"

#import "UIColor+LKJColorPalette.h"

#import "LKJCircleView.h"
#import "LKJHistory.h"
#import "LKJDateFormatter.h"

@interface LKJHistoryTableViewCell()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) LKJCircleView *circleView;
@property (nonatomic, strong) UILabel *capsusName;

@end

@implementation LKJHistoryTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self commonInit];
    }
    return self;
}

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
    self.dateLabel = [UILabel new];
    self.dateLabel.font = [UIFont systemFontOfSize:14.0f];
    self.capsusName.font = [UIFont systemFontOfSize:16.0f];
    self.circleView = [[LKJCircleView alloc]init];
    
    UIView *encapsulator = [UIView new];
    
    [AutolayoutHelper configureView:encapsulator
                           subViews:NSDictionaryOfVariableBindings(_dateLabel, _circleView, _capsusName)
                        constraints:@[@"H:|-4-[_circleView]-4-[_capsusName]",
                                      @"H:[_dateLabel]-4-|",
                                      @"X:_capsusName.centerY == superview.centerY",
                                      @"V:|-2-[_dateLabel]",
                                      @"V:|-2-[_circleView]-2-|"]];
    
    NSLayoutConstraint *circleAspect = [NSLayoutConstraint constraintWithItem:self.circleView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.circleView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:1.0
                                                                     constant:0];
    
    [encapsulator addConstraint:circleAspect];
    
    UIView *spacer = [UIView new];
    spacer.backgroundColor = [UIColor clearColor];
    
    [AutolayoutHelper configureView:self.contentView
                           subViews:NSDictionaryOfVariableBindings(encapsulator, spacer)
                        constraints:@[@"H:|[spacer]|", @"H:|[encapsulator]|", @"V:|[encapsulator][spacer(10)]|"]];
    
    
    
}

- (void)setHistoryItem:(LKJHistory *)historyItem {
    _historyItem = historyItem;
    if(historyItem.isLockAction) {
        self.circleView.backgroundColor = [UIColor lkj_lockedColor];
    } else {
        self.circleView.backgroundColor = [UIColor lkJ_unlockedColor];
    }
    self.dateLabel.text = [[LKJDateFormatter sharedDateFormatter]historyDisplayFromDate:historyItem.activatedDate];
    self.capsusName.text = historyItem.lockName;
}


@end
