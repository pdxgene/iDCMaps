#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Map : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * Provider;
@property (nonatomic, retain) NSNumber * CenterLat;
@property (nonatomic, retain) NSNumber * CenterLong;
@property (nonatomic, retain) NSDecimalNumber * latDelta;
@property (nonatomic, retain) NSDecimalNumber * longDelta;
@property (nonatomic, retain) NSNumber * Size;
@property (nonatomic, retain) NSManagedObject * MapTile;

@end
