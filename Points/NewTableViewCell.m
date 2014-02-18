//
//  NewTableViewCell.m
//  Points
//
//  Created by Siddharth Sukumar on 2/17/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "NewTableViewCell.h"

@implementation NewTableViewCell

@synthesize buttonWithTextToAddOrInvite;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize size = self.contentView.frame.size;
        
        buttonWithTextToAddOrInvite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buttonWithTextToAddOrInvite.frame = CGRectMake(260, 10.0f, 30.0f, 25.0f);
        [self.contentView addSubview:buttonWithTextToAddOrInvite];
        
        

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
