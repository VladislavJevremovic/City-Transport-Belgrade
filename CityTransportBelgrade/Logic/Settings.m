//
//  Settings.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 1/27/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "Settings.h"

@implementation Settings

+ (Settings *)sharedInstance {
    static Settings *_default = nil;
    if (_default != nil) {
        return _default;
    }

    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        _default = [[Settings alloc] init];
        [_default load];
    });
    return _default;
}

- (NSString *)applicationNameString {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)versionString {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

#pragma mark - Settings.plist Code

- (BOOL)load {
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths firstObject];
    // get the path to our Data/plist file
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"Settings.plist"];

    // check to see if Settings.plist exists in documents
    BOOL exists = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        exists = NO;

        // if not in documents, get property list from main bundle
        plistPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    }

    // read property list into memory as an NSData object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    if (!exists) {
        [plistXML writeToFile:[documentsPath stringByAppendingPathComponent:@"Settings.plist"] atomically:YES];
    }

    NSError *error = nil;
    NSPropertyListFormat format;
    NSDictionary *temp = nil;

    // convert static property list into dictionary object
    temp = (NSDictionary *) [NSPropertyListSerialization propertyListWithData:plistXML
                                                                      options:NSPropertyListMutableContainersAndLeaves
                                                                       format:&format
                                                                        error:&error];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %@", error, @(format));
        return NO;
    }

    // assign values
    _favoriteStops = (NSString *) temp[@"favoriteStops"];
    _currentDatabaseVersionDeployed = (NSNumber *) temp[self.versionString];
    _selectedMapStyle = (NSNumber *) temp[@"selectedMapStyle"];

    return YES;
}

- (BOOL)save {
    // get paths from root directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths firstObject];
    // get the path to our Data/plist file
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"Settings.plist"];

    // fetch data
    if (!_favoriteStops) {
        _favoriteStops = @"";
    }
    if (!_currentDatabaseVersionDeployed) {
        _currentDatabaseVersionDeployed = @NO;
    }
    if (!_selectedMapStyle) {
        _selectedMapStyle = @0;
    }

    // create dictionary with values
    NSDictionary *plistDict = @{
            @"favoriteStops" : _favoriteStops,
            self.versionString : _currentDatabaseVersionDeployed,
            @"selectedMapStyle" : _selectedMapStyle
    };

    NSError *error = nil;
    NSData *plistData = nil;

    // create NSData from dictionary
    plistData = [NSPropertyListSerialization dataWithPropertyList:plistDict
                                                           format:NSPropertyListXMLFormat_v1_0
                                                          options:0
                                                            error:&error];
    // check is plistData exists
    if (plistData) {
        // write plistData to our Settings.plist file
        [plistData writeToFile:plistPath atomically:YES];

        return YES;
    }
    else {
        NSLog(@"Error in saveData: %@", error);

        return NO;
    }
}

@end
