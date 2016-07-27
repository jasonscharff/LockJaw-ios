//
//  UIColor+LKJColorPalette.m
//  LockJaw
//
//  Created by Jason Scharff on 7/26/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "UIColor+LKJColorPalette.h"


@implementation UIColor(LKJColorPalette)

+ (instancetype)lkj_goldColor {
    return [UIColor colorWithRed:215.f/255.f
                           green:212.f/255.f
                            blue:204.f/255.f
                           alpha:1.0];
}


+ (instancetype)lkj_navyColor {
    return [UIColor colorWithRed:44.f/255.f
                           green:62.f/255.f
                            blue:80.f/255.f
                           alpha:1.0];
}

+ (instancetype)lkj_lockedColor {
    return [UIColor colorWithRed:162.f/255.f
                           green:0.f/255.f
                            blue:37.f/255.f
                           alpha:1.0];
}

+ (instancetype)lkJ_unlockedColor {
    return [UIColor colorWithRed:71.f/255.f
                           green:151.f/255.f
                            blue:65.f/255.f
                           alpha:1.0];
}


@end
