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

     NSArray *finalArrayToDisplayInTheCells;

    PFObject *group;
     PFUser *currentUser;

}

@end

@implementation FacebookFriendsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

     currentUser = [PFUser currentUser];
    arrayContainingDictionaroesOfTheNameAndUniqueIdOFtheSelectedPersons = [NSMutableArray new];
    arrayWithFriendsWhoDontHaveAnAccount = [NSMutableArray new];
    arrayWithFriendsWhoHaveAnAccount = [NSMutableArray new];
    finalArrayToDisplayInTheCells = [NSArray new];
   
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self gettingFacebookFriends];
    
}

- (void) gettingFacebookFriends {

    // finding out which facebook friends have the app and which dont

    NSMutableArray *arrayWithFacebookIDs = currentUser[@"facebookFriends"];
    NSMutableArray *arrayWithFacebookNames = currentUser[@"facebookFriendNames"];


    // array of dictionaries
    NSMutableArray *array = [NSMutableArray new];


    PFQuery *query = [PFUser query];
    __block NSArray *arrayOFPFUsers;


    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){

        } else {

            // if the query is succesful, create array of dictinaries and also create two seperate arrays for friends who have an account and for those who do not
            //            for (int i = 0; i < arrayWithFacebookIDs.count; i++){

            //                // create the dictinaries
            //                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            //
            //                [dict setObject:arrayWithFacebookIDs[i] forKey:@"ids"];
            //                [dict setObject:arrayWithFacebookNames[i] forKey:@"names"];
            //                [array addObject:dict];

            // populate the two different arrays
            // the query returns PFObjects, but i need to crete an array containig the facebookId's of the PFObjects
            NSMutableArray *arrayWithMyFacebookId = [NSMutableArray new];
            arrayOFPFUsers = objects;
            for (int i = 0; i < arrayOFPFUsers.count; i++) {
                PFUser *user = arrayOFPFUsers[i];
                [arrayWithMyFacebookId addObject:user[@"uniqueFacebookID"]];

            }
            for (int i = 0; i < arrayWithFacebookIDs.count; i++){

                if ([arrayWithMyFacebookId containsObject:arrayWithFacebookIDs[i]]){
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setObject:arrayWithFacebookIDs[i] forKey:@"ids"];
                    [dict setObject:arrayWithFacebookNames[i] forKey:@"name"];
                    [dict setObject:@"yes" forKey:@"InTheGroup"];
                    [arrayWithFriendsWhoHaveAnAccount addObject:dict];

                } else {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setObject:arrayWithFacebookIDs[i] forKey:@"ids"];
                    [dict setObject:arrayWithFacebookNames[i] forKey:@"name"];
                    [dict setObject:@"no" forKey:@"InTheGroup"];
                    [arrayWithFriendsWhoDontHaveAnAccount addObject:dict];

                }

            }

            finalArrayToDisplayInTheCells = [arrayWithFriendsWhoHaveAnAccount arrayByAddingObjectsFromArray:arrayWithFriendsWhoDontHaveAnAccount];
            [tableViewContainingFriends reloadData];
//            [finalArrayToDisplayInTheCells addObject: arrayWithFriendsWhoHaveAnAccount];
//            [finalArrayToDisplayInTheCells addObject: arrayWithFriendsWhoDontHaveAnAccount];
//            [tableViewContainingFriends reloadData];

            
            
            
            
            
            
            
            
        }
    }];
    
    
}

#pragma mark- TableView Delegate methods

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
