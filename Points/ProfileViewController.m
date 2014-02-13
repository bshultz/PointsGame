//
//  ProfileViewController.m
//  Points
//
//  Created by Brad Shultz on 2/11/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"

@interface ProfileViewController ()
{
    NSMutableArray *userInfoArray;
    __weak IBOutlet UIImageView *profileImage;
    __weak IBOutlet UITextField *profileUsername;
    __weak IBOutlet UITextField *profileEmail;
}

@end

@implementation ProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self currentUser];
}

-(void)currentUser
{
    PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            //there is a current user object
            NSLog(@"currentUser object: %@", currentUser);
            NSLog(@"The current user's email address is: %@ ", [currentUser objectForKey:@"email"]);
            
            //Set the user's image
            PFFile *theImage = [currentUser objectForKey:@"userImage"];
            NSData *imageData = [theImage getData];
            profileImage.image = [UIImage imageWithData:imageData];
            
            //Set the user's username
            profileUsername.text = [currentUser objectForKey:@"username"];
            
            //Set the user's email address
            profileEmail.text = [currentUser objectForKey:@"email"];
            
            
        } else {
            // show the signup or login screen
        }
}

-(void)setProfileValues
{
    
}






@end
