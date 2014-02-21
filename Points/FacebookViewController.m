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

@end

@implementation FacebookViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width/2)), 250);
    [self.view addSubview:loginView];
    loginView.readPermissions = @[@"user_about_me", @"email", @"user_relationships", @"read_insights", @"publish_actions"];
    
    [PFFacebookUtils logInWithPermissions:loginView.readPermissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:@10 forKey:@"pointsAvailable"];
            [self savePropertiesOfTheCurrentFacebookUserToTheDatabase];
        } else {
            NSLog(@"User logged in through Facebook!");
            [self performSegueWithIdentifier:@"FacebookSegue" sender:self];
        }
    }];
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
