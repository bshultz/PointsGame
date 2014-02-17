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

@interface CreateGroupViewController () <ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate, FBFriendPickerDelegate>
{
    PFObject *group;
    UITextField *groupTextField;
    PFUser *currentUser;
    UIButton *addButton;
    UIAlertView *personDoesNotHaveAnAccount;
    UIAlertView *personDoesHaveAnAccount;
    PFUser *userFoundInDatabase;
    NSMutableArray *arrayContainingFacebookFriends;
    BOOL returningFromFacebookFriendPicker;
    
    IBOutlet UITableView *tableViewWithPeopleWhoDontHaveAnAcoount;
   
    IBOutlet UITableView *tableViewWithPeopleWhoHaveAnAccount;
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
    arrayContainingFacebookFriends = [[NSMutableArray alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (returningFromFacebookFriendPicker){
        // do something and then set the aboove boolean to false
        returningFromFacebookFriendPicker = NO;
        tabkeViewWithPeopleWhoHaveAnAccount.alpha = 1;
        
        
        
    } else {
    groupTextField = [[UITextField alloc] initWithFrame:CGRectMake(30.0f, 68.0f, 260.0f, 30.0f)];
    groupTextField.placeholder = @"Group Name";
    groupTextField.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:23.0f];
    [groupTextField setBorderStyle:UITextBorderStyleRoundedRect];
    addButton = [[UIButton alloc] initWithFrame:CGRectMake(250.0f, 105.0f, 40.0f, 30.0f)];
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [self.view addSubview:groupTextField];
    [self.view addSubview:addButton];
    
//    group = [PFObject objectWithClassName:@"Group"];
    
        [addButton addTarget:self action:@selector(onAddButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}

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
- (IBAction)onAddFriendButtonPressed:(id)sender {
}

- (void) gettingFacebookFriends : (id) sender {

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
                                              [self onAddFriendButtonPressed:sender];
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
    
    returningFromFacebookFriendPicker = YES;
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
    
 //   FBRequest *request = [FBRequest requestForMyFriends];
    
    
//    self.addressBookController = [[ABPeoplePickerNavigationController alloc]init];
//    [self.addressBookController setPeoplePickerDelegate:self];
//    [self presentViewController:self.addressBookController animated:YES completion:nil];
    
    

}

#pragma mark - FBFriendPickerController delegate methods

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        [arrayContainingFacebookFriends addObject:user];
        
        
        }
    returningFromFacebookFriendPicker = YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    }
    
//    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"<None>"];




//- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user {
//    BOOL installed = [user objectForKey:@"installed"] != nil;
//    return installed;
//}

#pragma mark - ABPeoplePickerNavigationController delegate methods

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self.addressBookController dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
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
    __block BOOL theEmailIsPresent;
    
    // need to query the Parse database to check if the current person is already has the app or not. I do this by checking the emails
    PFQuery *query = [PFUser query];
//    [query whereKey:@"email" containsString:homeEmail];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog (@"%@ %@", error, [error userInfo]);
        } else {
            for (PFUser *object in objects){
                if ([object.email isEqualToString:homeEmail ]) {
                    theEmailIsPresent = true;
                    userFoundInDatabase = object;
                }
            }
            if (theEmailIsPresent){
                NSLog(@"the email is Present");
                personDoesHaveAnAccount = [[UIAlertView alloc] initWithTitle:nil message:nil  delegate:self cancelButtonTitle:nil otherButtonTitles:@"Add", @"Cancel",  nil];
                            personDoesHaveAnAccount.tag = 1;
                            [personDoesHaveAnAccount show];
            } else {
                // user is not present in the app
                personDoesNotHaveAnAccount = [[UIAlertView alloc] initWithTitle:nil message:@"This person does not have an account"  delegate:self cancelButtonTitle:nil otherButtonTitles:@"Invite", @"Cancel",  nil];
                            personDoesNotHaveAnAccount.tag = 0;
                            [personDoesNotHaveAnAccount show];
            }
            
        }
    
    }];
    
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (!object){
//             NSLog (@"the email does not exist");
//            personDoesNotHaveAnAccount = [[UIAlertView alloc] initWithTitle:nil message:@"This person does not have an account"  delegate:self cancelButtonTitle:nil otherButtonTitles:@"Invite", @"Cancel",  nil];
//            personDoesNotHaveAnAccount.tag = 0;
//            [personDoesNotHaveAnAccount show];
//        } else {
//            personDoesHaveAnAccount = [[UIAlertView alloc] initWithTitle:nil message:nil  delegate:self cancelButtonTitle:nil otherButtonTitles:@"Add", @"Cancel",  nil];
//            personDoesNotHaveAnAccount.tag = 1;
//            [personDoesHaveAnAccount show];
//            
//        }
//    }];

    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 0){
        if (buttonIndex == 0){
            // send the friend an invite to the app
            NSLog (@"you have sent the friend an invite");
        }
        
    }
    
    //person does have an account
    
    if (alertView.tag == 1){
        if (buttonIndex == 0){
            
            PFRelation *relation = [group relationForKey:@"members"];
            [relation addObject:userFoundInDatabase];
            [group saveInBackground];
             NSLog (@"you have added the friend");
        }
    }
}


@end
