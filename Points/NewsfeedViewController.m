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
    NSMutableArray *usersGroups;
    PFQuery *query;
    
    
    __weak IBOutlet UITableView *newsfeedTableView;
}

@end

@implementation NewsfeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.title = @"PointBank";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:.05f green:.345f blue:.65f alpha:1.0f];
    self.view.backgroundColor = [UIColor colorWithRed:0.408f green:0.612f blue:0.823f alpha:1.0f];
    
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
        
        logInViewController.fields = PFLogInFieldsFacebook;
        UILabel *logo = [UILabel new];
        logo.text = @"PointsBank";
        logo.textColor = [UIColor whiteColor];
        [logo sizeToFit];
        logInViewController.logInView.logo = logo;

        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
        
 //       [self savePropertiesOfTheCurrentFacebookUserToTheDatabase];
    }
}


-(void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:YES];
    [self getGroups];


}

#pragma mark Get the User's Groups

-(void)getGroups
{
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"myGroups"];
    PFQuery *userQuery = [relation query];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             usersGroups = [NSMutableArray new];
             for (PFObject *object in objects)
             {
                 [usersGroups addObject:object.objectId];
                 NSLog(@"My Groups are %@", usersGroups);
                 [self getTransactions];
             }
         }
     }];
}

#pragma mark Get the Filtered Transactions

-(void)getTransactions
{
    query = [PFQuery queryWithClassName:@"Transaction"];
    query.limit = 25;
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"fromUser"];
    [query includeKey:@"toUser"];
    [query whereKey:@"groupId" containedIn:usersGroups];
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
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ gave %@ a point!", [fromUser objectForKey:@"fullName"], [toUser objectForKey:@"fullName"]];
    cell.textLabel.textColor = [UIColor colorWithRed:0.05f green:0.345 blue:0.65f alpha:1.0f];
    
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
     [self savePropertiesOfTheCurrentFacebookUserToTheDatabase];
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
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
    user[@"pointsAvailable"] = @10; // Give the user 10 points for signing up
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