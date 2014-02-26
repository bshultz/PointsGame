//
//  GroupsViewController.m
//  Points
//
//  Created by Siddharth Sukumar on 2/10/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//
#import "GroupsViewController.h"
#import "Parse/Parse.h"
#import "FriendsViewController.h"

//line 190, 199, add bar button for search bar

@interface GroupsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSMutableArray *arrayOfAllTheUsersGroups;
@property (nonatomic, strong) NSMutableArray *filteredArray;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;

@end



@implementation GroupsViewController
@synthesize arrayOfAllTheUsersGroups, searchDisplayController;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:.05f green:.345f blue:.65f alpha:1.0f];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:RED/255.0f green:GREEN/255.0f blue:BLUE/255.0f alpha:1.0f];
    self.view.backgroundColor = [UIColor colorWithRed:0.408f green:0.612f blue:0.823f alpha:1.0f];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    self.myTableView.tableHeaderView = self.searchBar;
    self.myTableView.separatorColor = [UIColor colorWithRed:0.05f green:0.345f blue:0.65f alpha:0.5f];
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.myTableView setSeparatorInset:UIEdgeInsetsZero];

    
 // adding a clear button to the searchBar. Searchbar has a textfield, i find the textfield and then display the clear button
    for (UITextField *subview in self.searchBar.subviews)
        if ([subview isKindOfClass:[UITextField class]])
            [subview setClearButtonMode:UITextFieldViewModeWhileEditing];

    
    self.searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;


    
    //hides the search bar initially
    self.myTableView.contentOffset = CGPointMake(0, self.searchBar.bounds.size.height);

    

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self getGroups];
}


- (void) getGroups
{

    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationForKey:@"myGroups"];
    PFQuery *query = [relation query];
    [query orderByAscending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog (@"%@ %@", error, [error userInfo]);
        } else {
            self.arrayOfAllTheUsersGroups = [NSMutableArray arrayWithArray:objects];
            [self.myTableView reloadData];
        }
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredArray count];
        
    } else {
        return self.arrayOfAllTheUsersGroups.count;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFObject *object;

    

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (tableView == searchDisplayController.searchResultsTableView) {

         object = self.filteredArray[indexPath.row];
    
    } else {
         object = self.arrayOfAllTheUsersGroups[indexPath.row];
        
    }
    cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
    cell.textLabel.text = object[@"name"];
    return cell;

}



    
#pragma mark - Content Filtering

// Update the filtered array based on the scope and searchText

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self.filteredArray removeAllObjects];
    
    // Filter the array using NSPredicate
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains [c] %@", searchString];
    self.filteredArray = [NSMutableArray arrayWithArray:[self.arrayOfAllTheUsersGroups filteredArrayUsingPredicate:resultPredicate]];
    
    return YES;
}


#pragma mark - Search Button 

- (IBAction)onSearchButtonClicked:(id)sender {
    self.myTableView.contentOffset = CGPointMake(0, -64);
    [searchDisplayController setActive:YES animated:YES];
    [searchDisplayController.searchBar becomeFirstResponder];
    
}
#pragma mark - Segue

// need to check if the user selects an item from the regular tableView or the tableView that the SearchDisplayController adds
// Grab the groupID from the selected object and pass it forward to the FriendsViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"FriendsDetail"]) {
        
        FriendsViewController *friendsListDetailViewController = [segue destinationViewController];
        if (sender == self.searchDisplayController.searchResultsTableView) {
            
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            friendsListDetailViewController.groupID = [[self.filteredArray objectAtIndex:indexPath.row] objectId];
            
            
        } else {
            NSIndexPath *indexPath = [self.myTableView indexPathForSelectedRow];
            friendsListDetailViewController.groupID = [[self.arrayOfAllTheUsersGroups objectAtIndex:indexPath.row] objectId];
        }
    }
}




@end