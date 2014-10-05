//
//  ResultsViewController.m
//  Run With Me
//
//  Created by Ethan Yu on 10/4/14.
//  Copyright (c) 2014 HackMIT. All rights reserved.
//

#import "ResultsViewController.h"
#import "MyLoginViewController.h"
#import "ResultsCell.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>

@interface ResultsViewController ()

@property NSMutableArray *objects;

@end

@implementation ResultsViewController

- (void)viewDidLoad {
	CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
	if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
		[self getLocation];
	}
	else if (status == kCLAuthorizationStatusNotDetermined) {
		[[self locationManager] requestWhenInUseAuthorization];
	}
	self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:48/255.0f green:130/255.0f blue:163/255.0f alpha:1];
	self.navigationController.navigationBar.translucent = NO;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.fitbitAuthenticated = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([PFUser currentUser]) {
		FBRequest *request = [FBRequest requestForMe];
		[request startWithCompletionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			if (!error) {
				NSString *facebookUsername = [result objectForKey:@"id"];
				NSString *realName = [result objectForKey:@"name"];
				[[PFUser currentUser] setObject:facebookUsername forKey:@"fbusername"];
				[[PFUser currentUser] setObject:realName forKey:@"realName"];
				[[PFUser currentUser] saveEventually];
			}
		}];
		
		[PFCloud callFunctionInBackground:@"usersNearMe"
						   withParameters:@{@"username" : [[PFUser currentUser] username]}
									block:^(id result, NSError *error) {
										if (!error) {
											_objects = result;
											NSLog(@"Objects array %@", _objects);
											[self.tableView reloadData];
										}
									}];
		
	} else {
		[self showLoginView];
	}
    
    [self showFitbitView];
}

- (void)showLoginView {
	// Customize the Log In View Controller
	MyLoginViewController *myLoginViewController = [[MyLoginViewController alloc] initWithNibName:nil bundle:nil];
	[myLoginViewController setDelegate:self];
	//[myLoginViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
	[myLoginViewController setFields: PFLogInFieldsFacebook];
	// Present Log In View Controller
	[self presentViewController:myLoginViewController animated:YES completion:nil];
}

- (CLLocationManager *)locationManager {
	if (_locationManager != nil) {
		return _locationManager;
	}
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[_locationManager setDelegate:self];
 
	return _locationManager;
}

- (void)getLocation {
	if ([CLLocationManager locationServicesEnabled]) {
		[[self locationManager] startUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
		[[self locationManager] startUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	NSLog(@"Location updated");
	CLLocation *location = _locationManager.location;
	CLLocationCoordinate2D coordinate = [location coordinate];
	PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude
												  longitude:coordinate.longitude];
	[[PFUser currentUser] setObject:geoPoint forKey:@"location"];
	[[PFUser currentUser] saveEventually];
	[[self locationManager] stopUpdatingLocation];
}


- (void)logInViewController:(PFLogInViewController *)controller didLogInUser:(PFUser *)user {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showProfile"]) {
		ProfileViewController *profileViewController = [segue destinationViewController];
		ResultsCell *cell = (ResultsCell *)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
		profileViewController.profilePicData = UIImagePNGRepresentation(cell.image.image);
		profileViewController.name = cell.nameLabel.text;
		profileViewController.distance = cell.distanceLabel.text;
		profileViewController.avgPace = cell.avgPace;
		profileViewController.avgDistance = cell.avgDistance;
		UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
		[[self navigationItem] setBackBarButtonItem:newBackButton];
		NSLog(@"%@, %@, %@, %@", profileViewController.name, profileViewController.distance, profileViewController.avgPace, profileViewController.avgDistance);
	}
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (_objects == nil) {
		return 0;
	}
	else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_objects == nil)
		return 0;
	else {
		return [self.objects count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	if (!cell) {
		cell = [[ResultsCell alloc] init];
	}
	NSDictionary *dict = _objects[indexPath.row];

	cell.nameLabel.text = dict[@"realName"];
	cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f mi.", [dict[@"distance"] floatValue]];
	NSString *strurl = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", [_objects[indexPath.row] objectForKey:@"fbusername"]];
	cell.avgDistance = [NSString stringWithFormat:@"%.1f miles", [dict[@"averagedistance"] floatValue]];
	cell.avgPace = [NSString stringWithFormat:@"%.1f minutes/mile", [dict[@"averagepace"] floatValue]];
	NSURL *url=[NSURL URLWithString:strurl];
	NSData *imageData = [NSData dataWithContentsOfURL:url];
	UIImage *profilePic = [UIImage imageWithData:imageData];
	cell.image.image = profilePic;
	cell.image.layer.cornerRadius = cell.image.frame.size.width / 2;
	cell.image.clipsToBounds = YES;
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	    [self.objects removeObjectAtIndex:indexPath.row];
	    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
	    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
	}
}

#pragma mark - Fitbit integration

- (void)didReceiveOAuthIOResponse:(OAuthIORequest *)request
{
    NSDictionary *credentials = [request getCredentials];
    self.oauthToken = [credentials valueForKey:@"oauth_token"];
    self.oauthTokenSecret = [credentials valueForKey:@"oauth_token_secret"];
    [self pushActivityMetric];
}

- (void)pushActivityMetric
{
    NSString *path = @"1/user/-/activities/goals/weekly.json";
    
    NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:path
                                                                  parameters:nil
                                                                  HTTPmethod:@"GET"
                                                                  oauthToken:self.oauthToken
                                                                 oauthSecret:self.oauthTokenSecret];
    
    [NSURLConnection sendAsynchronousRequest:preparedRequest
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   NSError *error = nil;
                                   NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   float averageDistance = [[[json valueForKey:@"goals"] valueForKey:@"distance"] floatValue];
                                   float averagePace = averageDistance;
                                   
                                   NSNumber *avgDistance = [NSNumber numberWithFloat:averageDistance/66.7];
                                   NSNumber *avgPace = [NSNumber numberWithFloat:averagePace];
                                   
                                   NSLog(@"%f", averagePace);
                                   NSLog(@"%f", averageDistance);
                                   
                                   [[PFUser currentUser] setObject:avgPace forKey:@"avgPace"];
                                   [[PFUser currentUser] setObject:avgDistance forKey:@"avgDistance"];
                                   [[PFUser currentUser] saveEventually];
                                   
                                   if (error) NSLog(@"Error in API request: %@", error.localizedDescription);
                               });
                           }];
}

- (void)showFitbitView
{
    if (!self.fitbitAuthenticated)
    {
        OAuthIOModal *oauthioModal = [[OAuthIOModal alloc] initWithKey:@"Pd2cIrOq7a02OhCtteV_rgzNuvY" delegate:self];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:@"true" forKey:@"cache"];
        [oauthioModal showWithProvider:@"fitbit" options:options];
        
        self.fitbitAuthenticated = YES;
    }
}

@end
