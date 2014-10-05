//
//  ProfileViewController.m
//  Run With Me
//
//  Created by Ethan Yu on 10/4/14.
//  Copyright (c) 2014 HackMIT. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

#pragma mark - Managing the Profile item

- (void)viewDidLoad {
	[super viewDidLoad];
	NSString *strurl = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?width=9999", self.fbusername];
	NSURL *url=[NSURL URLWithString:strurl];
	NSData *imageData = [NSData dataWithContentsOfURL:url];
	self.profilePicView.image = [UIImage imageWithData:imageData];
	self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.width / 2;
	self.profilePicView.clipsToBounds = YES;
	self.nameLabel.text = self.name;
	self.detailLabel.text = [NSString stringWithFormat:@"Distance from you: %@\nAverage pace: %@\nAverage length of run: %@", self.distance, self.avgPace, self.avgDistance];
}


@end
