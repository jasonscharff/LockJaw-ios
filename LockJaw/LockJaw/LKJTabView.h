//
//  LKJTabView.h
//  LockJaw
//
//  Created by Jason Scharff on 7/26/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LKJTabItem;

typedef void (^buttonPressedBlock)(int index);

@interface LKJTabView : UIView

@property (nonatomic) NSArray<LKJTabItem *>*tabItems;
@property (nonatomic) NSArray <buttonPressedBlock>*actionBlocks;



@end
