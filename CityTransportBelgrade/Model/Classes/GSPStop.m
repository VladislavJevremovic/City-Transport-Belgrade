//
//  GSPStop.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 4/19/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

#import "GSPStop.h"

@implementation GSPStop

@dynamic active;
@dynamic name;
@dynamic code;
@dynamic altitude;
@dynamic latitude;
@dynamic longitude;
@dynamic lines;

- (NSString *)description {
    return [NSString stringWithFormat:@"(%05d) %@", self.code.intValue, self.name];
}

@end
