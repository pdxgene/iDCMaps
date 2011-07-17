//
//  Sample2AppDelegate.h
//  SampleMap : Diagnostic map
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@class RootViewController;

@interface iDCMapsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RootViewController *rootViewController;

    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, readonly) RMMapContents *mapContents;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

