//
//  CreateGroupViewController.m
//  Points
//
//  Created by Matthew Graham on 2/10/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "Parse/Parse.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "NewTableViewCell.h"
#import "FacebookFriendsViewController.h"


@interface CreateGroupViewController () < UIAlertViewDelegate, FBFriendPickerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    PFObject *group;
    UITextField *groupTextField;
    PFUser *currentUser;
    UIButton *addButton;
    UIAlertView *personDoesNotHaveAnAccount;
    UIAlertView *personDoesHaveAnAccount;
    PFUser *userFoundInDatabase;
    NSMutableArray *arrayContainingFacebookFriendsThatAreSelected;
    NSMutableArray *arrayContainingDictionaroesOfTheNameAndUniqueIdOFtheSelectedPersons;
    NSMutableArray *arrayWithFriendsWhoHaveAnAccount;
    NSMutableArray *arrayWithFriendsWhoDontHaveAnAccount;

    NSMutableArray *finalArrayToDisplayInTheCells;




    
    
    IBOutlet UITableView *tableViewContaingFriends;
}

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property (nonatomic, strong) FBFriendPickerViewController *friendPickerController;

@end

@implementation CreateGroupViewController

@synthesize addressBookController;;



- (void)viewDidLoad
{
    [super viewDidLoad];
    currentUser = [PFUser currentUser];
    arrayContainingFacebookFriendsThatAreSelected = [[NSMutableArray alloc]init];
    arrayContainingDictionaroesOfTheNameAndUniqueIdOFtheSelectedPersons = [NSMutableArray new];
    finalArrayToDisplayInTheCells = [NSMutableArray new];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [tableViewContaingFriends setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    arrayWithFriendsWhoDontHaveAnAccount = [NSMutableArray new];
    arrayWithFriendsWhoHaveAnAccount = [NSMutableArray new];

    if (arrayContainingDictionaroesOfTheNameAndUniqueIdOFtheSelectedPersons.count != 0){
        // tableViews do not show up because the number of cells will be zero

        [groupTextField removeFromSuperview];
        [addButton removeFromSuperview];
    
        // query the database to see which objects in the array returned from FBPickerController are in the database.
        
        for (id dict in arrayContainingDictionaroesOfTheNameAndUniqueIdOFtheSelectedPersons){
            // object is a dictionary
            NSString *name = dict[@"name"];
            NSString *uniqueID = dict[@"uniqueID"];
            
        PFQuery *query = [PFUser query];

        [query whereKey:@"uniqueFacebookID" equalTo:uniqueID];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (error || !object){
                NSLog(@"this does not work");
                // this person does not have an account
                [dict addObject:@"2" forKey:@"number"];
                
                [arrayWithFriendsWhoDontHaveAnAccount addObject:dict];
                [self addFriendsToTheFinalArray: arrayWithFriendsWhoDontHaveAnAccount];
                [tableViewContaingFriends reloadData];
                
            }
             else {
                
                // this person has an account
                
                [dict addObject:@"1" forKey:@"number"];
                
                [arrayWithFriendsWhoHaveAnAccount addObject:dict];
                [self addFriendsToTheFinalArray: arrayWithFriendsWhoHaveAnAccount];
                 [tableViewContaingFriends reloadData];
                
             }
            
//            [finalArrayToDisplayInTheCells addObject:object];
//            [self sortTheFinalArray];
//            [tableViewContaingFriends reloadData];

            
        }];
        
        }
        
        
        
        
         //        [tableViewContaingFriends reloadData];
        

        
    } else {
        //

    groupTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 75.0f, 240.0f, 30.0f)];
    groupTextField.placeholder = @"Group Name";
    groupTextField.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:23.0f];
    [groupTextField setBorderStyle:UITextBorderStyleRoundedRect];
    addButton = [[UIButton alloc] initWithFrame:CGRectMake(270.0f, 75.0f, 40.0f, 30.0f)];
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [self.view addSubview:groupTextField];
    [self.view addSubview:addButton];
    
        [addButton addTarget:self action:@selector(onAddButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}



- (void) addFriendsToTheFinalArray: (NSMutableArray *)array {
    
    [finalArrayToDisplayInTheCells addObjectsFromArray:arrayWithFriendsWhoHaveAnAccount];
    [finalArrayToDisplayInTheCells addObjectsFromArray:arrayWithFriendsWhoDontHaveAnAccount];
    
//    NSSet *setForFriendsWhHaveAnAccount
    
    [arrayWithFriendsWhoHaveAnAccount removeLastObject];
     [arrayWithFriendsWhoDontHaveAnAccount removeLastObject];
    
}

//- (IBAction)onAddOrInviteButtonPressed:(UIButton *)sender {
//    
//    if([sender.titleLabel.text isEqualToString:@"Add"]){
//        PFRelation *relation = [group relationForKey:@"members"];
//
//        [relation addObject:userFoundInDatabase];
//        [group saveInBackground];
//
//        
//    }  else {
//        
//    }
//    
//    
//}


-(void)onAddButtonPressed:(id) sender
{
    if (![groupTextField.text isEqual: @""])
    {
        group = [PFObject objectWithClassName:@"Group"];

        group[@"name"] = groupTextField.text;
        PFRelation *relation = [group relationForKey:@"members"];
        [relation addObject:currentUser];
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (!error)
            {
                NSLog(@"Group Saved");
                PFRelation *relation1 = [currentUser relationForKey:@"myGroups"];
                [relation1 addObject:group];
                [currentUser saveInBackground];
            }
            else
            {
                NSLog(@"Error: %@", error);
            }
        }];
        [groupTextField resignFirstResponder];
    }

   // [self gettingFacebookFriends:sender];
    [self performSegueWithIdentifier:@"FacebookFriends" sender:self];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UINavigationController *navController = segue.destinationViewController;
    FacebookFriendsViewController *vc = navController.viewControllers.firstObject;
    vc.group = group;
}





- (void) gettingFacebookFriends : (id) sender {

    // finding out which facebook friends have the app and which dont

    NSMutableArray *arrayWithFacebookIDs = currentUser[@"facebookFriends"];
    NSMutableArray *arrayWithFacebookNames = currentUser[@"facebookFriendNames"];


    PFQuery *query = [PFUser query];
    __block NSArray *arrayOFPFUsers;


    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){

        } else {

    // if the query is succesful, create array of dictinaries and also create two seperate arrays for friends who have an account and for those who do not

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
                [finalArrayToDisplayInTheCells addObject: arrayWithFriendsWhoHaveAnAccount];
                [finalArrayToDisplayInTheCells addObject: arrayWithFriendsWhoDontHaveAnAccount];
            [tableViewContaingFriends reloadData];
        }
    }];

    
}

#pragma mark- TableView Delegate methods 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    

    return finalArrayToDisplayInTheCells.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     NewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    id object = finalArrayToDisplayInTheCells[indexPath.row];
    cell.group = group;
    cell.stringContainingUserID = object[@"ids"];
    cell.currentUser = currentUser;
    cell.labelWithPersonsName.text = object[@"name"];
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





@end
