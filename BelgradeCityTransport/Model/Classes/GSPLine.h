//
//  GSPLine.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 4/19/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

@class GSPLineStop;

@interface GSPLine : NSManagedObject

@property(nonatomic, strong) NSNumber *active;
@property(nonatomic, copy) NSString *descriptionAtoB;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSNumber *type;
@property(nonatomic, copy) NSString *direction;
@property(nonatomic, strong) NSSet *stops;
@property(nonatomic, copy) NSString *map;

@end

@interface GSPLine (CoreDataGeneratedAccessors)

- (void)addStopsObject:(GSPLineStop *)value;

- (void)removeStopsObject:(GSPLineStop *)value;

- (void)addStops:(NSSet *)values;

- (void)removeStops:(NSSet *)values;

@end
