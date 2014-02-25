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
}

@end

@implementation FacebookViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    facebookLoginButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 60, 20)];
    facebookLoginButton.titleLabel.text = @"Login";
    facebookLoginButton.backgroundColor = [UIColor redColor];
    [self.view addSubview:facebookLoginButton];
    [facebookLoginButton addTarget:self action:@selector(loginButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];

    //    if ([PFUser currentUser])
    //    {
    //        [self performSegueWithIdentifier:@"FacebookLogin" sender:self];
    //        NSLog(@"The user is currently logged in");
    //    }


}

- (void) loginButtonTouchHandler : (id) sender {


    NSArray *permissionsArray =  @[@"user_about_me", @"email", @"user_relationships", @"read_insights", @"publish_actions"];

    // Login PFUser using Facebook
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
            [currentUser setObject:@10 forKey:@"pointsAvailable"];
            [self savePropertiesOfTheCurrentFacebookUserToTheDatabase];

            // save the access token so that
            //
            //                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //                [defaults setObject:facebook.accessToken forKey:ACCESS_TOKEN_KEY];
            //                [defaults setObject:facebook.expirationDate forKey:EXPIRATION_DATE_KEY];
            //                [defaults synchronize];

            [self performSegueWithIdentifier:@"FacebookLogin" sender:self];
        } else {
            NSLog(@"User with facebook logged in!");
            [self performSegueWithIdentifier:@"FacebookLogin" sender:self];


        }
    }];



    //    FBLoginView *loginView = [[FBLoginView alloc] init];
    //    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width/2)), 250);
    //    [self.view addSubview:loginView];
    //
    //    loginView.readPermissions = @[@"user_about_me", @"email", @"user_relationships", @"read_insights", @"publish_actions"];;
    //
    //        [PFFacebookUtils logInWithPermissions:loginView.readPermissions block:^(PFUser *user, NSError *error) {
    //        if (!user) {
    //            NSLog(@"Uh oh. The user cancelled the Facebook login.");
    //        } else if (user.isNew) {
    //            NSLog(@"User signed up and logged in through Facebook!");
    //            PFUser *currentUser = [PFUser currentUser];
    //            [currentUser setObject:@10 forKey:@"pointsAvailable"];
    //            [self savePropertiesOfTheCurrentFacebookUserToTheDatabase];
    //        } else {
    //            NSLog(@"User logged in through Facebook!");
    //            [self performSegueWithIdentifier:@"FacebookSegue" sender:self];
    //        }
    //    }];




}

-(void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:animated];

    if ([PFUser currentUser])
    {
        id vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        [self presentViewController:vc animated:NO completion:nil];
//        NSLog(@"The user is currently logged in");
    }
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
            [currentUser setObject:userData[@"username"] forKey:@"uniqueFacebookIdentifier"];
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

