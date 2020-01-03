//
//  MKMapView+Zoom.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/26/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Zoom)

- (void)zoomToFitAnnotations:(NSArray *)annotations;

@end
