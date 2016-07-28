//
//  LKJHistoryTableViewController.m
//  LockJaw
//
//  Created by Jason Scharff on 7/28/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "LKJHistoryTableViewController.h"

#import "AutolayoutHelper.h"

#import <Realm/Realm.h>

#import "LKJHistory.h"
#import "LKJHistoryTableViewCell.h"

@interface LKJHistoryTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)RLMResults *results;
@property (nonatomic, strong) UITableView *tableView;


@end

static NSString * const kLKJHistoryReuseIdentifier = @"com.lockjaw.tableviewcell.history";


@implementation LKJHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[LKJHistoryTableViewCell class] forCellReuseIdentifier:kLKJHistoryReuseIdentifier];
    self.results = [[LKJHistory allObjects]sortedResultsUsingProperty:@"activatedDate" ascending:NO];
    
    [AutolayoutHelper configureView:self.view fillWithSubView:self.tableView];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LKJHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLKJHistoryReuseIdentifier];
    cell.historyItem = self.results[indexPath.row];
    return cell;
}

@end
