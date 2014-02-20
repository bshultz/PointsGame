//
//  ProfileViewController.m
//  Points
//
//  Created by Brad Shultz on 2/11/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"

@interface ProfileViewController () <NSURLConnectionDataDelegate>
{
    NSMutableArray *userInfoArray;
    __weak IBOutlet UIImageView *profileImage;
    __weak IBOutlet UILabel *usernameLabel;
    __weak IBOutlet UILabel *emailLabel;
    __weak IBOutlet UILabel *pointsAvailableLabel;
    __weak IBOutlet UILabel *pointsAvailableStatic;
        PFUser *currentUser;

    NSData *imageData;
}

@end

@implementation ProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self currentUser];
    [self getAggregateScoreForUser];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:.05f green:.345f blue:.65f alpha:1.0f];
    self.view.backgroundColor = [UIColor colorWithRed:0.408f green:0.612f blue:0.823f alpha:1.0f];

}


-(void)currentUser
{
    
    currentUser = [PFUser currentUser];
        if (currentUser) {
            //there is a current user object
            NSLog(@"currentUser object: %@", currentUser);
            NSLog(@"The current user's email address is: %@ ", [currentUser objectForKey:@"email"]);
            
            usernameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
            usernameLabel.text = currentUser[@"fullName"];
            emailLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];;
            emailLabel.text = currentUser[@"email"];
            pointsAvailableLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
            pointsAvailableLabel.text = [NSString stringWithFormat:@"%@", currentUser[@"pointsAvailable"]]  ;
            pointsAvailableStatic.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
            
            PFFile *userImageFile = currentUser[@"userImage"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error){
                    profileImage.layer.masksToBounds = YES;
                    profileImage.layer.cornerRadius = 25.0f;
                    profileImage.image = [UIImage imageWithData:data];
                }
            }];
        } else {
            //show login screen 
        }
}



- (IBAction)onLogoutButtonPressed:(id)sender
{
    [PFUser logOut];
    int index = 0;
    self.tabBarController.selectedIndex = index;
    [self.tabBarController.viewControllers[index] popToRootViewControllerAnimated:NO];
    NSLog(@"Current user logged in is %@", [PFUser currentUser]);
}


// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in... %@", error);
}
// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)getAggregateScoreForUser
{
    NSLog(@"currentUserID: %@", [currentUser objectForKey:@"uniqueFacebookID"]);
    PFQuery *query = [PFQuery queryWithClassName:@"Point"];
    [query includeKey:@"toUser"];
    [query whereKey:@"uniqueFacebookID" equalTo:[currentUser objectForKey:@"uniqueFacebookID"]];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
            NSLog(@"You have %d points", count);
        } else {
            // The request failed
        }
    }];
}


@end
