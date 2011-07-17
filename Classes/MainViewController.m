//
//  MainViewController.m
//  SampleMap : Diagnostic map
//

#import "MainViewController.h"
#import "iDCMapsAppDelegate.h"

#import "MainView.h"

//#import "RMCloudMadeMapSource.h"
//#import "RMOpenCycleMapSource.h"
#import "RMOpenStreetMapSource.h"
#import "Map.h"
#import "Tile.h"


@implementation MainViewController

@synthesize mapView;
@synthesize infoTextView;
@synthesize managedObjectContext;
@synthesize saveButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (IBAction)saveMap{
    RMMapContents *contents = self.mapView.contents;
    CLLocationCoordinate2D mapCenter = [contents mapCenter];
    float lon = mapCenter.longitude;
    float lat = mapCenter.latitude;

    //create an instance of the Map object in Core Data:
    [self addMap];
    
    int z = contents.zoom;

    int solx = (int)(floor((lon + 180.0) / 360.0 * pow(2.0, z)));
    int soly = (int)(floor((1.0 - log( tan(lat * M_PI/180.0) + 1.0 / cos(lat * M_PI/180.0)) / M_PI) / 2.0 * pow(2.0, z)));
    
    NSLog(@"solx = %d", solx);
    NSLog(@"soly = %d", soly);
    NSLog(@"zoom = %d", z);

    //1. Save the tile covering this lat/lng:
    NSLog(@"this tile:");
    [self addTile:z atTileX:solx atTileY:soly];

    NSLog(@"Neighbor tiles:");
    //1. Save 8 "neighbor" tiles that surround the tile covering this lat/lng:
    [self addTile:z atTileX:solx+1 atTileY:soly+1];
    [self addTile:z atTileX:solx+1 atTileY:soly-1];
    [self addTile:z atTileX:solx atTileY:soly+1];
    [self addTile:z atTileX:solx+1 atTileY:soly];
    [self addTile:z atTileX:solx-1 atTileY:soly];
    [self addTile:z atTileX:solx atTileY:soly-1];
    [self addTile:z atTileX:solx-1 atTileY:soly+1];
    [self addTile:z atTileX:solx-1 atTileY:soly-1];    

    NSLog(@"zoom in one level:");
    //save the four tiles one level closer (zoom in)
    int zl = z+1;
    //2x,2y
    int solxl = 2*solx;
    int solyl = 2*soly;
    NSLog(@"url: http://c.tile.openstreetmaps.org/%d/%d/%d.png", zl, solxl, solyl);
    //2x+1, 2y
    //2x,2y+1
    //2x+1, 2y+1
    
    
    NSLog(@"zoom out one level:");
    //save four tiles one level further (zoom out)
    int zu = z-1;
    int solxu = solx/2;
    int solyu = soly/2;
    int solx1u = solx/2 + 1;
    int soly1u = soly/2 + 1;

    //x/2,y/2
    NSLog(@"url: http://c.tile.openstreetmaps.org/%d/%d/%d.png", zu, solxu, solyu);
    //x/2+1, y/2
    NSLog(@"url: http://c.tile.openstreetmaps.org/%d/%d/%d.png", zu, solx1u, solyu);
    //x/2,y/2+1
    NSLog(@"url: http://c.tile.openstreetmaps.org/%d/%d/%d.png", zu, solxu, soly1u);
    //x/2+1, 2y+1
    NSLog(@"url: http://c.tile.openstreetmaps.org/%d/%d/%d.png", zu, solx1u, soly1u);

    
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
    id myTilesource = [[RMOpenStreetMapSource alloc] init];
//	id myTilesource = [[[RMCloudMadeMapSource alloc] initWithAccessKey:@"0199bdee456e59ce950b0156029d6934" styleNumber:999] autorelease];
//    id myTilesource = [[[RMOpenCycleMapSource alloc] init] autorelease];
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

/**
 Add a map to the list
 */
- (void)addTile:(int)zoom atTileX:(int)x atTileY:(int)y {
    NSLog(@"add tile from data:");
    NSLog(@"zoom: %d", zoom);
    NSLog(@"x: %d", x);
    NSLog(@"y: %d", y);
    
    //fetch and save map tile from OSM tile server:
    NSString *urlString = [[[NSString alloc] initWithFormat:@"http://tile.openstreetmaps.org/%d/%d/%d.png", zoom, x, y] autorelease];
    NSLog(@"fetch and save: %@", urlString);

	/*
	 Create a new instance of the Tile entity.
	 */
	Tile *newTile = (Tile *)[NSEntityDescription insertNewObjectForEntityForName:@"Tile" inManagedObjectContext:managedObjectContext];
	    
    [newTile setX:[NSNumber numberWithInt:x]];
    [newTile setY:[NSNumber numberWithInt:y]];
    [newTile setZ:[NSNumber numberWithInt:zoom]];
    
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
