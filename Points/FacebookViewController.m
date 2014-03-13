//
//  FacebookViewController.m
//  Points
//
//  Created by Matthew Graham on 2/20/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "FacebookViewController.h"
#import "Parse/Parse.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NewsfeedViewController.h"

@interface FacebookViewController ()
{
    UIButton *facebookLoginButton;

    IBOutlet UIImageView *imageView;
}

@end

@implementation FacebookViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:facebookLoginButton];

}

- (IBAction)loginButtonTouchHandler:(id)sender {


    NSArray *permissionsArray =  @[@"user_about_me", @"email", @"user_relationships", @"read_insights", @"publish_actions"];

    if (![PFUser currentUser]) {
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            //           [_activityIndicator stopAnimating]; // Hide loading indicator

            if (!user) {
                if (!error) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                } else {
                    NSLog(@"Uh oh. An error occurred: %@", error);
                }
            } else if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                PFUser *currentUser = user;
                [currentUser setObject:@100 forKey:@"pointsAvailable"];
                [self savePropertiesOfTheCurrentFacebookUserToTheDatabase];

                [self dismissViewControllerAnimated:YES completion:nil];
//                [self performSegueWithIdentifier:@"FacebookLogin" sender:self];
            } else {
                NSLog(@"User with facebook logged in!");
                 [self dismissViewControllerAnimated:YES completion:nil];


            }
        }];
    }

    

}

-(void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:animated];

//    if ([PFUser currentUser])
//    {
//        id vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
//        [self presentViewController:vc animated:NO completion:nil];
////        NSLog(@"The user is currently logged in");
//    }
}

- (void) savePropertiesOfTheCurrentFacebookUserToTheDatabase {
    PFUser *currentUser = [PFUser currentUser];

    //there is a current user object

    NSLog(@"currentUser object: %@", currentUser);
    NSLog(@"The current user's email address is: %@ ", [currentUser objectForKey:@"email"]);

    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error){
            //result is a dictionary with the users Data

            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];

            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];

            // save relevant details to the database

            PFFile *file = [PFFile fileWithData:[NSData dataWithContentsOfURL:pictureURL]];
            [currentUser setObject:file forKey:@"userImage"];
            [currentUser setObject:userData[@"name"] forKey:@"fullName"];
 //           [currentUser setObject:userData[@"username"] forKey:@"uniqueFacebookIdentifier"];
            [currentUser setObject:userData[@"id"] forKey:@"uniqueFacebookID"];

            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error){
                    NSLog (@"%@ %@", error, [error userInfo]);

                } else {
                    // get the users friends information
                    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if(!error){
                            NSArray *data = [result objectForKey:@"data"];
                            NSLog(@"data = %@", data);
                            NSMutableArray *names = [[NSMutableArray alloc]initWithCapacity:data.count];
                            NSMutableArray *facebookIDs = [[NSMutableArray alloc]initWithCapacity:data.count];
                            for (NSDictionary *friendData in data){
                                [facebookIDs addObject:friendData[@"id"]];
                                [names addObject:friendData[@"name"]];

                            }
                            [currentUser setObject:names forKey:@"facebookFriendNames"];
                            [currentUser setObject:facebookIDs forKey:@"facebookFriends"];
                            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error){
                                    NSLog (@"%@ %@", error, [error userInfo]);

                                }
                            }];
                            
                        }
                    }];
                }
                
            }];
        }
    }];
    
    
}



@end

