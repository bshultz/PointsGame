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
#import <QuartzCore/QuartzCore.h>

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, NotificationTableViewCellDelegate>

{
    PFUser *currentUser;
    IBOutlet UITableView *tableViewWithNotifications;
    NSMutableArray *arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser;
    UIAlertView *alertIfNoNotificationsPresent;
    UIAlertView *alertIfNoNotificationsPresentInitially;


    BOOL theUserHasNoNotifications;
    BOOL theUserHasNoMoreNotifications;

    // the following int is used to keep track of when all the notifications on the page are deleted
    int numberOFfObjectsInArray;
}

@end

@implementation NotificationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:RED/255.0f green:GREEN/255.0f blue:BLUE/255.0f alpha:1.0f];

    tableViewWithNotifications.backgroundColor = [UIColor clearColor];
    tableViewWithNotifications.separatorColor = [UIColor colorWithRed:0.05f green:0.345f blue:0.65f alpha:0.5f];
    tableViewWithNotifications.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [tableViewWithNotifications setSeparatorInset:UIEdgeInsetsZero];
    
    currentUser = [PFUser currentUser];
    arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser = [[NSMutableArray alloc]init];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    UINavigationItem *bar = self.navigationItem;
    bar.backBarButtonItem.enabled = NO;
 //   self.navigationItem.backBarButtonItem.enabled = NO;

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


            if (objects.count == 0){

                theUserHasNoNotifications = YES;
                [self presentingASeperateViewForNoNotifications];

            }

            for (id object in objects){
                PFObject *group = object[@"group"];

                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:object[@"group"] forKey:@"group"];
                [dict setObject:group.objectId forKey:@"stringContainingId"];
                [dict setObject:object forKey:@"invite"];
                [dict setObject:object[@"fromUser"] forKey:@"fromUser"];

                [arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser addObject:dict];
                [tableViewWithNotifications reloadData];
            }
            self.navigationItem.backBarButtonItem.enabled = YES;
        }

    }];


}

#pragma mark - Custom Delegate for notification tableViewCell

- (void) didWantToDeleteCell: (NotificationTableViewCell*) NewTableViewCell atIndexPath:(NSIndexPath *)indexPath forGroup:(NSString *) groupId{

    NSMutableDictionary *dict = arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser[indexPath.row];
    [arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser removeObject:dict];
    numberOFfObjectsInArray--;
    if(numberOFfObjectsInArray == 0){
                theUserHasNoMoreNotifications = YES;
            }


    [tableViewWithNotifications reloadData];
    
}


#pragma mark - TableView Delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {



    NotificationTableViewCell *cell = [NotificationTableViewCell new];

    NSMutableDictionary *dict = arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser[indexPath.row];

    cell.group = dict[@"group"];
    cell.invite = dict[@"invite"];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.groupID = dict[@"stringContainingId"];

    PFObject *group = dict[@"group"];
    PFUser *fromUser = dict[@"fromUser"];
    NSString *name = fromUser[@"fullName"];
    NSString *groupName = group[@"name"];

    cell.labelContainingGroupInformation.text = [NSString stringWithFormat:@"%@ has invited you to the group '%@'", name, groupName ];

    return cell;




}

- (void) goBackToThePreviousPage {
    [self.navigationController popViewControllerAnimated:YES];

}

- (void) presentingASeperateViewForNoNotifications {
    UIView *newView = [[UIView alloc]initWithFrame:CGRectMake(30, 100, 260, 120)];

    newView.layer.borderWidth = 3.0f;


    newView.layer.borderColor = [UIColor colorWithRed:RED/255.0f green:GREEN/255.0f blue:BLUE/255.0f alpha:1.0f].CGColor;

    UILabel *labelWithText =[[UILabel alloc]initWithFrame:CGRectMake(20.0f, -30.0f, 300.0f, 120.0f)];

    if (theUserHasNoMoreNotifications){
        labelWithText.text =  @"No more notifications present";


    } else {
        labelWithText.text =  @"No notifications present";

        
    }

    [newView addSubview:labelWithText];

    UIButton *buttonToGoBack =  [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonToGoBack.frame = CGRectMake(10.0f, 60.0f, 240, 40);

    UILabel *addLabel = [[UILabel alloc] initWithFrame:(CGRectMake(20.0f, 10.0f, 200.0f, 20.0f))];
     addLabel.text = @"Go to the newsfeed page";

    addLabel.textColor = [UIColor whiteColor];
    [buttonToGoBack addSubview:addLabel];




    [buttonToGoBack setBackgroundImage:[UIImage imageNamed:@"btn_orange_normal.png"] forState:UIControlStateNormal];
    [buttonToGoBack  addTarget:self action:@selector(goBackToThePreviousPage) forControlEvents:UIControlEventTouchUpInside];
    [newView addSubview:buttonToGoBack];

    [self.view addSubview:newView];






}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (numberOFfObjectsInArray == 0 && theUserHasNoMoreNotifications){
        [self presentingASeperateViewForNoNotifications];
    }

    return arraysContainingDictionariesOfInvitesAndGroupsOfTheCurrentUser.count;
}






@end
