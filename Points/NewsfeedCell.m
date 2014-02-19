//
//  NewsfeedCell.m
//  Points
//
//  Created by Matthew Graham on 2/19/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "NewsfeedCell.h"

@implementation NewsfeedCell
@synthesize profileImage;
@synthesize text;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize size = self.contentView.frame.size;
        
        profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 45.0f)];
        [self.contentView addSubview:profileImage];
        
        text = [[UILabel alloc] initWithFrame:CGRectMake(55.0f, 0.0f, size.width - 60.0f, size.height - 4.0f)];
        [self.contentView addSubview:text];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
