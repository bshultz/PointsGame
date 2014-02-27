//
//  ProfileViewController.m
//  Points
//
//  Created by Brad Shultz on 2/11/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "FacebookViewController.h"

@interface ProfileViewController () <NSURLConnectionDataDelegate>
{
    NSMutableArray *userInfoArray;
    __weak IBOutlet UIImageView *profileImage;
    __weak IBOutlet UILabel *usernameLabel;
    __weak IBOutlet UILabel *emailLabel;
    __weak IBOutlet UILabel *pointsAvailableLabel;
    __weak IBOutlet UILabel *pointsAvailableStatic;
    __weak IBOutlet UILabel *totalPointsReceivedStatic;
    __weak IBOutlet UILabel *totalPointsReceivedLabel;
    
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
    [self getPointsAvailable];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:RED/255.0f green:GREEN/255.0f blue:BLUE/255.0f alpha:1.0f];

    
}


-(void)currentUser
{
    
    currentUser = [PFUser currentUser];
        if (currentUser) {
            //there is a current user object
            usernameLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
            usernameLabel.text = currentUser[@"fullName"];
            emailLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];;
            emailLabel.text = currentUser[@"email"];
            pointsAvailableLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
            pointsAvailableStatic.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
            totalPointsReceivedStatic.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
            totalPointsReceivedLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
            
            
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
    NSLog(@"Logged out of facebook");
    //
    //    FBSession* session = [FBSession activeSession];
    //    [session closeAndClearTokenInformation];
    //    [session close];
    //    [FBSession setActiveSession:nil];
    //
    //    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //    NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://facebook.com/"]];
    //
    //    for (NSHTTPCookie* cookie in facebookCookies) {
    //        [cookies deleteCookie:cookie];
    //    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FacebookViewController *fbvc = [storyboard instantiateViewControllerWithIdentifier:@"FacebookViewController"];
    [self.navigationController presentViewController:fbvc animated:YES completion:nil];
    NSLog(@"Current user logged in is %@", [PFUser currentUser]);
    //    [self performSegueWithIdentifier:@"UserLogOut" sender:self];}
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
    PFQuery *query = [PFQuery queryWithClassName:@"Point"];
    [query includeKey:@"toUser"];
    [query whereKey:@"toUser" equalTo:currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            NSLog(@"Number of points %i", objects.count);
            totalPointsReceivedLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)objects.count];
        }
    }];
}

-(void)getPointsAvailable
{
    pointsAvailableLabel.text = [NSString stringWithFormat:@"%@", currentUser[@"pointsAvailable"]];
}

@end
