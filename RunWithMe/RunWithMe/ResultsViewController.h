//
//  ResultsViewController.h
//  Run With Me
//
//  Created by Ethan Yu on 10/4/14.
//  Copyright (c) 2014 HackMIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <OAUthiOS/OAuthiOS.h>
#import "OAuth1Controller.h"

@interface ResultsViewController : UITableViewController  <PFLogInViewControllerDelegate, CLLocationManagerDelegate, OAuthIODelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL fitbitAuthenticated;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;
@property (nonatomic, strong) NSString *myUsername;
@property (nonatomic) float averagePace;
@property (nonatomic) float averageDistance;

@end

