//
//  ResultsViewController.m
//  Run With Me
//
//  Created by Ethan Yu on 10/4/14.
//  Copyright (c) 2014 HackMIT. All rights reserved.
//

#import "ResultsViewController.h"
#import "MyLoginViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>

@interface ResultsViewController ()

@property NSMutableArray *objects;

@end

@implementation ResultsViewController

- (void)viewDidLoad {
	CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
	if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
		[self getLocation];
	}
	else if (status == kCLAuthorizationStatusNotDetermined) {
		[[self locationManager] requestWhenInUseAuthorization];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([PFUser currentUser]) {
		FBRequest *request = [FBRequest requestForMe];
		[request startWithCompletionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			if (!error) {
				NSString *facebookUsername = [result objectForKey:@"id"];
				[[PFUser currentUser] setObject:facebookUsername forKey:@"fbusername"];
				[[PFUser currentUser] saveEventually];
			}
		}];
		
		[PFCloud callFunctionInBackground:@"usersNearMe"
						   withParameters:@{@"username" : [[PFUser currentUser] username]}
									block:^(id object, NSError *error) {
										if (!error) {
											NSArray *myJsonString = object;
											NSLog(@"My json array %@", myJsonString);
										}
									}];
		
	} else {
		[self showLoginView];
	}
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
	if (status == kCLAuthorizationStatusAuthorized) {
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
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//	if ([[segue identifier] isEqualToString:@"showDetail"]) {
//	    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//	    NSDate *object = self.objects[indexPath.row];
////	    [[segue destinationViewController] setProfileItem:object];
//	}
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 0;
}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	return self.objects.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//
//	NSDate *object = self.objects[indexPath.row];
//	cell.textLabel.text = [object description];
//	return cell;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//	// Return NO if you do not want the specified item to be editable.
//	return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//	if (editingStyle == UITableViewCellEditingStyleDelete) {
//	    [self.objects removeObjectAtIndex:indexPath.row];
//	    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
//	    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//	}
//}

@end
