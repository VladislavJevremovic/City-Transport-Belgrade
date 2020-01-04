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

@interface LocationAnnotation : MKPointAnnotation

- (instancetype)initWithName:(NSString *)name
                     address:(NSString *)address
                  coordinate:(CLLocationCoordinate2D)coordinate;

@end
