//
//  FriendsViewController.m
//  Points
//
//  Created by Matthew Graham on 2/14/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendsGroupDetailCell.h"

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    PFObject *group;
    NSMutableArray *friends;
    NSMutableArray *friendImages;
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
    
    cell.points.text = @"3";
    [cell.addButton setBackgroundImage:[UIImage imageNamed:@"addbutton.jpeg"] forState:UIControlStateNormal];
    
    [cell.addButton addTarget:self action:@selector(addPoint) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return friends.count;
}

-(void)addPoint
{
    NSLog(@"Button was touched");
}

@end
