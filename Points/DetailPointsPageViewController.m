//
//  DetailPointsPageViewController.m
//  Points
//
//  Created by Brad Shultz on 2/17/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "DetailPointsPageViewController.h"
#import "Parse/Parse.h"

@interface DetailPointsPageViewController ()  <UITableViewDataSource, UITableViewDelegate>
{
    //instance variables
    PFQuery *query;
    NSMutableArray *fromUsers;
    NSMutableArray *comments;
    NSMutableArray *timeStamps;

    __weak IBOutlet UITableView *detailPointsTableView;

}

@end

@implementation DetailPointsPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"username: %@", self.userName);
    NSLog(@"groupname: %@", self.groupName);
    [self getPointDetail];
    
    detailPointsTableView.separatorColor = [UIColor colorWithRed:0.05f green:0.345f blue:0.65f alpha:0.5f];
    detailPointsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [detailPointsTableView setSeparatorInset:UIEdgeInsetsZero];

}




-(void)getPointDetail
{
    query = [PFQuery queryWithClassName:@"Point"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"group" equalTo:self.groupName];
    [query includeKey:@"fromUser"];
    [query includeKey:@"toUser"];
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"User"];
    [toUserQuery whereKey:@"objectId" equalTo:self.userName];
    

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             fromUsers = [NSMutableArray new];
             comments = [NSMutableArray new];
             timeStamps = [NSMutableArray new];
             for (PFObject *object in objects)
             {
                 PFObject *toUser = [object objectForKey:@"toUser"];
                 if ([toUser.objectId isEqualToString:self.userName])
                 {
                     PFObject *fromUser = [object objectForKey:@"fromUser"];
                     [fromUsers addObject:[fromUser objectForKey:@"fullName"]];
                     [timeStamps addObject:object.createdAt];
                     [comments addObject:[object objectForKey:@"comment"]];
                     [detailPointsTableView reloadData];
                 }
             }
         }
         else
         {
             NSLog(@"Error: %@", error);
         }
     }];
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return comments.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendsCommentsCell"];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [comments objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [fromUsers objectAtIndex:indexPath.row];
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0f;
}

@end
