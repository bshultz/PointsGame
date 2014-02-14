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
    FriendsGroupDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendDetailCell"];
    cell.textLabel.text = [friends objectAtIndex:indexPath.row];
    UIImageView *accessoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, 25.0f)];
    accessoryImage.contentMode = UIViewContentModeScaleAspectFill;
    accessoryImage.image = [UIImage imageNamed:@"addbutton.jpeg"];
    
    PFFile *theImage = [friendImages objectAtIndex:indexPath.row];
    NSData *imageData = [theImage getData];
    cell.imageView.frame = CGRectMake(0.0f, 0.0f, 35.0f, 35.0f);
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.image = [UIImage imageWithData:imageData];
    [cell setAccessoryView:accessoryImage];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return friends.count;
}

@end
