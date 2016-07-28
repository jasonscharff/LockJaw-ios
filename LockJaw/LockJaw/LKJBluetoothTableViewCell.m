//
//  LKJBluetoothTableViewCell.m
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJBluetoothTableViewCell.h"

#import "AutolayoutHelper.h"

@import CoreBluetooth;

@interface LKJBluetoothTableViewCell()

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UIImageView *signalImageView;
@property (nonatomic) UILabel *connectedLabel;


@end

@implementation LKJBluetoothTableViewCell


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
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont systemFontOfSize:16.0f];
    self.signalImageView = [UIImageView new];
    self.connectedLabel = [UILabel new];
    self.connectedLabel.font = [UIFont systemFontOfSize:14.0f];
    
    [AutolayoutHelper configureView:self.contentView
                           subViews:NSDictionaryOfVariableBindings(_nameLabel, _signalImageView, _connectedLabel)
                        constraints:@[@"H:|-4-[_signalImageView]-4-[_nameLabel]",
                                      @"H:[_connectedLabel]-4-|",
                                      @"X:_signalImageView.centerY == superview.centerY",
                                      @"X:_nameLabel.centerY == superview.centerY",
                                      @"X:_nameLabel.centerY == superview.centerY",
                                      @"X:_connectedLabel.centerY == superview.centerY"]];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configureWithPeripheral:(CBPeripheral *)peripheral andRSSI :(NSNumber *)RSSI {
    CGFloat rssiFloat = RSSI.floatValue;
    if(rssiFloat > -77) {
        self.signalImageView.image = [UIImage imageNamed:@"fivebars"];
    } else if (rssiFloat > -86) {
        self.signalImageView.image = [UIImage imageNamed:@"fourbars"];
    } else if (rssiFloat > -97) {
        self.signalImageView.image = [UIImage imageNamed:@"threebars"];
    } else if (rssiFloat > -102) {
        self.signalImageView.image = [UIImage imageNamed:@"twobars"];
    } else {
        self.signalImageView.image = [UIImage imageNamed:@"onebar"];
    }
    self.nameLabel.text = peripheral.name;
    if(peripheral.state == CBPeripheralStateConnected) {
        self.connectedLabel.text = @"Connected";
    } else {
        self.connectedLabel.text = @"Disconnected";
    }
}

@end
