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

@interface CreateGroupViewController () <ABPeoplePickerNavigationControllerDelegate>
{
    PFObject *group;
    UITextField *groupTextField;
    PFUser *currentUser;
    UIButton *addButton;
}

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;

@end

@implementation CreateGroupViewController

@synthesize addressBookController;



- (void)viewDidLoad
{
    [super viewDidLoad];
    currentUser = [PFUser currentUser];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    groupTextField = [[UITextField alloc] initWithFrame:CGRectMake(30.0f, 68.0f, 260.0f, 30.0f)];
    groupTextField.placeholder = @"Group Name";
    groupTextField.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:23.0f];
    [groupTextField setBorderStyle:UITextBorderStyleRoundedRect];
    addButton = [[UIButton alloc] initWithFrame:CGRectMake(250.0f, 105.0f, 40.0f, 30.0f)];
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [self.view addSubview:groupTextField];
    [self.view addSubview:addButton];
    
    [addButton addTarget:self action:@selector(onAddButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

-(void)onAddButtonPressed
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
}
- (IBAction)onAddFriendButtonPressed:(id)sender {
    self.addressBookController = [[ABPeoplePickerNavigationController alloc]init];
    [self.addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:self.addressBookController animated:YES completion:nil];

}

#pragma mark - ABPeoplePickerNavigationController delegate methods

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self.addressBookController dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    UIAlertView *startGamePlayMode = [[UIAlertView alloc] initWithTitle:nil message:@"This person does not have an account"  delegate:self cancelButtonTitle:nil otherButtonTitles:@"Invite", @"Cancel",  nil];
    [startGamePlayMode show];
    
    //getting the persons phone numbers from the address book
    
    NSString *mobileNumber;
    NSString *homeNumber;
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
     for (int j = 0; j < ABMultiValueGetCount(phoneNumbers); j++){
         
         if (j == 0){
          mobileNumber = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers,j);
         } else if (j == 1){
             homeNumber = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers,j);
         }
         
     }
    
    //getting the persons emails from the address book
    
    NSString *homeEmail;
    NSString *workEmail;
    
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (int j = 0; j < ABMultiValueGetCount(emails); j++){
        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
        if (j == 0){
           homeEmail = email;
 
        } else if (j == 1) workEmail = email;
    }
   NSLog (@"persons homeEmail = %@", homeEmail);
    
    // need to query the Parse database to check if the current person is already has the app or not. I do this by checking the emails
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"email" equalTo:homeEmail];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object){
            // no object present
        } else {
            //object is present
        }
    }];
    
    
    
    

    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}


@end
