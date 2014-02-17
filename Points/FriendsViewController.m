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

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    PFObject *group;
    NSMutableArray *friends;
    NSMutableArray *friendImages;
    NSMutableArray *toUserObjectID;
    __weak IBOutlet UITableView *friendsTableView;
    
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
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    group = [PFObject objectWithClassName:@"Group"];
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
                    [friends addObject:[object objectForKey:@"username"]];
                    [friendImages addObject:[object objectForKey:@"userImage"]];
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
    
    PFQuery *pointQuery = [PFQuery queryWithClassName:@"Point"];
    [pointQuery whereKey:group.objectId equalTo:self.groupID];
    
    cell.points.text = @"3";
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

@end
