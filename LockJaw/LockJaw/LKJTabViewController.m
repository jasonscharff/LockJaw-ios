//
//  LKJTabViewController.m
//  LockJaw
//
//  Created by Jason Scharff on 7/26/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJTabViewController.h"

#import "AutolayoutHelper.h"

#import "UIColor+LKJColorPalette.h"

#import "LKJBluetoothController.h"
#import "LKJConnectionViewController.h"
#import "LKJLockViewController.h"
#import "LKJTabItem.h"
#import "LKJTabView.h"


@interface LKJTabViewController ()

@property (nonatomic) LKJTabView *tabView;
@property (nonatomic) UIViewController *currentContentViewController;
@property (nonatomic) UIView *contentView;

@property (nonatomic) NSArray<UIViewController *> *viewControllers;

@end

static const CGFloat kLKJStandardSpacing = 20.f;


@implementation LKJTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView = [UIView new];
    self.tabView = [[LKJTabView alloc]init];
    self.tabView.layer.cornerRadius = 12.0f;
    
    LKJTabItem *control = [[LKJTabItem alloc]init];
    control.caption = @"Control";
    control.image = [UIImage imageNamed:@"control"];
    
    UIViewController *controlVC = [[LKJLockViewController alloc]init];
    
    LKJTabItem *connect = [[LKJTabItem alloc]init];
    connect.caption = @"Connect";
    connect.image = [UIImage imageNamed:@"connect"];
    
    LKJConnectionViewController *connectVC = [[LKJConnectionViewController alloc]init];
    
    LKJTabItem *history = [[LKJTabItem alloc]init];
    history.caption = @"History";
    history.image = [UIImage imageNamed:@"history"];
    
    UIViewController *historyVC = [[UIViewController alloc]init];
    
    LKJTabItem *settings = [[LKJTabItem alloc]init];
    control.caption = @"Settings";
    control.image = [UIImage imageNamed:@"settings"];
    
    UIViewController *settingsVC = [[UIViewController alloc]init];
    
    self.tabView.tabItems = @[control, connect, history, settings];
    self.viewControllers = @[controlVC, connectVC, historyVC, settingsVC];
    
    
    self.view.backgroundColor = [UIColor lkj_navyColor];
    NSNumber *standardSpacing = @(kLKJStandardSpacing);
    NSNumber *halfSpacing = @(kLKJStandardSpacing/2);
    NSNumber *largeSpacing = @(kLKJStandardSpacing * 1.5);
    NSNumber *tabBarHeight = @(kLKJStandardTabViewHeight);
    
    [AutolayoutHelper configureView:self.view
                           subViews:NSDictionaryOfVariableBindings(_tabView, _contentView)
                            metrics:NSDictionaryOfVariableBindings(standardSpacing, halfSpacing, largeSpacing, tabBarHeight)
                        constraints:@[@"H:|-standardSpacing-[_contentView]-standardSpacing-|",
                                      @"V:|-standardSpacing-[_contentView]-standardSpacing-[_tabView(tabBarHeight)]-largeSpacing-|",
                                      @"H:|-halfSpacing-[_tabView]-halfSpacing-|"]];
    
    
    __weak typeof(self) weakSelf = self;
    
    self.tabView.actionBlock = ^void(NSInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf.currentContentViewController) {
            [strongSelf.currentContentViewController.view removeFromSuperview];
            [strongSelf.currentContentViewController removeFromParentViewController];
            [strongSelf.currentContentViewController didMoveToParentViewController:nil];
        }
        strongSelf.currentContentViewController = strongSelf.viewControllers[index];
        [strongSelf addChildViewController:strongSelf.currentContentViewController];
        [strongSelf.currentContentViewController didMoveToParentViewController:strongSelf];
        
        [AutolayoutHelper configureView:strongSelf.contentView
                        fillWithSubView:strongSelf.currentContentViewController.view];
        
    };
    
    
    if([[LKJBluetoothController sharedBluetoothController]existsBluetoothDevice]) {
        self.tabView.actionBlock(0);
    } else {
        self.tabView.actionBlock(1);
    }
    
                                 
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
