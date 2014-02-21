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
    
    
    __weak IBOutlet UIBarButtonItem *notificationsButton;
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
    permissions = [NSArray arrayWithObjects:@"read_friendlists", @"basic_info" , nil];
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
                 
             }
             [self getTransactions];
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
         pointId = [NSMutableArray new];
         for (PFObject *object in objects)
         {
             if (object)
             {
                 [transactions addObject:object];
                 [from addObject:[object objectForKey:@"fromUser"]];
                 [to addObject:[object objectForKey:@"toUser"]];
                 [pointId addObject:[object objectForKey:@"pointId"]];
                 [objectIDs addObject:object.objectId];
             }
         }
         [newsfeedTableView reloadData];
     }];
}
     

     
#pragma mark: Login New User

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

// called from viewWilAppear and only called when no user is currently logged in


#pragma mark: News Items Table View

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
    //cell.text.textColor = [UIColor colorWithRed:0.05f green:0.345 blue:0.65f alpha:1.0f];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return transactions.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsfeedCell *cell = [newsfeedTableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"NewsfeedDetail" sender:cell];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewsfeedDetail"])
    {
        NewsfeedDetailViewController *ndvc = segue.destinationViewController;
        NSIndexPath *indexPath = [newsfeedTableView indexPathForSelectedRow];
        NewsfeedCell *cell = [newsfeedTableView cellForRowAtIndexPath:indexPath];
        ndvc.pointId = [pointId objectAtIndex:indexPath.row];
    }
}








@end