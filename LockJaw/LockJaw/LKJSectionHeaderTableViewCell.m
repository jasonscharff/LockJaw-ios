//
//  LKJSectionHeaderTableViewCell.m
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJSectionHeaderTableViewCell.h"

#import "AutolayoutHelper.h"

@interface LKJSectionHeaderTableViewCell()

@property (nonatomic, strong) UILabel *mainLabel;

@end

@implementation LKJSectionHeaderTableViewCell

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
    self.backgroundColor = [UIColor clearColor];
    self.mainLabel = [UILabel new];
    UIView *encapsulator = [UIView new];
    encapsulator.backgroundColor = [UIColor whiteColor];
    encapsulator.layer.cornerRadius = 10.0f;
    encapsulator.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.0f;
    UIView *spacer = [UIView new];
    spacer.backgroundColor = [UIColor clearColor];
    self.mainLabel.font = [UIFont systemFontOfSize:20];
    [AutolayoutHelper configureView:encapsulator
                           subViews:NSDictionaryOfVariableBindings(_mainLabel)
                        constraints:@[@"H:|-4-[_mainLabel]-(>=0)-|", @"V:|-4-[_mainLabel]-4-|"]];
    
    [AutolayoutHelper configureView:self.contentView
                           subViews:NSDictionaryOfVariableBindings(encapsulator, spacer)
                        constraints:@[@"H:|[encapsulator]|",
                                      @"H:|[spacer]|",
                                      @"V:|[encapsulator][spacer(10)]|"]];
    
}

- (void)setText:(NSString *)text {
    self.mainLabel.text = text;
}

@end
