//
//  NewTableViewCell.h
//  Points
//
//  Created by Siddharth Sukumar on 2/17/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import <MessageUI/MessageUI.h>
#import "NewTableViewCellDelegate.h"

@interface NewTableViewCell : UITableViewCell




@property NSString *stringContainingUserID;;
@property UIButton *buttonWithTextToAddOrInvite;
@property  UILabel *labelWithPersonsName;
@property PFObject *group;
@property PFUser *currentUser;

@property id<NewTableViewCellDelegate> delegate;



@end


