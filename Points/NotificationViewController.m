//
//  NotificationViewController.m
//  Points
//
//  Created by Siddharth Sukumar on 2/18/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "NotificationViewController.h"
#import "Parse/Parse.h"
#import "NotificationTableViewCell.h"

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate>

{
    PFUser *currentUser;
    IBOutlet UITableView *tableViewWithNotifications;
}

@end

@implementation NotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [tableViewWithNotifications setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

#pragma mark - TableView Delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NotificationTableViewCell *cell = [NotificationTableViewCell new];

    cell.labelContainingGroupInformation.text = @"Sid Reddy has invited you to the Group Party";
    [cell.buttonToDeclineTheInvite setTitle:@"Decline" forState:UIControlStateNormal];
    [cell.buttonToAcceptTheInvite setTitle:@"Accept" forState:UIControlStateNormal];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


@end
