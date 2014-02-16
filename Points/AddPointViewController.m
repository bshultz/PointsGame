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
    NSLog(@"From user, to user, and friend name are %@, %@, %@", self.fromUserObjectID, self.toUserObjectID, self.friendName);
}

- (IBAction)onSubmitButtonPressed:(id)sender
{
    point = [PFObject objectWithClassName:@"Point"];
    point[@"fromUser"] = self.fromUserObjectID;
    point[@"toUser"] = self.toUserObjectID;
    point[@"pointValue"] = @1;
    point[@"comment"] = commentTextView.text;
    point[@"groupId"] = self.groupID;

    [point saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (error)
        {
            NSLog(@"Save Error: %@", error);
        }
        else
        {
            NSLog(@"Save Succeeded");
            
            PFObject *transaction = [PFObject objectWithClassName:@"Transaction"];
            PFRelation *fromRelation = [transaction relationForKey:@"fromUser"];
            //PFRelation *toRelation = [transaction relationForKey:@"toUser"];
            [fromRelation addObject:[PFUser currentUser]];
            //transaction[@"toUser"] = self.toUserObjectID;
            transaction[@"action"] = @"Point Awarded";
            [transaction saveInBackground];
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Point Saved!" message:@"You're Awesome!" delegate:self cancelButtonTitle:@"Sweet" otherButtonTitles:nil];
            [saveAlert show];
        }
    }];
    [commentTextView resignFirstResponder];

    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button index is %i", buttonIndex);
    if (buttonIndex == 0)
    {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        FriendsViewController *friendsVC = (FriendsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"FriendsViewController"];
//        [self.navigationController presentViewController:friendsVC animated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
