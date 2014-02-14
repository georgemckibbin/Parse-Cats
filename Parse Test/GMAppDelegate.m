//
//  GMAppDelegate.m
//  Parse Test
//
//  Created by George McKibbin on 13/02/2014.
//
//

#import "GMAppDelegate.h"
#import <Parse/Parse.h>

@implementation GMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Just fill in these details and add the Parse Framework and you're good to go.
	[Parse setApplicationId:@"YOUR_APP_ID"
				  clientKey:@"YOUR_CLIENT_KEY"];
	
    return YES;
}

+(void)initialize
{
	[PFImageView class];
}

@end
