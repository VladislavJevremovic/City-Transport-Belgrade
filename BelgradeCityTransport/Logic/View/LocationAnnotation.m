//
//  LocationAnnotation.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 4/21/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

#import "LocationAnnotation.h"

@implementation LocationAnnotation

- (instancetype)initWithName:(NSString *)name
                     address:(NSString *)address
                  coordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super initWithCoordinate:coordinate title:name subtitle:address]) {
        // ...
    }

    return self;
}

@end
