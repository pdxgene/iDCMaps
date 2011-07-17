//
//  Sample2AppDelegate.m
//  SampleMap : Diagnostic map
//

#import "iDCMapsAppDelegate.h"
#import "RootViewController.h"
#import "MainViewController.h"

@implementation iDCMapsAppDelegate


@synthesize window;
@synthesize rootViewController;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectContext;
@synthesize managedObjectModel;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		// Handle the error.
	}

    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
}

-(RMMapContents *)mapContents
{
	return self.rootViewController.mainViewController.mapView.contents;
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle the error.
        } 
    }
}


- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}

@end
