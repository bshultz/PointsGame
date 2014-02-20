//
//  FacebookViewController.m
//  Points
//
//  Created by Matthew Graham on 2/20/14.
//  Copyright (c) 2014 Matthew Graham. All rights reserved.
//

#import "FacebookViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookViewController ()

@end

@implementation FacebookViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width/2)), 250);
    [self.view addSubview:loginView];
    loginView.readPermissions = @[@"user_about_me", @"email", @"user_relationships"];
}


@end
