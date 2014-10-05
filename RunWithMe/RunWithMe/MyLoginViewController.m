//
//  MyLoginViewController.m
//  Run With Me
//
//  Created by Ethan Yu on 10/4/14.
//  Copyright (c) 2014 HackMIT. All rights reserved.
//

#import "MyLoginViewController.h"

@implementation MyLoginViewController 

- (void)viewDidLoad {
	[super viewDidLoad];
	UILabel *label = [[UILabel alloc] init];
	label.text = @"Run With Me";
	self.logInView.logo = label;
}


- (void)logInViewController:(PFLogInViewController *)controller
			   didLogInUser:(PFUser *)user {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
	[self dismissViewControllerAnimated:YES completion:nil];
}


@end
