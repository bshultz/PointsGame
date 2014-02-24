//
//  NotificationTableViewCell.h
//  Points
//
//  Created by Siddharth Sukumar on 2/18/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "NotificationTableViewCellDelegate.h"

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *labelContainingGroupInformation;
@property (nonatomic, strong) UIButton * buttonToAcceptTheInvite;
@property (nonatomic, strong) UIButton * buttonToDeclineTheInvite;
@property (nonatomic, strong) PFObject *group;
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) PFObject *invite;
@property id<NotificationTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic) int number;
@end
