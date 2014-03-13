//
//  FacebookFriendsViewController.h
//  Points
//
//  Created by Siddharth Sukumar on 2/21/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

static const int RED = 77 ;
static const int GREEN = 169;
static const int BLUE = 157;

@interface FacebookFriendsViewController : UIViewController

@property (nonatomic, strong) PFObject *group;
@property (nonatomic) BOOL isANewGroupBeingAdded;
@property (nonatomic, strong) NSArray *arrayWithTheNamesOfTheCurrentMemebersOfTheGroup;
@end
