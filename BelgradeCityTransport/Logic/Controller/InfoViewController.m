//
//  InfoViewController.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 2/17/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "AppDelegate.h"
#import "WebViewController.h"
#import "InfoViewController.h"
#import "Settings.h"
#import "MapStyleCell.h"

@interface AppLink : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *imageUrl;

@end

@implementation AppLink

@end

@interface InfoViewController () {
    NSMutableArray<AppLink *> *appLinks;
}
@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"vcInformationTitle", nil);
    [self setClearsSelectionOnViewWillAppear:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"WebViewSegue"]) {
        id dest = [segue destinationViewController];
        if ([dest isKindOfClass:[WebViewController class]]) {
            WebViewController *webViewController = (WebViewController *) dest;
            webViewController.string = sender;
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger result = 0;

    switch (section) {
        case 0:
            result = 1;
            break;
        case 1:
            result = 3;
            break;
        default:
            break;
    }

    return result;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = @"";

    switch (section) {
        case 0:
            sectionName = NSLocalizedString(@"settingsText", nil);
            break;
        case 1:
            sectionName = NSLocalizedString(@"aboutText", nil);
            break;
        default:
            break;
    }

    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifierMapStyle = @"MapStyleCell";

    UITableViewCell *cell = [UITableViewCell new];

    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMapStyle forIndexPath:indexPath];
                    cell.imageView.image = nil;
                    
                    MapStyleCell *mapStyleCell = (MapStyleCell *) cell;
                    mapStyleCell.aLabel.text = NSLocalizedString(@"mapStyleText", nil);
                    mapStyleCell.detailTextLabel.text = @"";
                    mapStyleCell.accessoryType = UITableViewCellAccessoryNone;
                    [mapStyleCell.segmentedControl removeAllSegments];
                    [mapStyleCell.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"mapStyleStandardText", nil) atIndex:0 animated:NO];
                    [mapStyleCell.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"mapStyleSatelliteText", nil) atIndex:1 animated:NO];
                    [mapStyleCell.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"mapStyleHybridText", nil) atIndex:2 animated:NO];
                    [mapStyleCell.segmentedControl addTarget:self
                                                      action:@selector(mapStyleSelected:)
                                            forControlEvents:UIControlEventValueChanged];
                    mapStyleCell.segmentedControl.selectedSegmentIndex = Settings.sharedInstance.selectedMapStyle.integerValue;
                }
                    break;

                default:
                    break;
            }
        }
            break;
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    cell.imageView.image = nil;
                    cell.textLabel.text = NSLocalizedString(@"versionText", nil);
                    cell.detailTextLabel.text = [Settings.sharedInstance versionString];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 1: {
                    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    cell.imageView.image = nil;
                    cell.textLabel.text = NSLocalizedString(@"authorText", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"authorTextValue", nil);
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                }
                    break;
                case 2: {
                    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    cell.imageView.image = nil;
                    cell.textLabel.text = NSLocalizedString(@"artworkText", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"artworkTextValue", nil);
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                }
                    break;

                default:
                    break;
            }
        }
            break;
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self linkActionWithIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self linkActionWithIndexPath:indexPath];
}

- (void)linkActionWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                break;
            case 1:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vladislavjevremovic.com"] options:@{} completionHandler:nil];
                break;
            case 2:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rs.linkedin.com/in/zarkocvijovic"] options:@{} completionHandler:nil];
                break;

            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - Private Methods

- (void)mapStyleSelected:(id)sender {
    Settings.sharedInstance.selectedMapStyle = @(((UISegmentedControl *) sender).selectedSegmentIndex);
    [Settings.sharedInstance save];
}

@end
