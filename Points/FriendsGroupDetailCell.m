//
//  FriendsGroupDetailCell.m
//  Points
//
//  Created by Matthew Graham on 2/14/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "FriendsGroupDetailCell.h"

@implementation FriendsGroupDetailCell

@synthesize profileImage;
@synthesize name;
@synthesize points;
@synthesize addButton;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize size = self.contentView.frame.size;
        
        profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 45.0f)];
        [self.contentView addSubview:profileImage];
        
        name = [[UILabel alloc] initWithFrame:CGRectMake(55.0f, 0.0f, size.width - 60.0f, size.height - 4.0f)];
        [self.contentView addSubview:name];
        
        points = [[UILabel alloc] initWithFrame:CGRectMake(260.0f, 0.0f, size.width - 20.0f, size.height - 4.0f)];
        [self.contentView addSubview:points];
    
        addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addButton.frame = CGRectMake(280.0f, 10.0f, 150.0f, 150.0f);
        
        CGRect buttonFrame = addButton.frame;
        buttonFrame.size = CGSizeMake(45.0f, 45.0f);
        addButton.frame = buttonFrame;
        addButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:addButton];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
