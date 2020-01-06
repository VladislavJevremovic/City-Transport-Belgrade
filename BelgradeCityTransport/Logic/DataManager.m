//
//  DataManager.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 11/1/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "Settings.h"
#import "DataManager.h"
#import "FavoriteStop.h"
#import "GSPStop.h"
#import "GSPLine.h"
#import "GSPLineStop.h"

#define TICK NSDate *startTime = [NSDate date];
#define TOCK NSLog(@"Elapsed Time: %f", -[startTime timeIntervalSinceNow]);

static const NSInteger kMaximumNumberOfFavoriteStops = 20;

@implementation DataManager

+ (DataManager *)sharedInstance {
    static DataManager *_default = nil;
    if (_default != nil) {
        return _default;
    }

    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        _default = [[DataManager alloc] init];
    });
    return _default;
}

- (void)fetchFavoriteStops {
    NSString *tFavoriteStops = Settings.sharedInstance.favoriteStops;
    if (!tFavoriteStops || tFavoriteStops.length < 1) {
        _favoriteStopsCodes = @[];
    } else {
        _favoriteStopsCodes = [tFavoriteStops componentsSeparatedByString:@","];
    }

    _favoriteStops = @[];
    for (NSString *code in _favoriteStopsCodes) {
        FavoriteStop *favoriteStop = [[FavoriteStop alloc] init];
        favoriteStop.code = code;
        _favoriteStops = [[_favoriteStops arrayByAddingObject:favoriteStop] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]]];
    }
}

- (FavoriteStop *)favoriteStopForCode:(NSString *)stopCode {
    NSArray *array = [_favoriteStops filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"code = %@", stopCode]];
    return [array firstObject];
}

- (BOOL)isFavoriteStop:(NSString *)stopCode {
    return [_favoriteStopsCodes containsObject:stopCode];
}

- (BOOL)addFavoriteStop:(NSString *)stopCode {
    if (![self isFavoriteStop:stopCode]) {
        if (_favoriteStops.count >= kMaximumNumberOfFavoriteStops) {
            return NO;
        }
        else {
            FavoriteStop *favoriteStop = [[FavoriteStop alloc] init];
            favoriteStop.code = stopCode;
            _favoriteStops = [[_favoriteStops arrayByAddingObject:favoriteStop] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]]];
            _favoriteStopsCodes = [_favoriteStops valueForKey:@"code"];
            Settings.sharedInstance.favoriteStops = [_favoriteStopsCodes componentsJoinedByString:@","];
            [Settings.sharedInstance save];

            return YES;
        }
    }

    return YES;
}

- (void)removeFavoriteStop:(NSString *)stopCode {
    FavoriteStop *favoriteStop = [self favoriteStopForCode:stopCode];
    if (favoriteStop) {
        NSMutableArray *ma = _favoriteStops.mutableCopy;
        [ma removeObject:favoriteStop];
        _favoriteStops = ma.copy;
        _favoriteStopsCodes = [_favoriteStops valueForKey:@"code"];
        Settings.sharedInstance.favoriteStops = [_favoriteStopsCodes componentsJoinedByString:@","];
        [Settings.sharedInstance save];
    }
}

- (NSArray *)fetchLines {
    TICK

    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPLine"
                                                         inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];
    [req setReturnsObjectsAsFaults:YES];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"active = %@", @YES];
    [req setPredicate:predicate];

    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [req setSortDescriptors:sortDescriptors];

    NSArray *lines = [self.managedObjectContext executeFetchRequest:req
                                                              error:nil];

    TOCK

    return lines;
}

- (NSArray *)fetchStops {
    TICK

    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPStop"
                                                         inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];
    [req setReturnsObjectsAsFaults:YES];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"active = %@", @YES];
    [req setPredicate:predicate];

    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [req setSortDescriptors:sortDescriptors];

    NSArray *stops = [self.managedObjectContext executeFetchRequest:req
                                                              error:nil];

    TOCK

    return stops;
}

