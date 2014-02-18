//
//  NewsfeedViewController.m
//  Points
//
//  Created by Brad Shultz on 2/10/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//



#import "NewsfeedViewController.h"
#import "Parse/Parse.h"
#import <FacebookSDK/FacebookSDK.h>

@interface NewsfeedViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *transactions;
    NSMutableArray *from;
    NSMutableArray *to;
    NSMutableArray *objectIDs;
    PFQuery *query;
    
    __weak IBOutlet UITableView *newsfeedTableView;
}

@end

@implementation NewsfeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark: Login New User

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![PFUser currentUser]) {
        // No user logged in
        // Create the log in view controller
        
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        [logInViewController setFacebookPermissions:@[@"user_about_me", @"user_birthday", @"user_relationships"]];
        
        logInViewController.fields = PFLogInFieldsUsernameAndPassword
        | PFLogInFieldsLogInButton
        | PFLogInFieldsSignUpButton
        | PFLogInFieldsPasswordForgotten
        | PFLogInFieldsDismissButton
        | PFLogInFieldsFacebook;
        
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
        
        [self savePropertiesOfTheCurrentFacebookUserToTheDatabase];
    }
}


-(void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:YES];

    query = [PFQuery queryWithClassName:@"Transaction"];
    [query orderByDescending:@"createdAt"];
    query.limit = 25;
    [query includeKey:@"fromUser"];
    [query includeKey:@"toUser"];
//    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        transactions = [NSMutableArray new];
        from = [NSMutableArray new];
        to = [NSMutableArray new];
        objectIDs = [NSMutableArray new];
        for (PFObject *object in objects)
        {
            if (object)
            {
                [transactions addObject:object];
                [from addObject:[object objectForKey:@"fromUser"]];
                [to addObject:[object objectForKey:@"toUser"]];
                [objectIDs addObject:object.objectId];
            }
        }
        [newsfeedTableView reloadData];
    }];
    

}

// called from viewWilAppear and only called when no user is currently logged in

- (void) savePropertiesOfTheCurrentFacebookUserToTheDatabase {
    PFUser *currentUser = [PFUser currentUser];
    
    
        //there is a current user object
        NSLog(@"currentUser object: %@", currentUser);
        NSLog(@"The current user's email address is: %@ ", [currentUser objectForKey:@"email"]);
        
        
//        FBRequest *request = [FBRequest requestForMe];
        
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
                        
                    }
                    
                }];
            }
        }];
    
}

#pragma mark: News Items Table View

// Set the cell properties
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsfeedCell"];
    PFUser *fromUser = [from objectAtIndex:indexPath.row];
    PFUser *toUser = [to objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ gave %@ a point!", fromUser.username, toUser.username ];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return transactions.count;
}




// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0)
    {
        return YES; // Begin login process
    }
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}
// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}
// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark: Sign Up New User
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0)
        { // check completion
            informationComplete = NO;
            break;
        }
    }
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    return informationComplete;
}
// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
}
// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}
// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


















@end