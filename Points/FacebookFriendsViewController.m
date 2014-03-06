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
#import <MessageUI/MFMailComposeViewController.h>
#import "NewTableViewCellDelegate.h"
#import "GroupsViewController.h"

@interface FacebookFriendsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, NewTableViewCellDelegate, MFMailComposeViewControllerDelegate>
{

    IBOutlet UITableView *tableViewContainingFriends;

    NSMutableArray *arrayContainingDictionaroesOfTheNameAndUniqueIdOFtheSelectedPersons;
    NSMutableArray *filteredArray;

    NSMutableArray *arrayWithFriendsWhoHaveAnAccount;
    NSMutableArray *arrayWithFriendsWhoDontHaveAnAccount;

     NSArray *finalArrayToDisplayInTheCells;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;

     PFUser *currentUser;

}


@end

@implementation FacebookFriendsViewController

@synthesize group, isANewGroupBeingAdded, arrayWithTheNamesOfTheCurrentMemebersOfTheGroup;


- (void)viewDidLoad
{
    [super viewDidLoad];

     currentUser = [PFUser currentUser];

     searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    tableViewContainingFriends.tableHeaderView = searchBar;

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:RED/255.0f green:GREEN/255.0f blue:BLUE/255.0f alpha:1.0f];


    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;




    arrayContainingDictionaroesOfTheNameAndUniqueIdOFtheSelectedPersons = [NSMutableArray new];
    arrayWithFriendsWhoDontHaveAnAccount = [NSMutableArray new];
    arrayWithFriendsWhoHaveAnAccount = [NSMutableArray new];
    finalArrayToDisplayInTheCells = [NSArray new];
    
    tableViewContainingFriends.separatorColor = [UIColor colorWithRed:0.05f green:0.345f blue:0.65f alpha:0.5f];
    tableViewContainingFriends.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [tableViewContainingFriends setSeparatorInset:UIEdgeInsetsZero];
   
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self gettingFacebookFriends];
    
}

- (void) gettingFacebookFriends {

    // finding out which facebook friends have the app and which dont

    NSMutableArray *arrayWithFacebookIDs = currentUser[@"facebookFriends"];
    NSMutableArray *arrayWithFacebookNames = currentUser[@"facebookFriendNames"];


    PFQuery *query = [PFUser query];
    __block NSArray *arrayOFPFUsers;


    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
              NSLog (@"%@ %@", error, [error userInfo]);

        } else {

            // populate the two different arrays
            // the query returns PFObjects, but i need to crete an array containig the facebookId's of the PFObjects
            NSMutableArray *arrayWithMyFacebookId = [NSMutableArray new];
            arrayOFPFUsers = objects;
            for (int i = 0; i < arrayOFPFUsers.count; i++) {
                PFUser *user = arrayOFPFUsers[i];
                [arrayWithMyFacebookId addObject:user[@"uniqueFacebookID"]];

            }
            for (int i = 0; i < arrayWithFacebookIDs.count; i++){

                 // only enter if person is not already a member of the group

                if (![arrayWithTheNamesOfTheCurrentMemebersOfTheGroup containsObject: arrayWithFacebookNames[i]] || arrayWithTheNamesOfTheCurrentMemebersOfTheGroup == nil) {

                     if ([arrayWithMyFacebookId containsObject:arrayWithFacebookIDs[i]]){



                       NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                       [dict setObject:arrayWithFacebookIDs[i] forKey:@"ids"];
                       [dict setObject:arrayWithFacebookNames[i] forKey:@"name"];
                       [dict setObject:@"yes" forKey:@"InTheGroup"];
                       [arrayWithFriendsWhoHaveAnAccount addObject:dict];


                   }  else {

                       NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                       [dict setObject:arrayWithFacebookIDs[i] forKey:@"ids"];
                       [dict setObject:arrayWithFacebookNames[i] forKey:@"name"];
                       [dict setObject:@"no" forKey:@"InTheGroup"];
                       [arrayWithFriendsWhoDontHaveAnAccount addObject:dict];

                   }
             }

        }

            // need to concatenate the two different arrays in the end because i want the array with users who have an account to show up first

            finalArrayToDisplayInTheCells = [arrayWithFriendsWhoHaveAnAccount arrayByAddingObjectsFromArray:arrayWithFriendsWhoDontHaveAnAccount];
            [tableViewContainingFriends reloadData];

            
        }
    }];
    
    
}

#pragma mark- TableView Delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NewTableViewCell *cell = [[NewTableViewCell alloc]init];

    if (cell == nil) {
        cell = [[NewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    cell.delegate = self;


    id object ;

    if (tableView == searchDisplayController.searchResultsTableView) {

        object = filteredArray[indexPath.row];

    } else {
        object = finalArrayToDisplayInTheCells[indexPath.row];

    }

    cell.group = self.group;
    cell.stringContainingUserID = object[@"ids"];
    cell.currentUser = currentUser;
    cell.labelWithPersonsName.text = object[@"name"];

    if ([object[@"InTheGroup"]isEqualToString:@"yes"]){

        // this person already has an account
        [cell.buttonWithTextToAddOrInvite setTitleColor:[UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
        cell.buttonWithTextToAddOrInvite.exclusiveTouch = YES;
        [cell.buttonWithTextToAddOrInvite setTitle:@"Add" forState:UIControlStateNormal];

    } else if ([object[@"InTheGroup"]isEqualToString:@"no"]) {

        // this person does not have an account
        cell.buttonWithTextToAddOrInvite.exclusiveTouch = YES;
        [cell.buttonWithTextToAddOrInvite setTitle:@"Invite" forState:UIControlStateNormal];
        [cell.buttonWithTextToAddOrInvite setTitleColor:[UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];

        [cell sizeToFit];
        [cell bringSubviewToFront:cell.buttonWithTextToAddOrInvite];
    }


    return cell;
    
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (tableView == searchDisplayController.searchResultsTableView) {
        return [filteredArray count];

    } else {
         return finalArrayToDisplayInTheCells.count;
    }

   }

#pragma mark - NewTableViewCellDelegate methods

- (void) showMailApp {
    if ([MFMailComposeViewController canSendMail]) {

        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Invitation to join the app Points Bank."];
        [mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];

    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {

    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - Content Filtering

// Update the filtered array based on the scope and searchText

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [filteredArray removeAllObjects];

    // Filter the array using NSPredicate
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains [c] %@", searchString];
    filteredArray = [NSMutableArray arrayWithArray:[finalArrayToDisplayInTheCells filteredArrayUsingPredicate:resultPredicate]];

    return YES;
}
- (IBAction)onDoneButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//if the person presses the cancel button, the group that was created needs to be deleted

//- (IBAction)onCancelButtonPressed:(id)sender {
//
//    if(self.isANewGroupBeingAdded) {
//
//    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
//    [query whereKey:@"objectId" equalTo:group.objectId];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if(error) {
//
//        } else {
//            [object deleteInBackground];
//        }
//    }];
//    }
//    [self dismissViewControllerAnimated:YES completion:nil];
//
//}


@end
