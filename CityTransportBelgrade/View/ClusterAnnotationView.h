//
//  ClusterAnnotationView.h
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 4/21/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ClusterAnnotationView : MKAnnotationView

@property(nonatomic) NSUInteger count;
@property(nonatomic, getter = isBlue) BOOL blue;
@property(nonatomic, getter = isUniqueLocation) BOOL uniqueLocation;

@end
