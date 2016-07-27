//
//  LKJCaptionedButton.m
//  LockJaw
//
//  Created by Jason Scharff on 7/26/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJCaptionedButton.h"

#import "AutolayoutHelper.h"

@interface LKJCaptionedButton()

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *captionLabel;

@end

@implementation LKJCaptionedButton

//Designated initializer
- (instancetype)initWithImage : (UIImage *)image
                      caption : (NSString *)caption
                      spacing : (CGFloat)spacing {
    self = [super init];
    
    self.standardColor = [UIColor blackColor];
    self.selectedColor = [UIColor whiteColor];
    
    NSNumber *spacingNumber = @(spacing);
    
    self.imageView = [[UIImageView alloc]initWithImage:image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.tintColor = self.standardColor;
    
    self.captionLabel = [UILabel new];
    self.captionLabel.text = caption;
    self.captionLabel.font = [UIFont systemFontOfSize:12];
    self.captionLabel.textColor = self.standardColor;
    [self.captionLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    
    [AutolayoutHelper configureView:self
                           subViews:NSDictionaryOfVariableBindings(_imageView, _captionLabel)
                            metrics: NSDictionaryOfVariableBindings(spacingNumber)
                        constraints:@[@"X:_imageView.centerX == superview.centerX",
                                      @"H:|-(>=0)-[_captionLabel]-(>=0)-|",
                                      @"X:_captionLabel.centerX == superview.centerX",
                                      @"V:|-3-[_imageView]-(>=spacingNumber)-[_captionLabel]-3-|"]];
    
    NSLayoutConstraint *imageHeight = [NSLayoutConstraint constraintWithItem:self.imageView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationLessThanOrEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0.5
                                                                    constant:0];
    [self addConstraint:imageHeight];
    
    
    return self;
}

- (void)setStandardColor:(UIColor *)standardColor {
    _standardColor = standardColor;
    if(!self.selected) {
        self.captionLabel.textColor = self.standardColor;
        self.imageView.tintColor = self.standardColor;
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    if(self.selected) {
        self.captionLabel.textColor = self.selectedColor;
        self.imageView.tintColor = self.selectedColor;
    }
}

- (void)setSelected:(BOOL)selected {
    if(selected) {
        self.captionLabel.textColor = self.selectedColor;
        self.imageView.tintColor = self.selectedColor;
    } else {
        self.captionLabel.textColor = self.standardColor;
        self.imageView.tintColor = self.standardColor;
    }
    
}



@end
