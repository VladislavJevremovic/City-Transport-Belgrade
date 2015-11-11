//
//  DataStore.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 11/18/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "DataStore.h"
#import "Settings.h"

@interface DataStore ()

@property(nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property(nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation DataStore

@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

+ (DataStore *)sharedInstance {
    static DataStore *_default = nil;
    if (_default != nil) {
        return _default;
    }
    
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        _default = [[DataStore alloc] init];
    });
    return _default;
}

#pragma mark - Core Data Stack

- (void)saveContext {
    NSError *error = nil;
    if (__managedObjectContext != nil) {
        if ([__managedObjectContext hasChanges] && ![__managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"DataModel.sqlite"];

    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    pragmaOptions[@"journal_mode"] = @"DELETE";

    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES, NSSQLitePragmasOption : pragmaOptions};

    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return __persistentStoreCoordinator;
}

#pragma mark - Utility

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

- (NSURL *)applicationLibraryDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] firstObject];
}

- (BOOL)deployDatabaseToPath:(NSString *)filePath replacing:(BOOL)replacing {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL result = YES;

    NSString *defaultDB = [[NSBundle mainBundle] pathForResource:@"DataModel" ofType:@"sqlite"];
    NSError *error = nil;
    if (replacing) {
        if ([fileManager fileExistsAtPath:filePath]) {
            result = [fileManager removeItemAtPath:filePath error:&error];
        }

        NSString *filePathSHM = [NSString stringWithFormat:@"%@-shm", filePath];
        if ([fileManager fileExistsAtPath:filePathSHM]) {
            result &= [fileManager removeItemAtPath:filePathSHM error:&error];
        }

        NSString *filePathWAL = [NSString stringWithFormat:@"%@-wal", filePath];
        if ([fileManager fileExistsAtPath:filePathWAL]) {
            result &= [fileManager removeItemAtPath:filePathWAL error:&error];
        }
    }

    if (result) {
        if ([fileManager fileExistsAtPath:defaultDB]) {
            if (![[NSFileManager defaultManager] copyItemAtPath:defaultDB toPath:filePath error:&error]) {
                result = NO;
                NSLog(@"%@:%@ Error copying file %@", [self class], NSStringFromSelector(_cmd), error);
            }
            else {
                [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:filePath]];
            }
        }
        else {
            result = NO;
            NSLog(@"Error copying missing bundled database file!");
        }
    }

    return result;
}

- (void)prepareDataBase {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *libFolder = [[self applicationLibraryDirectory] relativePath];
    NSError *error;
    if (![fileManager fileExistsAtPath:libFolder]) {
        if (![fileManager createDirectoryAtPath:libFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }

    NSString *filePath = [libFolder stringByAppendingPathComponent:@"DataModel.sqlite"];
    if (![fileManager fileExistsAtPath:filePath]) {
        [self deployDatabaseToPath:filePath replacing:NO];
    }
    else {
        if (!Settings.sharedInstance.currentDatabaseVersionDeployed || !Settings.sharedInstance.currentDatabaseVersionDeployed.boolValue) {
            BOOL result = [self deployDatabaseToPath:filePath replacing:YES];
            if (result) {
                Settings.sharedInstance.currentDatabaseVersionDeployed = @YES;
                [Settings.sharedInstance save];
            }
        }
    }
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);

    NSError *error = nil;
    BOOL success = [URL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }

    return success;
}

@end
