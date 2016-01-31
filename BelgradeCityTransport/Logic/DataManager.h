//
//  DataManager.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 11/1/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@class FavoriteStop;
@class GSPStop;
@class GSPLine;
@class GSPLineStop;
@class Settings;

@interface DataManager : NSObject

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property(nonatomic, strong) NSArray *favoriteStops;
@property(nonatomic, strong) NSArray *favoriteStopsCodes;

+ (DataManager *)sharedInstance;

- (void)fetchFavoriteStops;

- (FavoriteStop *)favoriteStopForCode:(NSString *)stopCode;

- (BOOL)isFavoriteStop:(NSString *)stopCode;

- (BOOL)addFavoriteStop:(NSString *)stopCode;

- (void)removeFavoriteStop:(NSString *)stopCode;

- (NSArray *)fetchLines;

- (NSArray *)fetchStops;

- (GSPLine *)lineForName:(NSString *)name withDirection:(NSString *)direction;

- (NSArray *)fetchStopsWithin:(CLLocationDegrees)maxLongitude minLongitude:(CLLocationDegrees)minLongitude maxLatitude:(CLLocationDegrees)maxLatitude minLatitude:(CLLocationDegrees)minLatitude;

- (GSPStop *)fetchStopForCode:(NSString *)code;

- (GSPLineStop *)lineStopByName:(NSString *)name andCode:(NSString *)code;

- (NSArray *)fetchLinesForStopCode:(NSString *)stopCode;

- (NSNumber *)fetchOrderForStopCode:(NSString *)stopCode inLine:(GSPLine *)line;

- (GSPLineStop *)fetchNextLineStopForOrder:(NSNumber *)order inLine:(GSPLine *)line;

@end
