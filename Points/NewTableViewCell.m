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

@synthesize buttonWithTextToAddOrInvite, textfield, stringContainingUserID, group;


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
            if(!error){
                [relation addObject:object];
                [group saveInBackground];

            }
        }];
        
        
        
        
    }  else {
        
    }
    
    
}
    
    

}

@end
