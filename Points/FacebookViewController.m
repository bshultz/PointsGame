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
    loginView.readPermissions = @[@"user_about_me", @"email", @"user_relationships"];
    
    [PFFacebookUtils logInWithPermissions:loginView.readPermissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            NSLog(@"User logged in through Facebook!");
                     
            [self performSegueWithIdentifier:@"FacebookSegue" sender:self];
        }
    }];
}




@end
