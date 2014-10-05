//
//  AppDelegate.m
//  Run With Me
//
//  Created by Ethan Yu on 10/4/14.
//  Copyright (c) 2014 HackMIT. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[Parse setApplicationId:@"27OKfEfexHMr1l0IQn2XLsVzNfdZbUi6Rhobo1zv" clientKey:@"WvmQ6Ko52TKKvWmlz9tMKwWJrfJLxtnLN4OiKUNI"];
	[PFFacebookUtils initializeFacebook];
	
	// Set default ACLs
	PFACL *defaultACL = [PFACL ACL];
	[defaultACL setPublicReadAccess:YES];
	[PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

	return YES;
}

// Facebook oauth callback
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Handle an interruption during the authorization flow, such as the user clicking the home button.
	[FBSession.activeSession handleDidBecomeActive];
}

@end

