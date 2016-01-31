//
//  DetailMapViewController.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/26/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailTableViewController.h"

@class MKMapView;

@interface DetailMapViewController : UIViewController

@property(nonatomic, strong) id object;
@property(nonatomic, assign) DisplayMode displayMode;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)updateMapViewForScrollOffset:(CGFloat)offset;

@end
