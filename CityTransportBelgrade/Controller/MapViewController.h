//
//  MapViewController.h
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 4/8/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "SearchViewController.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
