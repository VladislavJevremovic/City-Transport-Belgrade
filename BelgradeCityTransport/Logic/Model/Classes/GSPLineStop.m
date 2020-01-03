//
//  GSPLineStop.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 4/19/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

#import "GSPLineStop.h"
#import "GSPLine.h"
#import "GSPStop.h"

@implementation GSPLineStop

@dynamic order;
@dynamic line;
@dynamic stop;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@), %@", self.line.name, self.line.direction, self.stop.code];
}

@end
