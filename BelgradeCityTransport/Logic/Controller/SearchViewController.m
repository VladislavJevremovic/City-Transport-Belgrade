//
//  SearchViewController.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 2/1/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "GSPLine.h"
#import "GSPStop.h"
#import "SubtitleCell.h"
#import "AnnotationType.h"
#import "DrawingHelper.h"
#import "DetailViewController.h"

#define CellIdentifier @"SelectionCell"

@interface SearchViewController () <NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate> {
    DisplayMode displayMode;
    int tapToSelectCount;
    NSArray *fetchedObjects;
}

@property(nonatomic, strong) NSFetchRequest *searchFetchRequestLines;
@property(nonatomic, strong) NSFetchRequest *searchFetchRequestStops;

@property(nonatomic, strong) UISearchController *searchController;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = false;
    self.searchController.searchBar.placeholder = nil;
    self.searchController.searchBar.backgroundColor = UIColor.whiteColor;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = true;

//    self.extendedLayoutIncludesOpaqueBars = YES;

    displayMode = self.initialMode;
    [self adjustInterfaceBasedOnSearchMode];

    [self performFetch];
}

- (void)dealloc {
    self.searchFetchRequestLines = nil;
    self.searchFetchRequestStops = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.searchController.searchResultsUpdater = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    tapToSelectCount = 0;
}

#pragma mark - Private Methods

- (BOOL)isSearchBarEmpty {
    return self.searchController.searchBar.text.length == 0;
}

- (BOOL)isFiltering {
    return self.searchController.isActive && !self.isSearchBarEmpty;
}

- (void)adjustInterfaceBasedOnSearchMode {
    if (displayMode == DisplayMode_Stops) {
        self.title = NSLocalizedString(@"tbStopsTitle", nil);
        self.searchController.searchBar.placeholder = NSLocalizedString(@"searchStopsPlaceholderText", nil);
    }
    else if (displayMode == DisplayMode_Lines) {
        self.title = NSLocalizedString(@"tbLinesTitle", nil);
        self.searchController.searchBar.placeholder = NSLocalizedString(@"searchLinesPlaceholderText", nil);
    }

    self.searchController.searchBar.keyboardType = UIKeyboardTypeNumberPad;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger) fetchedObjects.count;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (displayMode == DisplayMode_Lines) {
        GSPLine *line = (GSPLine *) fetchedObjects[(NSUInteger) indexPath.row];

        cell.textLabel.text = line.descriptionAtoB;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.text = line.direction;
        cell.tag = line.name.integerValue;
        cell.imageView.image = [[DrawingHelper sharedInstance] imageForListWithText:line.name annotationType:AnnotationType_Bus + (uint) line.type.intValue];
    } else if (displayMode == DisplayMode_Stops) {
        GSPStop *stop = (GSPStop *) fetchedObjects[(NSUInteger) indexPath.row];

        cell.textLabel.text = stop.name;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.detailTextLabel.text = @"";
        cell.tag = stop.code.integerValue;
        cell.imageView.image = [[DrawingHelper sharedInstance] imageForListWithText:stop.code.stringValue annotationType:AnnotationType_Stop];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (displayMode == DisplayMode_Stops) {
        GSPStop *stop = (GSPStop *) fetchedObjects[(NSUInteger) indexPath.row];
        if (![stop.active boolValue]) {
            [cell setBackgroundColor:UIColor.lightGrayColor];
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
    }
    else if (displayMode == DisplayMode_Lines) {
        GSPLine *line = (GSPLine *) fetchedObjects[(NSUInteger) indexPath.row];
        if (![line.active boolValue]) {
            [cell setBackgroundColor:UIColor.lightGrayColor];
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tapToSelectCount < 1) {
        if (displayMode == DisplayMode_Lines) {
            GSPLine *selectedLine = (GSPLine *) fetchedObjects[(NSUInteger) indexPath.row];

            DetailViewController *detailViewController = [[DetailViewController alloc] init];
            detailViewController.displayMode = DisplayMode_Lines;
            detailViewController.managedObjectContext = self.managedObjectContext;
            detailViewController.object = selectedLine;
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else {
            GSPStop *selectedStop = (GSPStop *) fetchedObjects[(NSUInteger) indexPath.row];

            DetailViewController *detailViewController = [[DetailViewController alloc] init];
            detailViewController.displayMode = DisplayMode_Stops;
            detailViewController.managedObjectContext = self.managedObjectContext;
            detailViewController.object = selectedStop;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = nil;
    if (displayMode == DisplayMode_Lines) {
        fetchRequest = self.searchFetchRequestLines;
    } else if (displayMode == DisplayMode_Stops) {
        fetchRequest = self.searchFetchRequestStops;
    }

    return fetchRequest;
}

- (NSFetchRequest *)newFetchRequestWithLineSearch:(NSString *)searchString {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GSPLine" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:YES];
    [fetchRequest setFetchBatchSize:20];

    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"active = %@", @YES]];
    if (searchString.length > 0) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"name beginsWith[cd] %@", searchString]];
    }
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[predicates copy]];

    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"direction" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2];
    [fetchRequest setSortDescriptors:sortDescriptors];

    return fetchRequest;
}

- (NSFetchRequest *)newFetchRequestWithStopSearch:(NSString *)searchString {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GSPStop" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:YES];
    [fetchRequest setFetchBatchSize:20];

    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"active = %@", @YES]];
    if (searchString.length > 0) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"code beginsWith[cd] %@", searchString]];
    }
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[predicates copy]];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    return fetchRequest;
}

- (NSFetchRequest *)searchFetchRequestLines {
    return [self newFetchRequestWithLineSearch:self.searchController.searchBar.text];
}

- (NSFetchRequest *)searchFetchRequestStops {
    return [self newFetchRequestWithStopSearch:self.searchController.searchBar.text];
}

- (void)performFetch {
    NSFetchRequest *fetchRequest = [self fetchRequest];
    if (!fetchRequest) {
        return;
    }

    NSError *error;
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self performFetch];
}

@end
