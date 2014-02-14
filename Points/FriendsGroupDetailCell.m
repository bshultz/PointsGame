//
//  FriendsGroupDetailCell.m
//  Points
//
//  Created by Matthew Graham on 2/14/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "FriendsGroupDetailCell.h"

@implementation FriendsGroupDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addButton.frame = CGRectMake(260.0f, 0.0f, 30.0f, 30.0f);
        addButton.imageView.image = [UIImage imageNamed:@"addbutton.jpeg"];
        
        [self addSubview:addButton];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
