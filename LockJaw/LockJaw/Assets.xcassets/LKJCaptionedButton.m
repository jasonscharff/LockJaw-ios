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
    
    
    [AutolayoutHelper configureView:self
                           subViews:NSDictionaryOfVariableBindings(_imageView, _captionLabel)
                            metrics: NSDictionaryOfVariableBindings(spacingNumber)
                        constraints:@[@"H:|-(>=0)-[_imageView]-(>=0)-|",
                                      @"H:|-(>=0)-[_captionLabel]-(>=0)-|",
                                      @"V:|[_imageView]-spacingNumber-[_captionLabel]|"]];
    
    return self;
}



@end
