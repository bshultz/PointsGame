//
//  NotificationTableViewCell.m
//  Points
//
//  Created by Siddharth Sukumar on 2/18/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell

@synthesize labelContainingGroupInformation, buttonToAcceptTheInvite, buttonToDeclineTheInvite;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

//        CGSize size = self.contentView.frame.size;

        self.labelContainingGroupInformation = [[UILabel alloc]initWithFrame:CGRectMake(30.0f, 0.0f, 300, 100)];
        labelContainingGroupInformation.numberOfLines = 0;
        labelContainingGroupInformation.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:self.labelContainingGroupInformation];

        self.buttonToAcceptTheInvite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.buttonToAcceptTheInvite.frame = CGRectMake(60.0f, 60.0f, 60, 20);
        [self.contentView addSubview:self.buttonToAcceptTheInvite];
        [self.buttonToAcceptTheInvite addTarget:self action:@selector(addPersonToGroup) forControlEvents:UIControlEventTouchUpInside];

        

        self.buttonToDeclineTheInvite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.buttonToDeclineTheInvite.frame = CGRectMake(200.0f, 60.0f, 60, 20);
         [self.contentView addSubview:self.buttonToDeclineTheInvite];
        [self.buttonToDeclineTheInvite addTarget:self action:@selector(doNotAddPersonToGroup) forControlEvents:UIControlEventTouchUpInside];


    }
    return self;
}

- (void) addPersonToGroup {

    PFUser *currentUser = [PFUser currentUser];

    // first step is to get the group and add the currentUser to the "myMembers" relation of group object"
    // if the first step succeeds, the second step is to add the group to the 'myGroups" relation of the user object"
    // if the second step succeeds, the next step is to delete the invite object

    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"objectId" equalTo:self.group.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error){
           NSLog (@"%@ %@", error, [error userInfo]);
        } else {
            PFRelation *relation = [object relationForKey:@"members"];
            [relation addObject:currentUser];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error){
                     NSLog (@"%@ %@", error, [error userInfo]);
                } else {

                    PFRelation *relation = [currentUser relationForKey:@"myGroups"];
                    [relation addObject:self.group];
                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error){
                              NSLog (@"%@ %@", error, [error userInfo]);
                        } else {
                            PFQuery *query = [PFQuery queryWithClassName:@"invite"];
                            [query whereKey:@"objectId" equalTo:self.invite.objectId];
                            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (error){
                                        NSLog (@"%@ %@", error, [error userInfo]);
                                    }
                                }];
                            }];

                        }
                    }];

                }
            }];
        }
    }];



}

- (void) doNotAddPersonToGroups {

    PFQuery *query = [PFQuery queryWithClassName:@"invite"];
    [query whereKey:@"objectId" equalTo:self.invite.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error){
                NSLog (@"%@ %@", error, [error userInfo]);
                
            }
        }];
    }];






}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
