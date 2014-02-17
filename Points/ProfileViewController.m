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
    __weak IBOutlet UITextField *profileUsername;
    __weak IBOutlet UITextField *profileEmail;
    NSData *imageData;
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

            
            profileUsername.text = currentUser[@"fullName"];
            
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


@end
