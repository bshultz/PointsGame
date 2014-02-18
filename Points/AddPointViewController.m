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
    NSNumber *pointsAvailable;
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
    
    // Get the number of points the user has available
    
    PFUser *currentUser = [PFUser currentUser];
    pointsAvailable = (NSNumber *)[currentUser objectForKey:@"pointsAvailable"];
}

- (IBAction)onSubmitButtonPressed:(id)sender
{
    // Check to see if the user has any points to give
    if (pointsAvailable.intValue > 0)
    {
    
    // Update the Point class with the from user, to user, point value (1), and the user's comments
    point = [PFObject objectWithClassName:@"Point"];
    point[@"fromUser"] = [PFUser currentUser];
    
    PFQuery *toQuery = [PFUser query];
    point[@"toUser"] = [toQuery getObjectWithId:self.toUserObjectID error:nil];
    point[@"pointValue"] = @1;
    point[@"comment"] = commentTextView.text;
    point[@"group"] = self.groupID;

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
            
            PFUser *currentUser = [PFUser currentUser];
            [currentUser incrementKey:@"pointsAvailable" byAmount:[NSNumber numberWithInt:-1]];
            [currentUser saveInBackground];
            // Tell the user the save was successful
            
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Point Saved!" message:@"You're Awesome!" delegate:self cancelButtonTitle:@"Sweet" otherButtonTitles:nil];
            [saveAlert show];
        }
    }];
    [commentTextView resignFirstResponder];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Out of Points!" message:@"You don't have any points to give!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Get More Points", nil];
        [alert show];
    }
    
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
