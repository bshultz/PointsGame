//
//  CreateGroupViewController.m
//  Points
//
//  Created by Matthew Graham on 2/10/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "Parse/Parse.h"

@interface CreateGroupViewController ()
{
    PFObject *group;
    UITextField *groupTextField;
    PFUser *currentUser;
    UIButton *addButton;
}

@end

@implementation CreateGroupViewController



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
    
}


@end
