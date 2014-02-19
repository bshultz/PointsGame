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
    __weak IBOutlet UIImageView *userProfileImage;
    
    PFObject *point;
    NSNumber *pointsAvailable;
    PFQuery *toQuery;
}

@end

@implementation AddPointViewController
@synthesize toUserObjectID;
@synthesize fromUserObjectID;
@synthesize friendName;
@synthesize groupID;
@synthesize profileImage;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.title = @"Give Point";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:.05f green:.345f blue:.65f alpha:1.0f];
    self.view.backgroundColor = [UIColor colorWithRed:0.408f green:0.612f blue:0.823f alpha:1.0f];
    
    friendNameLabel.text = self.friendName;
    userProfileImage.contentMode = UIViewContentModeScaleAspectFill;
    userProfileImage.image = self.profileImage.image;
    // Get the number of points the user has available
    
    PFUser *currentUser = [PFUser currentUser];
//    Artifically set the number of points the user has avaiable. Uncomment if necessay for testing.
//    currentUser[@"pointsAvailable"] = @250;
//    [currentUser saveInBackground];
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
    
    toQuery = [PFUser query];
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
            [self updateTransaction];

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

-(void)updateTransaction
{
    // Update the Transaction class with the relevant information
    PFObject *transaction = [PFObject objectWithClassName:@"Transaction"];
    transaction[@"fromUser"] = [PFUser currentUser];
    transaction[@"toUser"] = [toQuery getObjectWithId:self.toUserObjectID error:nil];
    transaction[@"action"] = @"Point Awarded";
    transaction[@"groupId"] = self.groupID;
    
    [transaction saveInBackground];
    
    // Update the points available to the user
    PFUser *currentUser = [PFUser currentUser];
    [currentUser incrementKey:@"pointsAvailable" byAmount:[NSNumber numberWithInt:-1]];
    [currentUser saveInBackground];
}

- (IBAction)onCancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
