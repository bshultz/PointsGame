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
    
}

@end

@implementation FriendsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    friends = [NSMutableArray new];
    friendImages = [NSMutableArray new];
    toUserObjectID = [NSMutableArray new];
    usernames = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    group = [PFObject objectWithClassName:@"Group"];
    
    points = [NSMutableArray new];
    pointQuery = [PFQuery queryWithClassName:@"Point"];
    [pointQuery includeKey:@"toUser"];
    [pointQuery whereKey:@"group" equalTo:self.groupID];
    [pointQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                [points addObject:object];
                [friendsTableView reloadData];
            }
        }
        else
        {
            NSLog(@"pointsQuery error is %@", error);
        }
    }];
    
    [query whereKey:@"objectId" equalTo:self.groupID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        group = [objects firstObject];
        self.title = [group objectForKey:@"name"];
        PFRelation *relation = [group relationForKey:@"members"];
        [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            if (!error)
            {
                for (PFObject *object in objects)
                {
                    [friends addObject:[object objectForKey:@"fullName"]];
                    [friendImages addObject:[object objectForKey:@"userImage"]];
                    [usernames addObject:[object objectForKey:@"username"]];
                    [toUserObjectID addObject:object.objectId];
                    [friendsTableView reloadData];
                    NSLog(@"Friends are %@", friends);
                }
            }
            else
            {
                NSLog(@"Error: %@", error);
            }

        }];
    }];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsGroupDetailCell *cell = [FriendsGroupDetailCell new];
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
    [cell.addButton setBackgroundImage:[UIImage imageNamed:@"addbutton.jpeg"] forState:UIControlStateNormal];
    
    [cell.addButton addTarget:self action:@selector(addPoint:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    [self.navigationController presentViewController:pointVC animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Friend Selected - transition to friend detail page");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailPointsPageViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"DetailPointsPageViewController"];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    dvc.groupName = self.groupID;
    dvc.userName = toUserObjectID[0];
 //   dvc.userName = cell.textLabel.text;
    
    [self.navigationController pushViewController:dvc animated:YES];
}

- (IBAction)onInviteButtonPressed:(id)sender
{
    
}


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
