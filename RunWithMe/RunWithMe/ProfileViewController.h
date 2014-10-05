//
//  ProfileViewController.h
//  Run With Me
//
//  Created by Ethan Yu on 10/4/14.
//  Copyright (c) 2014 HackMIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) id ProfileItem;
@property (weak, nonatomic) IBOutlet UILabel *ProfileDescriptionLabel;

@end

