//
//  TableViewCellDelegate.h
//  Points
//
//  Created by Siddharth Sukumar on 2/22/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationTableViewCell.h"

@protocol NotificationTableViewCellDelegate <NSObject>

- (void) didWantToDeleteCell: (id) NotificationTableViewCell atIndexPath:(NSIndexPath *)indexPath forGroup:(NSString *)groupId;

@end
