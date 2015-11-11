//
//  FavoriteStopsViewController.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 2/10/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "AppDelegate.h"
#import "DataStore.h"
#import "Settings.h"
#import "FavoriteStopsViewController.h"
#import "DataManager.h"
#import "DetailViewController.h"
#import "GSPStop.h"
#import "DrawingHelper.h"

@implementation FavoriteStopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"tbFavoritesTitle", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

#pragma mark - Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger) DataManager.sharedInstance.favoriteStops.count;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *code = ((NSUInteger) indexPath.row >= DataManager.sharedInstance.favoriteStopsCodes.count) ? nil : DataManager.sharedInstance.favoriteStopsCodes[(NSUInteger) indexPath.row];
    GSPStop *stop = [DataManager.sharedInstance fetchStopForCode:code];

    cell.textLabel.text = stop.name;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.text = @"";
    cell.imageView.image = [[DrawingHelper sharedInstance] imageForListWithText:stop.code.stringValue annotationType:AnnotationType_Stop];
    cell.tag = stop.code.integerValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FavoriteStopCell";

    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tvc = [tableView cellForRowAtIndexPath:indexPath];
    GSPStop *selectedStop = [DataManager.sharedInstance fetchStopForCode:[NSString stringWithFormat:@"%@", @(tvc.tag)]];

    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.displayMode = DisplayMode_Stops;
    detailViewController.managedObjectContext = DataStore.sharedInstance.managedObjectContext;
    detailViewController.object = selectedStop;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell *tvc = [tableView cellForRowAtIndexPath:indexPath];
        [DataManager.sharedInstance removeFavoriteStop:[NSString stringWithFormat:@"%@", @(tvc.tag)]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
