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

@synthesize buttonWithTextToAddOrInvite, textfield, stringContainingUserID, group, currentUser;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        

    }
    return self;
}

- (IBAction)OnAddButtonPressed:(UIButton *)sender{
    
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
