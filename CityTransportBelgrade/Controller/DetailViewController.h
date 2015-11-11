//
//  DetailViewController.h
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 10/27/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPullDownController.h"
#import "DisplayMode.h"

@interface DetailViewController : MBPullDownController

@property(nonatomic, strong) id object;
@property(nonatomic, assign) DisplayMode displayMode;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
