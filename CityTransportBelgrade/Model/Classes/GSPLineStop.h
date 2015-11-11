//
//  GSPLineStop.h
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 4/19/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

@class GSPLine;
@class GSPStop;

@interface GSPLineStop : NSManagedObject

@property(nonatomic, strong) NSNumber *order;
@property(nonatomic, strong) GSPLine *line;
@property(nonatomic, strong) GSPStop *stop;

@end
