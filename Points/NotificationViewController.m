//
//  NotificationViewController.m
//  Points
//
//  Created by Siddharth Sukumar on 2/18/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "NotificationViewController.h"
#import "Parse/Parse.h"

@interface NotificationViewController ()

{
    PFUser *currentUser;
}

@end

@implementation NotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    // need to query the database to find out all the notifications


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
