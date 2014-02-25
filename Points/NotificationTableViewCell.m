//
//  NotificationTableViewCell.m
//  Points
//
//  Created by Siddharth Sukumar on 2/18/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "NotificationTableViewCell.h"

@implementation NotificationTableViewCell

@synthesize labelContainingGroupInformation, buttonToAcceptTheInvite, buttonToDeclineTheInvite, delegate, indexPath, number;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

//        CGSize size = self.contentView.frame.size;

        self.labelContainingGroupInformation = [[UILabel alloc]initWithFrame:CGRectMake(10.0f, -30.0f, 300.0f, 120.0f)];
        labelContainingGroupInformation.numberOfLines = 0;
        labelContainingGroupInformation.lineBreakMode = NSLineBreakByWordWrapping;
        labelContainingGroupInformation.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.labelContainingGroupInformation];

        self.buttonToAcceptTheInvite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.buttonToAcceptTheInvite.frame = CGRectMake(60.0f, 60.0f, 60, 20);
        self.buttonToAcceptTheInvite.tintColor = [UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f];
        [self.contentView addSubview:self.buttonToAcceptTheInvite];
        [self.buttonToAcceptTheInvite addTarget:self action:@selector(addPersonToGroup) forControlEvents:UIControlEventTouchUpInside];

        

        self.buttonToDeclineTheInvite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.buttonToDeclineTheInvite.frame = CGRectMake(200.0f, 60.0f, 60, 20);
        self.buttonToDeclineTheInvite.tintColor = [UIColor colorWithRed:1.0f green:0.6f blue:0.0f alpha:1.0f];
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

   PFRelation *relation = [self.group relationForKey:@"members"];
    [relation addObject:currentUser];
    [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
         NSLog (@"%@ %@", error, [error userInfo]);
        } else {
            PFRelation *relation = [currentUser relationForKey:@"myGroups"];
             [relation addObject:self.group];
             [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (error){
                    NSLog (@"%@ %@", error, [error userInfo]);
                 } else {
                     [self.invite deleteInBackground];
                     [self.delegate  didWantToDeleteCell:self atIndexPath:self.indexPath forGroup:self.groupID];
                     
                 }
             }];

        }
    }];




}

- (void) doNotAddPersonToGroup {

    PFQuery *query = [PFQuery queryWithClassName:@"invite"];
    [query whereKey:@"objectId" equalTo:self.invite.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error){
                NSLog (@"%@ %@", error, [error userInfo]);
                
            } else  {
                [self.delegate  didWantToDeleteCell:self atIndexPath:self.indexPath forGroup:self.groupID];
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
