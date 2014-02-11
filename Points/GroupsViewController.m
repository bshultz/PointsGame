//
//  GroupsViewController.m
//  Points
//
//  Created by Siddharth Sukumar on 2/10/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//
#import "GroupsViewController.h"
#import "Parse/Parse.h"



@interface GroupsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray *arrayOfAllTheUsersGroups;
@property (nonatomic, strong) NSArray *filteredData;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;

@end



@implementation GroupsViewController
@synthesize arrayOfAllTheUsersGroups;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    [self.view addSubview:self.searchBar];
    self.searchBar.delegate = self;
    [self getGroups];
}


- (void) getGroups
{

    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationForKey:@"myGroups"];
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog (@"%@ %@", error, [error userInfo]);
        } else {
            self.arrayOfAllTheUsersGroups = objects;
            [self.myTableView reloadData];
        }
    }];

}



-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText

{

    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"myGroups"];
    [[relation query] whereKey:@"name" containsString:searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        self.arrayOfAllTheUsersGroups = objects;
        [self.myTableView reloadData];
    }];

    [self.myTableView reloadData];

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayOfAllTheUsersGroups.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFObject *object = self.arrayOfAllTheUsersGroups[indexPath.row];
    cell.textLabel.text = object[@"name"];
    return cell;

}



#pragma mark SearchDisplayController

/*

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    [self filterContentForSearchText:searchString

    scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return nil;
}


- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
}



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@", searchText];
    self.filteredData = [self.arrayOfAllTheUsersGroups filteredArrayUsingPredicate:resultPredicate];

}
*/

@end