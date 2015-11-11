//
//  DataStore.h
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 11/18/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Settings;

@interface DataStore : NSObject

@property(nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

+ (DataStore *)sharedInstance;

- (void)prepareDataBase;

@end
