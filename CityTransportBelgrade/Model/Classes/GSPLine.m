//
//  GSPLine.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 4/19/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

#import "GSPLine.h"

@implementation GSPLine

@dynamic active;
@dynamic descriptionAtoB;
@dynamic name;
@dynamic type;
@dynamic direction;
@dynamic stops;
@dynamic map;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.direction];
}

@end
