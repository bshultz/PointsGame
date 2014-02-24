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

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, NotificationTableViewCellDelegate>

{
    PFUser *currentUser;
    IBOutlet UITableView *tableViewWithNotifications;
    NSMutableArray *arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser;
    int indexOfTheArrayThatNeedsToBeDelted;
    int numberThatNeedsToBeSubtracted;
    UIAlertView *alertIfNoNotificationsPresent;
    BOOL theUserHasNoMoreNotifications;
    int numberOFfObjectsInArray;
}

@end

@implementation NotificationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:.05f green:.345f blue:.65f alpha:1.0f];
    tableViewWithNotifications.backgroundColor = [UIColor clearColor];
    tableViewWithNotifications.separatorColor = [UIColor colorWithRed:0.05f green:0.345f blue:0.65f alpha:0.5f];
    tableViewWithNotifications.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [tableViewWithNotifications setSeparatorInset:UIEdgeInsetsZero];
    
    currentUser = [PFUser currentUser];
    arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser = [[NSMutableArray alloc]init];
    indexOfTheArrayThatNeedsToBeDelted = 0;

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    numberThatNeedsToBeSubtracted = 0;
    [tableViewWithNotifications setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    PFQuery *query = [PFQuery queryWithClassName:@"invite"];

    [query includeKey:@"toUser"];
    [query includeKey:@"fromUser"];
    [query includeKey:@"group"];
    
    [query whereKey:@"toUser" equalTo:currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error){
            NSLog (@"%@ %@", error, [error userInfo]);

        } else {
            numberOFfObjectsInArray = objects.count;
            for (id object in objects){
                PFObject *group = object[@"group"];

                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:object[@"group"] forKey:@"group"];
                [dict setObject:group.objectId forKey:@"stringContainingId"];
                [dict setObject:object forKey:@"invite"];
                [dict setObject:object[@"fromUser"] forKey:@"fromUser"];

                [arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser addObject:dict];
                [tableViewWithNotifications reloadData];
            };
        }

    }];


}

#pragma mark - Custom Delegate for notification tableViewCell

- (void) didWantToDeleteCell: (NotificationTableViewCell*) NewTableViewCell atIndexPath:(NSIndexPath *)indexPath forGroup:(NSString *) groupId{

//    int index = number - numberThatNeedsToBeSubtracted;
//
//    [arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser removeObjectAtIndex:index];
//    number = arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser.count;

    numberThatNeedsToBeSubtracted++;
    numberOFfObjectsInArray--;

    if(numberOFfObjectsInArray == 0){
        theUserHasNoMoreNotifications = YES;
    }

        [tableViewWithNotifications beginUpdates];

//    NSMutableArray *temporaryArray = [NSMutableArray new];
//    for (NSMutableDictionary * dict in arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser){
//
//        if ([dict[@"stringContainingId"] isEqualToString:groupId]){
//            [temporaryArray addObject:dict];
//        }
//
//    }
    NSMutableDictionary *dict = arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser[indexPath.row];
    [arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser removeObject:dict];


//        [tableViewWithNotifications deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableViewWithNotifications reloadData];
 //       [tableViewWithNotifications endUpdates];
    
}

#pragma mark - TableView Delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NotificationTableViewCell *cell = [NotificationTableViewCell new];

    NSMutableDictionary *dict = arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser[indexPath.row];

    

    cell.group = dict[@"group"];
    cell.invite = dict[@"invite"];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.number = indexOfTheArrayThatNeedsToBeDelted;
    cell.groupID = dict[@"stringContainingId"];
    indexOfTheArrayThatNeedsToBeDelted++;

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
                cell.labelContainingGroupInformation.text = [NSString stringWithFormat:@"%@ has invited you to the group '%@'", name, object[@"name"] ];
                [cell.buttonToDeclineTheInvite setTitle:@"Decline" forState:UIControlStateNormal];
                [cell.buttonToAcceptTheInvite setTitle:@"Accept" forState:UIControlStateNormal];
                }
            }];
        }


    }];





    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (numberOFfObjectsInArray == 0 && theUserHasNoMoreNotifications){
        alertIfNoNotificationsPresent = [[UIAlertView alloc] initWithTitle:@"No more notifications" message:nil delegate:self cancelButtonTitle:@"Go to the newsfeed page" otherButtonTitles:nil, nil];
        [alertIfNoNotificationsPresent show];
    }

    return numberOFfObjectsInArray;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



@end
