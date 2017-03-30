//
//  AppDelegate.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/25/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "FavoriteStopsViewController.h"
#import "FavoriteStop.h"
#import "GSPStop.h"
#import "DataStore.h"
#import "DataManager.h"

@interface AppDelegate () <UIApplicationDelegate, UITabBarControllerDelegate>

@end

@implementation AppDelegate

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Settings *_settings = [Settings sharedInstance];
    [_settings load];

    DataStore *_dataStore = [DataStore sharedInstance];

    [_dataStore prepareDataBase];

    DataManager *_dataManager = [DataManager sharedInstance];
    _dataManager.managedObjectContext = _dataStore.managedObjectContext;

    [_dataManager fetchFavoriteStops];
    // fix for missing stops
    NSMutableArray *missingStopsCodes = [NSMutableArray array];
    for (FavoriteStop *favoriteStop in _dataManager.favoriteStops) {
        GSPStop *stop = [_dataManager fetchStopForCode:favoriteStop.code];
        if (!stop) {
            [missingStopsCodes addObject:favoriteStop.code];
        }
    }
    for (NSString *stopCode in missingStopsCodes) {
        [_dataManager removeFavoriteStop:stopCode];
    }
    // end fix

    MapViewController *mvc = [self mapViewController];
    mvc.managedObjectContext = _dataStore.managedObjectContext;
    mvc.parentViewController.tabBarItem.title = NSLocalizedString(@"tbMapTitle", nil);
    mvc.parentViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"MapActive"];

    FavoriteStopsViewController *fsvc = [self favoriteStopsViewController];
    fsvc.parentViewController.tabBarItem.title = NSLocalizedString(@"tbFavoritesTitle", nil);
    fsvc.parentViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"StarActive"];

    SearchViewController *svcs = [self searchViewControllerStops];
    svcs.managedObjectContext = _dataStore.managedObjectContext;
    svcs.initialMode = DisplayMode_Stops;
    svcs.parentViewController.tabBarItem.title = NSLocalizedString(@"tbStopsTitle", nil);
    svcs.parentViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"BusinessmanActive"];

    SearchViewController *svcl = [self searchViewControllerLines];
    svcl.managedObjectContext = _dataStore.managedObjectContext;
    svcl.initialMode = DisplayMode_Lines;
    svcl.parentViewController.tabBarItem.title = NSLocalizedString(@"tbLinesTitle", nil);
    svcl.parentViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"NodeConnectActive"];

    return YES;
}

- (MapViewController *)mapViewController {
    UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
    UIViewController *vc = tbc.viewControllers[0];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *) vc;
        if ([nc.topViewController isKindOfClass:[MapViewController class]]) {
            return (MapViewController *) nc.topViewController;
        }
        return nil;
    }
    else {
        return nil;
    }
}

- (FavoriteStopsViewController *)favoriteStopsViewController {
    UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
    UIViewController *vc = tbc.viewControllers[1];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *) vc;
        if ([nc.topViewController isKindOfClass:[FavoriteStopsViewController class]]) {
            return (FavoriteStopsViewController *) nc.topViewController;
        }
        return nil;
    }
    else {
        return nil;
    }
}

- (SearchViewController *)searchViewControllerStops {
    UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
    UIViewController *vc = tbc.viewControllers[2];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *) vc;
        if ([nc.topViewController isKindOfClass:[SearchViewController class]]) {
            return (SearchViewController *) nc.topViewController;
        }
        return nil;
    }
    else {
        return nil;
    }
}

- (SearchViewController *)searchViewControllerLines {
    UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
    UIViewController *vc = tbc.viewControllers[3];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *) vc;
        if ([nc.topViewController isKindOfClass:[SearchViewController class]]) {
            return (SearchViewController *) nc.topViewController;
        }
        return nil;
    }
    else {
        return nil;
    }
}

@end

