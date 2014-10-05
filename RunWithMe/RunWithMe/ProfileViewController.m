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

- (void)setProfileItem:(id)newProfileItem {
	if (_ProfileItem != newProfileItem) {
	    _ProfileItem = newProfileItem;
	        
	    // Update the view.
	    [self configureView];
	}
}

- (void)configureView {
	// Update the user interface for the Profile item.
	if (self.ProfileItem) {
	    self.ProfileDescriptionLabel.text = [self.ProfileItem description];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
