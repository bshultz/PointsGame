//
//  FriendsViewController.m
//  Points
//
//  Created by Matthew Graham on 2/14/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendsGroupDetailCell.h"
#import "AddPointViewController.h"
#import "DetailPointsPageViewController.h"
#import "FacebookFriendsViewController.h"

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    PFObject *group;
    NSMutableArray *friends;
    NSMutableArray *friendImages;
    NSMutableArray *toUserObjectID;
    NSMutableArray *usernames;
    __weak IBOutlet UITableView *friendsTableView;
    PFQuery *pointQuery;
    NSMutableArray *points;
    PFUser *currentUser;
     UIActivityIndicatorView *activityView;
    
}

@end

@implementation FriendsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    friends = [NSMutableArray new];
    friendImages = [NSMutableArray new];
    toUserObjectID = [NSMutableArray new];
    usernames = [NSMutableArray new];

    currentUser = [PFUser currentUser];

    activityView = [[UIActivityIndicatorView alloc] init];
    activityView.color = [UIColor colorWithRed:77.0f/255.0f green:169.0/255.0f blue:157.0f/255.0f alpha:1.0f];
    activityView.frame = CGRectMake(self.view.center.x - 25, self.view.center.y, 50, 50);
    [activityView startAnimating];
    [self.view addSubview:activityView];

    friendsTableView.separatorColor = [UIColor colorWithRed:0.05f green:0.345f blue:0.65f alpha:0.5f];
    friendsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [friendsTableView setSeparatorInset:UIEdgeInsetsZero];
}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    group = [PFObject objectWithClassName:@"Group"];
    
    points = [NSMutableArray new];
    pointQuery = [PFQuery queryWithClassName:@"Point"];
    [pointQuery includeKey:@"toUser"];
    [pointQuery whereKey:@"group" equalTo:self.groupID];
    [pointQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        [points removeAllObjects];
        if (!error)
        {
            for (PFObject *object in objects)
            {
                [points addObject:object];
                
            }
        }
        else
        {
            NSLog(@"pointsQuery error is %@", error);
        }
        [friendsTableView reloadData];
    }];
    
    [query whereKey:@"objectId" equalTo:self.groupID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        group = [objects firstObject];
        self.title = [group objectForKey:@"name"];
        PFRelation *relation = [group relationForKey:@"members"];
        [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            [activityView stopAnimating];
            [friends removeAllObjects];
            if (!error)
            {
                for (PFObject *object in objects)

                {
                    [friends addObject:[object objectForKey:@"fullName"]];
                    [friendImages addObject:[object objectForKey:@"userImage"]];
                    [usernames addObject:[object objectForKey:@"username"]];
                    [toUserObjectID addObject:object.objectId];
                    NSLog(@"Friends are %@", friends);
                }
                [friendsTableView reloadData];
            }
            else
            {
                NSLog(@"Error: %@", error);
            }

        }];
    }];

}
- (IBAction)onInviteButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"FacebookFriends" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UINavigationController *navController = segue.destinationViewController;
    FacebookFriendsViewController *vc = navController.viewControllers.firstObject;
    vc.group = group;
    vc.isANewGroupBeingAdded = NO;
    vc.arrayWithTheNamesOfTheCurrentMemebersOfTheGroup = friends;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsGroupDetailCell *cell = [FriendsGroupDetailCell new];
    cell.name.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
    cell.name.text = [friends objectAtIndex:indexPath.row];
    PFFile *theImage = [friendImages objectAtIndex:indexPath.row];
    NSData *imageData = [theImage getData];
    cell.profileImage.image = [UIImage imageWithData:imageData];
    
    NSInteger pointValue;
    pointValue = 0;
    
    for (PFObject *object in points)
    {
        if ([[[object objectForKey:@"toUser"] objectForKey:@"username"] isEqualToString:[usernames objectAtIndex:indexPath.row]])
        {
            pointValue++;
        }
        
    }
    
    cell.points.text = [NSString stringWithFormat:@"%ld",(long)pointValue];

    // if the user is the current User, dont show the add point button
    if ([cell.name.text isEqualToString:currentUser[@"fullName"]]) {
        cell.addButton.alpha = 0;
    } else {
    [cell.addButton setBackgroundImage:[UIImage imageNamed:@"btn_orange_normal.png"] forState:UIControlStateNormal];
    [cell.addButton addTarget:self action:@selector(addPoint:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return friends.count;
}

-(void)addPoint:(UIButton *)button
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddPointViewController *pointVC = (AddPointViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AddPointViewController"];
    
    FriendsGroupDetailCell *cell = (FriendsGroupDetailCell *)button.superview.superview.superview;
    NSIndexPath *indexPath = [friendsTableView indexPathForCell:cell];
    pointVC.toUserObjectID = [toUserObjectID objectAtIndex:indexPath.row];
    pointVC.fromUserObjectID = [PFUser currentUser].objectId;
        pointVC.friendName = [friends objectAtIndex:indexPath.row];
    pointVC.groupID = self.groupID;
    pointVC.profileImage = cell.profileImage;
    pointVC.group = group;
    
    [self.navigationController presentViewController:pointVC animated:YES completion:nil];

}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Friend Selected - transition to friend detail page");
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    DetailPointsPageViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"DetailPointsPageViewController"];
//    dvc.groupName = self.groupID;
//    dvc.userName = toUserObjectID[0];
//    
//    [self.navigationController pushViewController:dvc animated:YES];
//}




// Try to have the user leave the group
//- (IBAction)onLeaveButtonPressed:(id)sender
//{
//    PFUser *currentUser = [PFUser currentUser];
//    group = [PFObject objectWithClassName:@"Group"];
//        
//    PFRelation *relation = [group relationForKey:@"members"];
//    [relation removeObject:currentUser];
//    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//        {
//            if (!error)
//             {
//                 NSLog(@"Removal Saved");
//                 PFRelation *relation1 = [currentUser relationForKey:@"myGroups"];
//                 [relation1 removeObject:group];
//                 [currentUser saveInBackground];
//             }
//             else
//             {
//                 NSLog(@"Error: %@", error);
//             }
//         }];
//}


@end
