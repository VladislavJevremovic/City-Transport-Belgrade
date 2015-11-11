//
//  SearchViewController.h
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 2/1/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayMode.h"
#import "Settings.h"

@interface SearchViewController : UITableViewController

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, assign) DisplayMode initialMode;

@end
