//
//  DetailViewController.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/27/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayMode.h"

@interface DetailViewController : UIViewController

@property(nonatomic, strong) id object;
@property(nonatomic, assign) DisplayMode displayMode;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
