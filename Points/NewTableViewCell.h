//
//  NewTableViewCell.h
//  Points
//
//  Created by Siddharth Sukumar on 2/17/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface NewTableViewCell : UITableViewCell

@property IBOutlet UIButton *buttonWithTextToAddOrInvite;
@property IBOutlet UILabel *textfield;
@property NSString *stringContainingUserID;;
@property PFObject *group;
@end
