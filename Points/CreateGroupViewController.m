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

    groupTextField = [[UITextField alloc] initWithFrame:CGRectMake(30.0f, 68.0f, 260.0f, 30.0f)];
    groupTextField.placeholder = @"Group Name";
    groupTextField.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:23.0f];
    [groupTextField setBorderStyle:UITextBorderStyleRoundedRect];
    addButton = [[UIButton alloc] initWithFrame:CGRectMake(250.0f, 105.0f, 40.0f, 30.0f)];
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
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
    
    [self gettingFacebookFriends:sender];
}

- (void) gettingFacebookFriends : (id) sender {

    // finding out which facebook friends have the app and which dont

    NSMutableArray *arrayWithFacebookIDs = currentUser[@"facebookFriends"];
    NSMutableArray *arrayWithFacebookNames = currentUser[@"facebookFriendNames"];

    




//    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        NSDictionary *friends = result;
//        NSLog(@"friends = %@", friends);
//    }];

    
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              [self onAddButtonPressed:sender];
                                          }
                                      }];
        return;
    }
    
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
        NSSet *fields = [NSSet setWithObjects:@"installed", nil];
        self.friendPickerController.fieldsForRequest = fields;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];


}

#pragma mark- TableView Delegate methods 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    if (tableView == tableViewWithPeopleWhoDontHaveAnAcoount){
//        
//        return arrayWithFriendsWhoDontHaveAnAccount.count;
//        
//    } else if (tableView == tableViewWithPeopleWhoHaveAnAccount){
//        return arrayWithFriendsWhoHaveAnAccount.count;
//    }
    return finalArrayToDisplayInTheCells.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     NewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    id object = finalArrayToDisplayInTheCells[indexPath.row];
    cell.group = group;
    cell.stringContainingUserID = object[@"uniqueID"];
    cell.currentUser = currentUser;
    
   cell.textfield.text = object[@"name"];
    if ([object[@"number"]isEqualToString:@"1"]){
        // this person already has an account
        [cell.buttonWithTextToAddOrInvite setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [cell.buttonWithTextToAddOrInvite setTitle:@"Add" forState:UIControlStateNormal];
    } else if ([object[@"number"]isEqualToString:@"2"]) {
        // this person does not have an account
        [cell.buttonWithTextToAddOrInvite setTitle:@"Invite" forState:UIControlStateNormal];
        [cell.buttonWithTextToAddOrInvite setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
       
        [cell sizeToFit];
        [cell bringSubviewToFront:cell.buttonWithTextToAddOrInvite];
    }
    
    
    
    
//    if (tableView == tableViewWithPeopleWhoDontHaveAnAcoount){
//        
//        id <FBGraphUser> user = arrayWithFriendsWhoDontHaveAnAccount[indexPath.row];
//        cell.textLabel.text = user.name;
//        return cell;
//        
//        
//        
//        
//    } else if (tableView == tableViewWithPeopleWhoHaveAnAccount){
//        
//        id <FBGraphUser> user = arrayWithFriendsWhoHaveAnAccount[indexPath.row];
//        cell.textLabel.text = user.name;
//        return cell;
//
//        
//    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
}

#pragma mark - FBFriendPickerController delegate methods

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    NSLog(@"friends = %@", self.friendPickerController.selection);
    
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//        [arrayContainingFacebookFriendsThatAreSelected addObject:user];
        [dict setObject:user[@"name"] forKey:@"name"];
        [dict setObject:user[@"id"] forKey:@"uniqueID"];
        NSLog(@"user id = %@", user[@"id"]);
        NSLog(@"user name= %@", user[@"name"]);
        
        [arrayContainingDictionaroesOfTheNameAndUniqueIdOFtheSelectedPersons addObject:dict];
        
        
        
        }
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    }
    
//    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];




//- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user {
//    BOOL installed = [user objectForKey:@"installed"] != nil;
//    return installed;
//}




@end
