//
//  AddPointViewController.m
//  Points
//
//  Created by Matthew Graham on 2/15/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "AddPointViewController.h"
#import "Parse/Parse.h"
#import "FriendsViewController.h"

@interface AddPointViewController () <UIAlertViewDelegate>
{
    __weak IBOutlet UILabel *friendNameLabel;
    __weak IBOutlet UITextView *commentTextView;
    PFObject *point;
}

@end

@implementation AddPointViewController
@synthesize toUserObjectID;
@synthesize fromUserObjectID;
@synthesize friendName;
@synthesize groupID;



- (void)viewDidLoad
{
    [super viewDidLoad];
    friendNameLabel.text = self.friendName;
}

- (IBAction)onSubmitButtonPressed:(id)sender
{
    // Update the Point class with the from user, to user, point value (1), and the user's comments
    point = [PFObject objectWithClassName:@"Point"];
    point[@"fromUser"] = [PFUser currentUser];
    
    PFQuery *toQuery = [PFUser query];
    point[@"toUser"] = [toQuery getObjectWithId:self.toUserObjectID error:nil];
    point[@"pointValue"] = @1;
    point[@"comment"] = commentTextView.text;
    
    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
    point[@"group"] = [groupQuery getObjectWithId:self.groupID error:nil];

    [point saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error)
        {
            // If there is an error saving point, log the error
            NSLog(@"Save Error: %@", error);
        }
        else
        {
            // If the save is successful, then update the Transaction class with from user, to user, and action
            NSLog(@"Save Succeeded");
            
            PFObject *transaction = [PFObject objectWithClassName:@"Transaction"];
            transaction[@"fromUser"] = [PFUser currentUser];
            transaction[@"toUser"] = [toQuery getObjectWithId:self.toUserObjectID error:nil];
            transaction[@"action"] = @"Point Awarded";
            
            [transaction saveInBackground];
            
            // Tell the user the save was successful
            
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Point Saved!" message:@"You're Awesome!" delegate:self cancelButtonTitle:@"Sweet" otherButtonTitles:nil];
            [saveAlert show];
        }
    }];
    [commentTextView resignFirstResponder];

    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // When the user dismisses the alert, dismiss the AddPointViewController
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
