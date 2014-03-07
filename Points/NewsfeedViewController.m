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
#import "NewsfeedCell.h"
#import "NewsfeedDetailViewController.h"
#import "FacebookViewController.h"
//#import "CSAnimationView.h"

@interface NewsfeedViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *transactions;
    NSMutableArray *from;
    NSMutableArray *to;
    NSMutableArray *objectIDs;
    NSMutableArray *usersGroups;
    NSMutableArray *pointId;
    NSArray *permissions;
    PFQuery *query;
    UIActivityIndicatorView *activityView;
    
    
    __weak IBOutlet UIBarButtonItem *notificationsButton;
    __weak IBOutlet UITableView *newsfeedTableView;
}

@end

@implementation NewsfeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    activityView = [[UIActivityIndicatorView alloc] init];
    activityView.color = [UIColor colorWithRed:77.0f/255.0f green:169.0/255.0f blue:157.0f/255.0f alpha:1.0f];
    activityView.frame = CGRectMake(self.view.center.x - 25, self.view.center.y, 50, 50);
    [activityView startAnimating];
    [self.view addSubview:activityView];


    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:77.0f/255.0f green:169.0/255.0f blue:157.0f/255.0f alpha:1.0f];

    //set color of bar button item
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    //set back button color

    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];

        self.view.backgroundColor = [UIColor colorWithRed:0.408f green:0.612f blue:0.823f alpha:1.0f];
    newsfeedTableView.separatorColor = [UIColor colorWithRed:0.05f green:0.345f blue:0.65f alpha:0.5f];
    newsfeedTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [newsfeedTableView setSeparatorInset:UIEdgeInsetsZero];
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
    [toolbarButtons removeObject:notificationsButton];
    [self setToolbarItems:toolbarButtons animated:YES];

}

-(void)viewDidAppear:(BOOL)animated

{

     [super viewDidAppear:YES];
// only show the spinner if a current user is logged in

//    if ([PFUser currentUser])


    if (![PFUser currentUser]){

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FacebookViewController *loginController = (FacebookViewController *)[storyboard instantiateViewControllerWithIdentifier:@"FacebookViewController"];

        [self presentViewController:loginController animated:NO completion:nil];
    }
        // get the transactions associated with the current user

    [self getTransactions];
}

#pragma mark Get the User's Groups

- (void) getTransactions {

    PFRelation *relation = [[PFUser currentUser] relationForKey:@"myGroups"];
    PFQuery *userQuery = [relation query];
    [userQuery includeKey:@"myTransactions"];
    [userQuery includeKey:@"myTransactions.fromUser"];
    [userQuery includeKey:@"myTransactions.toUser"];

    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog (@"%@ %@", error, [error userInfo]);

        } else {
            [activityView stopAnimating];

            transactions = [NSMutableArray new];
            from = [NSMutableArray new];
            to = [NSMutableArray new];
            objectIDs = [NSMutableArray new];
            pointId = [NSMutableArray new];

            for (id object in objects){
                PFObject *group = object;
                NSArray *transactionObjects = group[@"myTransactions"];
                for (PFObject *transaction in transactionObjects){


                    [transactions addObject:transaction];
                    [from addObject: [transaction objectForKey:@"fromUser"]];
                    [to addObject:[transaction objectForKey:@"toUser"]];
                    [pointId addObject:[transaction objectForKey:@"pointId"]];
                    [objectIDs addObject:transaction.objectId];
                    NSLog(@"transaction = %@", transaction);

                }

            } [newsfeedTableView reloadData];

        }
    }];

}


#pragma mark- TableView Delegate methods

// Set the cell properties
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsfeedCell *cell = [NewsfeedCell new];
    PFUser *fromUser = [from objectAtIndex:indexPath.row];
    PFUser *toUser = [to objectAtIndex:indexPath.row];
    
    PFFile *theImage = [fromUser objectForKey:@"userImage"];
    NSData *theData = [theImage getData];
    cell.profileImage.image = [UIImage imageWithData:theData];
    
    cell.text.font = [UIFont systemFontOfSize:12.0];
    cell.text.text = [NSString stringWithFormat:@"%@ gave %@ a point!", [fromUser objectForKey:@"fullName"], [toUser objectForKey:@"fullName"]];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return transactions.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsfeedCell *cell = (NewsfeedCell *)[newsfeedTableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"NewsfeedDetail" sender:cell];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewsfeedDetail"])
    {
        NewsfeedDetailViewController *ndvc = segue.destinationViewController;
        NSIndexPath *indexPath = [newsfeedTableView indexPathForSelectedRow];
 //       NewsfeedCell *cell = [newsfeedTableView cellForRowAtIndexPath:indexPath];
        ndvc.pointId = [pointId objectAtIndex:indexPath.row];
    }
}








@end