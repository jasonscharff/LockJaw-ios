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
    
    NSNumber *spacingNumber = @(spacing);
    
    self.imageView = [[UIImageView alloc]initWithImage:image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.captionLabel = [UILabel new];
    self.captionLabel.text = caption;
    [self.captionLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    
    [AutolayoutHelper configureView:self
                           subViews:NSDictionaryOfVariableBindings(_imageView, _captionLabel)
                            metrics: NSDictionaryOfVariableBindings(spacingNumber)
                        constraints:@[@"X:_imageView.centerX == superview.centerX",
                                      @"H:|-(>=0)-[_captionLabel]-(>=0)-|",
                                      @"X:_captionLabel.centerX == superview.centerX",
                                      @"V:|-3-[_imageView]-spacingNumber-[_captionLabel]-3-|"]];
    
    return self;
}



@end
