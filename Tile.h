
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Map;

@interface Tile : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * imgData;
@property (nonatomic, retain) Map * MapTile;

@end
