//
//  LKJHistoryTableViewCell.h
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LKJHistory;


@interface LKJHistoryTableViewCell : UITableViewCell

@property (nonatomic, strong) LKJHistory *historyItem;

@end
