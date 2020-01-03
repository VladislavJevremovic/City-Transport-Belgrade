//
//  DetailTableViewController.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/26/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayMode.h"
#import "Settings.h"

@class DetailTableViewController;

@protocol DetailTableViewControllerDelegate <NSObject>

- (void)detailTableViewController:(DetailTableViewController *)viewController didChangeOffsetTo:(CGFloat)offset;

- (void)detailTableViewController:(DetailTableViewController *)viewController didSelectObject:(id)object;

@end

@interface DetailTableViewController : UITableViewController

@property(nonatomic, strong) id object;
@property(nonatomic, assign) DisplayMode displayMode;

@property(nonatomic, weak) id <DetailTableViewControllerDelegate> delegate;

@end
