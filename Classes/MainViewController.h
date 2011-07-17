//
//  MainViewController.h
//  SampleMap : Diagnostic map
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@interface MainViewController : UIViewController <RMMapViewDelegate, CLLocationManagerDelegate> {
	IBOutlet RMMapView * mapView;
	IBOutlet UITextView * infoTextView;
    CLLocationManager* locationManager;
    NSManagedObjectContext *managedObjectContext;
    IBOutlet UIButton *saveButton;

}
@property (nonatomic, retain) IBOutlet RMMapView * mapView;
@property (nonatomic, retain) IBOutlet UITextView * infoTextView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	    
@property (nonatomic, retain) IBOutlet UIButton *saveButton;

- (void)updateInfo;
- (IBAction)saveMap;
- (void)addMap;
- (void)addTile:(int)zoom atTileX:(int)x atTileY:(int)y;
@end
