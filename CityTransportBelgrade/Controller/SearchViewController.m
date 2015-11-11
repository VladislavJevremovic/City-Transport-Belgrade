//
//  SearchViewController.m
//  CityTransportBelgrade
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

@interface SearchViewController () <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    UITableView *currentTableView;

    DisplayMode displayMode;
    int tapToSelectCount;

    NSArray *fetchedObjects;
}

@property(nonatomic, strong) NSFetchRequest *fetchRequestLines;
@property(nonatomic, strong) NSFetchRequest *fetchRequestStops;

@property(nonatomic, strong) NSFetchRequest *searchFetchRequestLines;
@property(nonatomic, strong) NSFetchRequest *searchFetchRequestStops;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    displayMode = self.initialMode;
    [self adjustInterfaceBasedOnSearchMode];

    currentTableView = self.tableView;

    [self performFetch];
}

- (void)dealloc {
    self.fetchRequestLines = nil;
    self.fetchRequestStops = nil;
    
    self.searchFetchRequestLines = nil;
    self.searchFetchRequestStops = nil;
    
    // fetch
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // prevent crash upon return
    self.searchDisplayController.delegate = nil;
    self.searchDisplayController.searchResultsDelegate = nil;
    self.searchDisplayController.searchResultsDataSource = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    tapToSelectCount = 0;
}

#pragma mark - Private Methods

- (void)adjustInterfaceBasedOnSearchMode {
    if (displayMode == DisplayMode_Stops) {
        self.title = NSLocalizedString(@"tbStopsTitle", nil);
        self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"searchStopsPlaceholderText", nil);
    }
    else if (displayMode == DisplayMode_Lines) {
        self.title = NSLocalizedString(@"tbLinesTitle", nil);
        self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"searchLinesPlaceholderText", nil);
    }

    self.searchDisplayController.searchBar.keyboardType = UIKeyboardTypeNumberPad;
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
    }
    else if (displayMode == DisplayMode_Stops) {
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
            [cell setBackgroundColor:kCustomColorLightGray];
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
    }
    else if (displayMode == DisplayMode_Lines) {
        GSPLine *line = (GSPLine *) fetchedObjects[(NSUInteger) indexPath.row];
        if (![line.active boolValue]) {
            [cell setBackgroundColor:kCustomColorLightGray];
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentTableView = tableView;

    if (tapToSelectCount < 1) {
        if (displayMode == DisplayMode_Lines) {
            GSPLine *selectedLine = (GSPLine *) fetchedObjects[(NSUInteger) indexPath.row];

            DetailViewController *detailViewController = [[DetailViewController alloc] init];
            detailViewController.displayMode = DisplayMode_Lines;
            detailViewController.managedObjectContext = self.managedObjectContext;
            detailViewController.object = selectedLine;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        else {
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

- (NSFetchRequest *)fetchRequestForTableView:(UITableView *)tableView {
    if (!tableView) {
        return nil;
    }

    NSFetchRequest *fetchRequest = nil;

    if (displayMode == DisplayMode_Lines) {
        fetchRequest = (tableView == self.tableView ? self.fetchRequestLines : self.searchFetchRequestLines);
    }
    else if (displayMode == DisplayMode_Stops) {
        fetchRequest = (tableView == self.tableView ? self.fetchRequestStops : self.searchFetchRequestStops);
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
    if (searchString.length) {
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
    if (searchString.length) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"code beginsWith[cd] %@", searchString]];
    }
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[predicates copy]];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    return fetchRequest;
}

- (NSFetchRequest *)fetchRequestLines {
    if (_fetchRequestLines != nil) {
        return _fetchRequestLines;
    }
    _fetchRequestLines = [self newFetchRequestWithLineSearch:nil];

    return _fetchRequestLines;
}

- (NSFetchRequest *)fetchRequestStops {
    if (_fetchRequestStops != nil) {
        return _fetchRequestStops;
    }
    _fetchRequestStops = [self newFetchRequestWithStopSearch:nil];

    return _fetchRequestStops;
}

- (NSFetchRequest *)searchFetchRequestLines {
    if (_searchFetchRequestLines != nil) {
        return _searchFetchRequestLines;
    }
    _searchFetchRequestLines = [self newFetchRequestWithLineSearch:self.searchDisplayController.searchBar.text];

    return _searchFetchRequestLines;
}

- (NSFetchRequest *)searchFetchRequestStops {
    if (_searchFetchRequestStops != nil) {
        return _searchFetchRequestStops;
    }
    _searchFetchRequestStops = [self newFetchRequestWithStopSearch:self.searchDisplayController.searchBar.text];

    return _searchFetchRequestStops;
}

- (void)performFetch {
    NSFetchRequest *fetchRequest = [self fetchRequestForTableView:currentTableView];
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

#pragma mark - UISearchDisplayDelegate methods

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    [tableView registerClass:[SubtitleCell class] forCellReuseIdentifier:CellIdentifier];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return [self shouldReloadTableForSearchString:searchString];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString *searchString = controller.searchBar.text;
    return [self shouldReloadTableForSearchString:searchString];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView; {
    currentTableView = self.tableView;
    [self performFetch];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    currentTableView = self.tableView;
    [self performFetch];
}

- (BOOL)shouldReloadTableForSearchString:(NSString *)searchString {
    currentTableView = self.searchDisplayController.searchResultsTableView;

    if (displayMode == DisplayMode_Lines) {
        NSPredicate *predicate = [searchString length] > 0 ? [NSPredicate predicateWithFormat:@"name beginsWith[cd] %@ AND active = %@", searchString, @YES] : [NSPredicate predicateWithFormat:@"active = %@", @YES];
        [self.searchFetchRequestLines setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"direction" ascending:YES selector:@selector(localizedStandardCompare:)]]];
        [self.searchFetchRequestLines setPredicate:predicate];
    }
    else {
        NSPredicate *predicate = [searchString length] > 0 ? [NSPredicate predicateWithFormat:@"code beginsWith[cd] %@ AND active = %@", searchString, @YES] : [NSPredicate predicateWithFormat:@"active = %@", @YES];
        [self.searchFetchRequestStops setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES selector:@selector(localizedStandardCompare:)]]];
        [self.searchFetchRequestStops setPredicate:predicate];
    }

    [self performFetch];

    return YES;
}

@end
