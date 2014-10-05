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

@interface ResultsViewController ()

@property NSMutableArray *objects;

@end

@implementation ResultsViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([PFUser currentUser]) {
		// Create Facebook Request for user's details
//		FBRequest *request = [FBRequest requestForMe];
//		[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//			// This is an asynchronous method. When Facebook responds, if there are no errors, we'll update the Welcome label.
//			if (!error) {
//				NSString *displayName = result[@"name"];
//				if (displayName) {
//					self.welcomeLabel.text =[NSString stringWithFormat:@"Welcome %@!", displayName];
//				}
//			}
//		}];
		
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

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
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