- (NSArray *)fetchLinesForStopCode:(NSString *)stopCode {
    TICK

    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPLine"
                                                         inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];
    [req setReturnsObjectsAsFaults:NO];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY stops.stop.code = %@", stopCode];
    [req setPredicate:predicate];

    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]];
    [req setSortDescriptors:sortDescriptors];

    NSArray *lines = [self.managedObjectContext executeFetchRequest:req
                                                              error:nil];

    TOCK

    return lines;
}

- (NSNumber *)fetchOrderForStopCode:(NSString *)stopCode inLine:(GSPLine *)line {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPLineStop"
                                                         inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];
    [req setReturnsObjectsAsFaults:NO];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"line = %@ AND stop.code = %@", line, stopCode];
    [req setPredicate:predicate];

    NSArray *lines = [self.managedObjectContext executeFetchRequest:req
                                                              error:nil];
    GSPLineStop *lineStop = (GSPLineStop *) [lines firstObject];
    return lineStop.order;
}

- (GSPLineStop *)fetchNextLineStopForOrder:(NSNumber *)order inLine:(GSPLine *)line {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPLineStop"
                                                         inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];
    [req setReturnsObjectsAsFaults:NO];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"line = %@ AND order = %@", line, @(order.intValue + 1)];
    [req setPredicate:predicate];

    NSArray *lines = [self.managedObjectContext executeFetchRequest:req
                                                              error:nil];
    GSPLineStop *lineStop = (GSPLineStop *) [lines firstObject];
    return lineStop;
}

- (GSPLine *)lineForName:(NSString *)name withDirection:(NSString *)direction {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPLine"
                                                         inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];
    [req setReturnsObjectsAsFaults:YES];

    NSPredicate *predicate = [direction isEqualToString:@""] ? [NSPredicate predicateWithFormat:@"name =[cd] %@", name] : [NSPredicate predicateWithFormat:@"name =[cd] %@ AND direction =[cd] %@", name, direction];
    [req setPredicate:predicate];

    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [req setSortDescriptors:sortDescriptors];

    NSArray *lines = [self.managedObjectContext executeFetchRequest:req error:nil];
    GSPLine *line = (GSPLine *) [lines firstObject];
    return line;
}

- (NSArray *)fetchStopsWithin:(CLLocationDegrees)maxLongitude minLongitude:(CLLocationDegrees)minLongitude maxLatitude:(CLLocationDegrees)maxLatitude minLatitude:(CLLocationDegrees)minLatitude {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPStop" inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];
    [req setReturnsObjectsAsFaults:YES];

    NSPredicate *p = [NSPredicate predicateWithFormat:@"%f < latitude AND latitude < %f AND %f < longitude AND longitude < %f AND active = %@", minLatitude, maxLatitude, minLongitude, maxLongitude, @YES];
    [req setPredicate:p];

    return [self.managedObjectContext executeFetchRequest:req error:nil];
}

- (GSPStop *)fetchStopForCode:(NSString *)code {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPStop" inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];
    [req setFetchLimit:1];
    [req setReturnsObjectsAsFaults:YES];

    NSPredicate *p = [NSPredicate predicateWithFormat:@"code = %@ AND active = %@", code, @YES];
    [req setPredicate:p];

    NSArray *stops = [self.managedObjectContext executeFetchRequest:req error:nil];
    GSPStop *stop = (GSPStop *) [stops firstObject];
    return stop;
}

- (GSPLineStop *)lineStopByName:(NSString *)name andCode:(NSString *)code {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPLineStop" inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];

    NSPredicate *p = [NSPredicate predicateWithFormat:@"line.name =[cd] %@ AND stop.code =[cd] %@", name, code];
    [req setPredicate:p];

    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"stop.code" ascending:YES]];
    [req setSortDescriptors:sortDescriptors];

    NSArray *lineStops = [self.managedObjectContext executeFetchRequest:req error:nil];
    GSPLineStop *lineStop = (GSPLineStop *) [lineStops firstObject];
    return lineStop;
}

@end
