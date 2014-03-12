//
//  FriendsGroupDetailCell.m
//  Points
//
//  Created by Matthew Graham on 2/14/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "FriendsGroupDetailCell.h"
#import "UIView+Autolayout.h"


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
        
        points = [[UILabel alloc] initWithFrame:CGRectMake(300.0f, 0.0f, size.width - 20.0f, size.height - 4.0f)];
        [self.contentView addSubview:points];

        [points setTranslatesAutoresizingMaskIntoConstraints:NO];
    
        addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addButton.frame = CGRectMake(210.0f, 5.0f, 40.0f, 80.0f);
        
        CGRect buttonFrame = addButton.frame;
        buttonFrame.size = CGSizeMake(80.0f, 35.0f);
        addButton.frame = buttonFrame;
        addButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:addButton];
        
        UILabel *addLabel;addLabel = [[UILabel alloc] initWithFrame:(CGRectMake(10.0f, 5.0f, 70.0f, 25.0f))];
        addLabel.text = @"+ Point";
        addLabel.textColor = [UIColor whiteColor];
        [addButton addSubview:addLabel];
        [addButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        

        [self addConstraints];
        
    }
    return self;
}

- (void) addConstraints {

    [addButton constrainToWidth:80.0f];
    [addButton constrainToHeight:35.0f];
    
    [points pinToSuperviewEdges:JRTViewPinRightEdge inset:5.0f];
    [addButton pinToSuperviewEdges:JRTViewPinRightEdge inset:30.0];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
