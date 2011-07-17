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

}
@property (nonatomic, retain) IBOutlet RMMapView * mapView;
@property (nonatomic, retain) IBOutlet UITextView * infoTextView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	    


- (void)updateInfo;
- (void)addMap;

@end
