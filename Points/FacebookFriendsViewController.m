//
//  FacebookFriendsViewController.m
//  Points
//
//  Created by Siddharth Sukumar on 2/21/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "FacebookFriendsViewController.h"
#import "NewTableViewCell.h"
#import "Parse/Parse.h"

@interface FacebookFriendsViewController () <UITableViewDataSource, UITableViewDelegate>
{

    IBOutlet UITableView *tableViewContainingFriends;

    NSMutableArray *arrayContainingDictionaroesOfTheNameAndUniqueIdOFtheSelectedPersons;
    NSMutableArray *arrayWithFriendsWhoHaveAnAccount;
    NSMutableArray *arrayWithFriendsWhoDontHaveAnAccount;

     NSMutableArray *finalArrayToDisplayInTheCells;

    PFObject *group;
     PFUser *currentUser;

}

@end

@implementation FacebookFriendsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

     currentUser = [PFUser currentUser];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];

    id object = finalArrayToDisplayInTheCells[indexPath.row];
    cell.group = group;
    cell.stringContainingUserID = object[@"uniqueID"];
    cell.currentUser = currentUser;
    cell.textfield.text = object[@"name"];
    if ([object[@"InTheGroup"]isEqualToString:@"yes"]){
        // this person already has an account
        [cell.buttonWithTextToAddOrInvite setTitleColor:[UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
        [cell.buttonWithTextToAddOrInvite setTitle:@"Add" forState:UIControlStateNormal];
    } else if ([object[@"InTheGroup"]isEqualToString:@"no"]) {
        // this person does not have an account
        [cell.buttonWithTextToAddOrInvite setTitle:@"Invite" forState:UIControlStateNormal];
        [cell.buttonWithTextToAddOrInvite setTitleColor:[UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];

        [cell sizeToFit];
        [cell bringSubviewToFront:cell.buttonWithTextToAddOrInvite];
    }


    return cell;
    
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return finalArrayToDisplayInTheCells.count;
}


@end
