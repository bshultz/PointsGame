//
//  ProfileViewController.m
//  Points
//
//  Created by Brad Shultz on 2/11/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "NewsfeedViewController.h"

@interface ProfileViewController () <NSURLConnectionDataDelegate>
{
    NSMutableArray *userInfoArray;
    __weak IBOutlet UIImageView *profileImage;
    __weak IBOutlet UILabel *usernameLabel;
    __weak IBOutlet UILabel *emailLabel;
    __weak IBOutlet UILabel *pointsAvailableLabel;

    NSData *imageData;
}

@end

@implementation ProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self currentUser];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:.05f green:.345f blue:.65f alpha:1.0f];
    self.view.backgroundColor = [UIColor colorWithRed:0.408f green:0.612f blue:0.823f alpha:1.0f];

}


-(void)currentUser
{
    
    PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            //there is a current user object
            NSLog(@"currentUser object: %@", currentUser);
            NSLog(@"The current user's email address is: %@ ", [currentUser objectForKey:@"email"]);

            
            usernameLabel.text = currentUser[@"fullname"];
            emailLabel.text = currentUser[@"email"];
            pointsAvailableLabel.text = [NSString stringWithFormat:@"%@", currentUser[@"pointsAvailable"]]  ;
            
            PFFile *userImageFile = currentUser[@"userImage"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error){
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
    
    
    NSLog(@"Current user logged in is %@", [PFUser currentUser]);
}


@end
