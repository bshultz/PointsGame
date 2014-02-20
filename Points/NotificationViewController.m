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
    NSMutableArray *arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser;
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
    currentUser = [PFUser currentUser];
    arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser = [[NSMutableArray alloc]init];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [tableViewWithNotifications setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    PFQuery *query = [PFQuery queryWithClassName:@"invite"];

    [query includeKey:@"toUser"];
    [query includeKey:@"fromUser"];
    
    [query whereKey:@"toUser" equalTo:currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error){
            NSLog (@"%@ %@", error, [error userInfo]);

        } else {
            for (id object in objects){
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:object[@"group"] forKey:@"group"];
                [dict setObject:object forKey:@"invite"];
                [dict setObject:object[@"fromUser"] forKey:@"fromUser"];

                [arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser addObject:dict];
                [tableViewWithNotifications reloadData];
            };
        }

    }];


}

#pragma mark - TableView Delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NotificationTableViewCell *cell = [NotificationTableViewCell new];

    NSMutableDictionary *dict = arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser[indexPath.row];

    cell.group = dict[@"group"];
    cell.invite = dict[@"invite"];

    PFUser *user = dict[@"fromUser"];
    PFObject *group = dict[@"group"];

    __block NSString *name;


    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:user.objectId];
    [userQuery includeKey:@"fromUser"];
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error){
            NSLog (@"%@ %@", error, [error userInfo]);
        } else {
           name = object[@"fullName"];
            PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
            [groupQuery whereKey:@"objectId" equalTo:group.objectId];
            [groupQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (error){
                    NSLog (@"%@ %@", error, [error userInfo]);


                } else {
                cell.labelContainingGroupInformation.text = [NSString stringWithFormat:@"%@ has invited you to the group %@", name, object[@"name"] ];
                [cell.buttonToDeclineTheInvite setTitle:@"Decline" forState:UIControlStateNormal];
                [cell.buttonToAcceptTheInvite setTitle:@"Accept" forState:UIControlStateNormal];
                }
            }];
        }


    }];





    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser.count;
}


@end
