//
//  NewTableViewCell.m
//  Points
//
//  Created by Siddharth Sukumar on 2/17/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "NewTableViewCell.h"
#import "Parse/Parse.h"

@implementation NewTableViewCell

@synthesize labelWithPersonsName, buttonWithTextToAddOrInvite, stringContainingUserID, group, currentUser;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.labelWithPersonsName = [[UILabel alloc]initWithFrame:CGRectMake(20.0f, 5.0f, 180.0f, 40.0f)];
        [self.contentView addSubview:self.labelWithPersonsName];


        self.buttonWithTextToAddOrInvite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.buttonWithTextToAddOrInvite.frame = CGRectMake(250.0f, 5.0f, 60, 40.0f);
        self.buttonWithTextToAddOrInvite.tintColor = [UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f];
        [self.contentView addSubview:self.buttonWithTextToAddOrInvite];
        [self.buttonWithTextToAddOrInvite addTarget:self action:@selector(OnAddButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}

- (void)OnAddButtonPressed:(UIButton *)sender{
    
    if([sender.titleLabel.text isEqualToString:@"Add"]){
        PFRelation *relation = [group relationForKey:@"members"];
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"uniqueFacebookID" equalTo:stringContainingUserID];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(error)
            {
                NSLog(@"Save Error: %@", error);
            }
            else
                {

                // create a invite object and send a invite this person

                    PFObject *invite = [PFObject objectWithClassName:@"invite"];
                    invite[@"fromUser"] = currentUser;
                    invite[@"toUser"] = object;
                    [invite setObject:[NSNumber numberWithBool:NO] forKey:@"acceptedInvite"];
                    invite[@"group"] = group;
                    [invite saveInBackground];
                    
                    [buttonWithTextToAddOrInvite setTitle:@"Request Sent" forState:UIControlStateNormal];
                    [buttonWithTextToAddOrInvite setEnabled:NO];
                

                }
            }];

        }
    else
    {
        // Send an invite to a non-registered user
        NSLog(@"The invite button was pressed.");
    }
    
    
}
    
    


@end
