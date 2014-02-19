//
//  NotificationTableViewCell.h
//  Points
//
//  Created by Siddharth Sukumar on 2/18/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *labelContainingGroupInformation;
@property (nonatomic, strong) UIButton * buttonToAcceptTheInvite;
@property (nonatomic, strong) UIButton * buttonToDeclineTheInvite;


@end
