//
//  NewTableViewCell.m
//  Points
//
//  Created by Siddharth Sukumar on 2/17/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "NewTableViewCell.h"

@implementation NewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
