//
//  MainViewController.m
//  SampleMap : Diagnostic map
//

#import "MainViewController.h"
#import "iDCMapsAppDelegate.h"

#import "MainView.h"

#import "RMCloudMadeMapSource.h"
#import "RMOpenCycleMapSource.h"
#import "Map.h"


@implementation MainViewController

@synthesize mapView;
@synthesize infoTextView;
@synthesize managedObjectContext;
@synthesize saveButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (IBAction)saveMap{
    [self addMap];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    
    if (managedObjectContext == nil) 
    { 
        managedObjectContext = [(iDCMapsAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"After managedObjectContext: %@",  managedObjectContext);
    }

    if (!locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = 10; // 1000 = kilometer
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    
    [locationManager startUpdatingLocation];
    NSLog (@"Locating started");


    [mapView setDelegate:self];
//	id myTilesource = [[[RMCloudMadeMapSource alloc] initWithAccessKey:@"0199bdee456e59ce950b0156029d6934" styleNumber:999] autorelease];
    id myTilesource = [[[RMOpenCycleMapSource alloc] init] autorelease];
	// have to initialize the RMMapContents object explicitly if we want it to use a particular tilesource
	[[[RMMapContents alloc] initWithView:mapView 
							  tilesource:myTilesource] autorelease];
    

    /* -- Uncomment to constrain view
    [mapView setConstraintsSW:((CLLocationCoordinate2D){-33.942221,150.996094}) 
                           NE:((CLLocationCoordinate2D){-33.771157,151.32019})]; */
    

//    CLLocation *location = [[CLLocation alloc] init];
    

    [self updateInfo];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    [[mapView contents] moveToLatLong:coordinate];
    
    [self updateInfo];

}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
*/


- (void)didReceiveMemoryWarning {
	RMLog(@"didReceiveMemoryWarning %@", self);
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateInfo];
}

- (void)dealloc {
	LogMethod();
    self.infoTextView = nil; 
    self.mapView = nil; 
    [super dealloc];
}

- (void)updateInfo {
	RMMapContents *contents = self.mapView.contents;
    CLLocationCoordinate2D mapCenter = [contents mapCenter];
    
	double truescaleDenominator = [contents scaleDenominator];
    double routemeMetersPerPixel = [contents metersPerPixel]; 
    [infoTextView setText:[NSString stringWithFormat:@"Latitude : %f\nLongitude : %f\nZoom: %.2f Meter per pixel : %.1f\nTrue scale : 1:%.0f\n%@\n%@", 
                           mapCenter.latitude, 
                           mapCenter.longitude, 
                           contents.zoom, 
                           routemeMetersPerPixel,
                           truescaleDenominator,
						   [[contents tileSource] shortName],
						   [[contents tileSource] shortAttribution]
						   ]];
}

/**
 Add a map to the list
 */
- (void)addMap {
    
	NSLog(@"add map to list");
    
	/*
	 Create a new instance of the Map entity.
	 */
	Map *newMap = (Map *)[NSEntityDescription insertNewObjectForEntityForName:@"Map" inManagedObjectContext:managedObjectContext];
	
    [newMap setTitle:@"Test map title"];
    
	// If it's not possible to get a location, then start with it blank.
	CLLocation *location = [locationManager location];
	if (!location) {
        //		return;
        [newMap setCenterLat:nil];
        [newMap setCenterLong:nil];
	} else {
        
        // Configure the new event with information from the location.
        CLLocationCoordinate2D coordinate = [location coordinate];
        [newMap setCenterLat:[NSNumber numberWithDouble:coordinate.latitude]];
        [newMap setCenterLong:[NSNumber numberWithDouble:coordinate.longitude]];
    }
    
	// Should be the location's timestamp, but this will be constant for simulator.
	// [event setCreationDate:[location timestamp]];
        
	// Commit the change.
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
	}
	
	/*
	 Since this is a new event, and events are displayed with most recent events at the top of the list,
	 add the new event to the beginning of the events array; then redisplay the table view.
	 */
    NSLog(@"added");
    
}


#pragma mark -
#pragma mark Delegate methods

- (void) afterMapMove: (RMMapView*) map {
    [self updateInfo];
}

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
    [self updateInfo];
}


@end
