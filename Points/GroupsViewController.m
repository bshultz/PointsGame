//
//  GroupsViewController.m
//  Points
//
//  Created by Siddharth Sukumar on 2/10/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//
#import "GroupsViewController.h"
#import "Parse/Parse.h"

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
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    [self.view addSubview:self.searchBar];
    self.myTableView.tableHeaderView = self.searchBar;

    
 // adding a clear button to the searchBar
    for (UIView *subview in self.searchBar.subviews)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            [(UITextField *)subview setClearButtonMode:UITextFieldViewModeWhileEditing];
        }
    }

    
    self.searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    
   
    
//    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]
//                                   initWithTitle:@"Search"
//                                   style:UIBarButtonItemStyleBordered
//                                   target:self
//                                   action:@selector(goToSearch:)];
//    self.navigationItem.leftBarButtonItem = searchButton;
//
    
    //hides the search bar initially
//    self.myTableView.contentOffset = CGPointMake(0, self.searchBar.bounds.size.height);
    
    // Initialize the filtered array with a capacity equal to the capacity of our main array
//    self.filteredArray = [NSMutableArray arrayWithCapacity:[self.arrayOfAllTheUsersGroups count]];
    

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
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
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {

         object = self.filteredArray[indexPath.row];
    
    } else {
         object = self.arrayOfAllTheUsersGroups[indexPath.row];
        
    }
    cell.textLabel.text = object[@"name"];
    return cell;

}


-(IBAction)goToSearch:(id)sender {
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
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

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Perform segue to individual friends detail view
    
    [self performSegueWithIdentifier:@"FriendsDetail" sender:tableView];
    
}
- (IBAction)onSearchButtonClicked:(id)sender {
    
}

#pragma mark - Segue

// need to check if the user selects an item from the regular tableView or the tableView that the SearchDisplayController adds

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"FriendsDetail"]) {
        UIViewController *friendsListDetailViewController = [segue destinationViewController];
        if (sender == self.searchDisplayController.searchResultsTableView) {
            
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            NSString *destinationTitle = [[self.filteredArray objectAtIndex:[indexPath row]] name];
            [friendsListDetailViewController setTitle:destinationTitle];
            
        } else {
            NSIndexPath *indexPath = [self.myTableView indexPathForSelectedRow];
            NSString *destinationTitle = [[self.arrayOfAllTheUsersGroups objectAtIndex:[indexPath row]] name];
            [friendsListDetailViewController setTitle:destinationTitle];
            
        }
    }
    
    
    
    
}




@end