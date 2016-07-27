//
//  LKJCaptionedButton.h
//  LockJaw
//
//  Created by Jason Scharff on 7/26/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LKJCaptionedButton : UIControl

- (instancetype)initWithImage : (UIImage *)image
                      caption : (NSString *)caption
                      spacing : (CGFloat)spacing;

@property (nonatomic) UIColor *selectedColor; //defaults to white
@property (nonatomic) UIColor *standardColor; //defaults to black.


@end
