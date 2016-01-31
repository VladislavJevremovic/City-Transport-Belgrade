//
//  MKMapView+Zoom.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/26/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "MKMapView+Zoom.h"
#import "LocationAnnotation.h"

#define MINIMUM_MAP_ZOOM 20000

@implementation MKMapView (Zoom)

- (void)zoomToFitAnnotations:(NSArray *)annotations {
    NSArray *pins = annotations;
    if ([pins count] < 1) {
        return;
    }

    // Set the default max and minimm coordinates, the top left of the world, and the bottom right of the world
    CLLocationCoordinate2D topLeftCoord = CLLocationCoordinate2DMake(-90, 180);
    CLLocationCoordinate2D bottomRightCoord = CLLocationCoordinate2DMake(90, -180);

    // for each annotation, decrease the top left longitude, increase the latitude
    // for each annotation, increase the bot right longitude, decrease the latitude
    for (NSUInteger i = 0; i < pins.count; i++) {
        LocationAnnotation *pin = (LocationAnnotation *) pins[i];
        if ([pins[i] isKindOfClass:[MKUserLocation class]]) {
            continue;
        }

        double_t pinLongitude = pin.coordinate.longitude;
        double_t pinLatitude = pin.coordinate.latitude;

        topLeftCoord.longitude = fmin(topLeftCoord.longitude, pinLongitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, pinLatitude);

        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, pinLongitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, pinLatitude);
    }

    // Now we turn the Core Location Coordinates (which are real world GPS coordinates) into MKMapView points (which are points on a View)
    // An MKMapView is basically one view that is the width and height of the whole world layed flat. 
    // What we're going to do here, is take our two GPS points and turn them into a rectangle that is a portion of the whole world that we want the map to show.

    // Convert the two points to MKMapPoints
    MKMapPoint topLeftPoint = MKMapPointForCoordinate(topLeftCoord);
    MKMapPoint bottomRightPoint = MKMapPointForCoordinate(bottomRightCoord);

    // Of the two points, calculate the center point between them, this will be where our map is centered.
    MKMapPoint centrePoint = MKMapPointMake((topLeftPoint.x + bottomRightPoint.x) / 2, (topLeftPoint.y + bottomRightPoint.y) / 2);

    // Work out the widths between the top left and bottom right points
    double spanWidth = fabs(topLeftPoint.x - bottomRightPoint.x);
    double spanHeight = fabs(topLeftPoint.y - bottomRightPoint.y);

    // Apply the MAX macro to make sure we have at least a minimum zoom level, don't want to zoom too far in.
    double mapWidth = MAX(spanWidth, MINIMUM_MAP_ZOOM);
    double mapHeight = MAX(spanHeight, MINIMUM_MAP_ZOOM);

    // From our center, and widths, create a rectangle to display.
    MKMapRect mapRect;
    mapRect.origin.x = centrePoint.x - mapWidth / 2;
    mapRect.origin.y = centrePoint.y - mapHeight / 2;
    mapRect.size = MKMapSizeMake(mapWidth, mapHeight);

    // You can then futher pad the map, and it will return a rect that fits based on it's bounds
    CGFloat padding = 40.0;
    MKMapRect adjustedRect = [self mapRectThatFits:mapRect edgePadding:UIEdgeInsetsMake(padding, padding, padding, padding)];

    [self setVisibleMapRect:adjustedRect animated:YES];
}

@end
