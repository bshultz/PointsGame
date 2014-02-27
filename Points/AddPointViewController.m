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

#define kOFFSET_FOR_KEYBOARD 80.0

@interface AddPointViewController () <UIAlertViewDelegate, UITextViewDelegate, UITextViewDelegate>
{
    __weak IBOutlet UILabel *friendNameLabel;
    __weak IBOutlet UITextView *commentTextView;
    __weak IBOutlet UIImageView *userProfileImage;
    
    IBOutlet UIButton *submitButton;
    IBOutlet UIButton *cancelButton;
    PFObject *point;
    NSNumber *pointsAvailable;
    PFQuery *toQuery;
    CGPoint txco;
}

@end

@implementation AddPointViewController
@synthesize toUserObjectID, fromUserObjectID, friendName, groupID, group;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.title = @"Give Point";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:.05f green:.345f blue:.65f alpha:1.0f];
    self.view.backgroundColor = [UIColor colorWithRed:77.0/255.0f green:169.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    //[UIColor colorWithRed:0.408f green:0.612f blue:0.823f alpha:1.0f];
    
    friendNameLabel.text = self.friendName;
    userProfileImage.contentMode = UIViewContentModeScaleAspectFill;
    userProfileImage.layer.masksToBounds = YES;
    userProfileImage.layer.cornerRadius = 25.0f;
    userProfileImage.image = self.profileImage.image;
    // Get the number of points the user has available
    
    commentTextView.layer.masksToBounds = YES;
    commentTextView.layer.cornerRadius = 5.0f;

    [cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_orange_normal.png"] forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[UIImage imageNamed:@"btn_orange_normal.png"] forState:UIControlStateNormal];
    

    
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
    PFUser *fromUser = [PFUser currentUser];
        point[@"fromUser"] = fromUser;


    
    toQuery = [PFUser query];
    PFUser *toUser = (PFUser *)[toQuery getObjectWithId:self.toUserObjectID error:nil];
        point[@"toUser"] = toUser;


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
    transaction[@"pointId"] = point.objectId;
    
    [transaction saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {

        } else {
            // Update the points available to the user
            PFUser *currentUser = [PFUser currentUser];
            [currentUser incrementKey:@"pointsAvailable" byAmount:[NSNumber numberWithInt:-1]];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog (@"%@ %@", error, [error userInfo]);

                } else {
                    [group addObject:transaction forKey:@"myTransactions"];
                    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error){
                             NSLog (@"%@ %@", error, [error userInfo]);
                        }
                    }];
                }
            }];

        }
    }];

}

- (IBAction)onCancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextView *)sender
{
    if ([sender isEqual:commentTextView])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}




@end
