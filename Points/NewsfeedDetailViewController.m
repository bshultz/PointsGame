//
//  NewsfeedDetailViewController.m
//  Points
//
//  Created by Matthew Graham on 2/20/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "NewsfeedDetailViewController.h"
#import "Parse/Parse.h"

@interface NewsfeedDetailViewController ()
{
    __weak IBOutlet UIImageView *profileImage;
    __weak IBOutlet UILabel *date;
    __weak IBOutlet UILabel *fromUser;
    __weak IBOutlet UITextView *commentTextView;
    
}

@end

@implementation NewsfeedDetailViewController
@synthesize pointId;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.408f green:0.612f blue:0.823f alpha:1.0f];
    PFQuery *query = [PFQuery queryWithClassName:@"Point"];
    [query includeKey:@"fromUser"];
    [query includeKey:@"toUser"];
    [query whereKey:@"objectId" equalTo:self.pointId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             for (PFObject *object in objects)
             {
                 NSDateFormatter *dateFormat = [NSDateFormatter new];
                 [dateFormat setDateStyle:NSDateFormatterMediumStyle];
                 NSDate *createDate = object.createdAt;
                 
                 date.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
                 date.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:createDate]];
                 
                 PFObject *fromUserObject = [object objectForKey:@"fromUser"];
                 fromUser.font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:12.0f];
                 fromUser.text = [fromUserObject objectForKey:@"fullName"];
                 
                 PFObject *toUserObject = [object objectForKey:@"toUser"];
                 PFFile *theImage = [toUserObject objectForKey:@"userImage"];
                 NSData *theData = [theImage getData];
                 profileImage.layer.masksToBounds = YES;
                 profileImage.layer.cornerRadius = 25.0f;
                 profileImage.contentMode = UIViewContentModeScaleAspectFill;
                 profileImage.image = [UIImage imageWithData:theData];
                 
                 commentTextView.layer.borderWidth = 2.0f;
                 commentTextView.layer.borderColor = [[UIColor colorWithRed:0.05f green:0.345f blue:0.65f alpha:1.0f] CGColor];
                 commentTextView.text = [object objectForKey:@"comment"];
                 
             }
         }
     }];
}





@end
