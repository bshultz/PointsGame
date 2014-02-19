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

        self.buttonToDeclineTheInvite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.buttonToDeclineTheInvite.frame = CGRectMake(200.0f, 60.0f, 60, 20);
         [self.contentView addSubview:self.buttonToDeclineTheInvite];

        

        


    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
