//
//  GSPStop.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 4/19/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

@class GSPLineStop;

@interface GSPStop : NSManagedObject

@property(nonatomic, strong) NSNumber *active;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSNumber *code;
@property(nonatomic, strong) NSNumber *altitude;
@property(nonatomic, strong) NSNumber *latitude;
@property(nonatomic, strong) NSNumber *longitude;
@property(nonatomic, strong) NSSet *lines;

@end

@interface GSPStop (CoreDataGeneratedAccessors)

- (void)addLinesObject:(GSPLineStop *)value;

- (void)removeLinesObject:(GSPLineStop *)value;

- (void)addLines:(NSSet *)values;

- (void)removeLines:(NSSet *)values;

@end
