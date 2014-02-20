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
    NSMutableArray *usersGroups;
    NSMutableArray *transactions;
    NSMutableArray *from;
    NSMutableArray *to;
    NSMutableArray *objectIDs;
    

    __weak IBOutlet UITableView *detailPointsTableView;

}

@end

@implementation DetailPointsPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    [self getGroups];
    [self getTransactions];
    NSLog(@"username: %@", self.userName);
    NSLog(@"groupname: %@", self.groupName);
}




-(void)getTransactions
{
    query = [PFQuery queryWithClassName:@"Transaction"];
    query.limit = 25;
    [query orderByDescending:@"createdAt"];

//    [query whereKey:@"toUser" equalTo:self.userName];
    
//    [query whereKey:@"groupId" equalTo:self.groupName];
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
                 NSLog(@"%@", object);
             }
         }
         [detailPointsTableView reloadData];
     }];
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return transactions.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFObject *object;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }    
        object = transactions[indexPath.row];
    cell.textLabel.text = object[@"action"];
    return cell;
    
}


@end
