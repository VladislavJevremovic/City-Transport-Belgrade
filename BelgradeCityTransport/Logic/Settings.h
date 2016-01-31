//
//  Settings.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 1/27/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property(nonatomic, strong) NSString *favoriteStops;
@property(nonatomic, strong) NSNumber *currentDatabaseVersionDeployed;
@property(nonatomic, strong) NSNumber *selectedMapStyle;

+ (Settings *)sharedInstance;

- (BOOL)load;

- (BOOL)save;

- (NSString *)applicationNameString;

- (NSString *)versionString;

@end
