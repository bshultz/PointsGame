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


@interface CreateGroupViewController () < UIAlertViewDelegate>
{
    PFObject *group;
    UITextField *groupTextField;
    PFUser *currentUser;
    UIButton *addButton;
    UIAlertView *personDoesNotHaveAnAccount;
    UIAlertView *personDoesHaveAnAccount;

}

@end

@implementation CreateGroupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    currentUser = [PFUser currentUser];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [groupTextField becomeFirstResponder];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    groupTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 85.0f, 240.0f, 30.0f)];
    groupTextField.placeholder = @"Group Name";
    groupTextField.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:16.0f];
    [groupTextField setBorderStyle:UITextBorderStyleRoundedRect];
    addButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 125.0f, 240.0f, 30.0f)];
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
        addButton.titleLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:16.0f];
    [addButton setTitleColor:[UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [self.view addSubview:groupTextField];
    [self.view addSubview:addButton];
    
        [addButton addTarget:self action:@selector(onAddButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
                [self performSegueWithIdentifier:@"FacebookFriends" sender:self];
            }
            else
            {
                NSLog(@"Error: %@", error);
            }
        }];
        [groupTextField resignFirstResponder];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UINavigationController *navController = segue.destinationViewController;
    FacebookFriendsViewController *vc = navController.viewControllers.firstObject;
    vc.group = group;
    vc.isANewGroupBeingAdded = YES;
}







@end
