//
//  LocationAnnotation.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 4/21/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

#import <CoreLocation/CLLocation.h>
#import "AnnotationType.h"
#import <MapKit/MapKit.h>
#import "CCHMapClusterAnnotation.h"

@interface LocationAnnotation : CCHMapClusterAnnotation

- (instancetype)initWithName:(NSString *)name
                     address:(NSString *)address
                  coordinate:(CLLocationCoordinate2D)coordinate;

@end
