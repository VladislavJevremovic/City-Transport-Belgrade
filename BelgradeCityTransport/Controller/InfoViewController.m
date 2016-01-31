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

    [self getAppLinks];
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
    return 4;
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
        case 2:
            result = 1;
            break;
        case 3:
            result = (NSInteger) appLinks.count;
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
        case 2:
            sectionName = NSLocalizedString(@"acknowledgementsText", nil);
            break;
        case 3:
            sectionName = NSLocalizedString(@"otherAppsText", nil);
            break;

        default:
            break;
    }

    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifierMapStyle = @"MapStyleCell";

    UITableViewCell *cell = nil;

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
                    cell.detailTextLabel.text = @"Vladislav Jevremović";
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                }
                    break;
                case 2: {
                    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    cell.imageView.image = nil;
                    cell.textLabel.text = NSLocalizedString(@"artworkText", nil);
                    cell.detailTextLabel.text = @"Žarko Cvijović";
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                }
                    break;

                default:
                    break;
            }
        }
            break;
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    cell.imageView.image = nil;
                    cell.textLabel.text = NSLocalizedString(@"acknowledgementsLabelText", nil);
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;

                default:
                    break;
            }
        }
            break;
        case 3: {
            switch (indexPath.row) {
                case 0: {
                    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appLinks[(NSUInteger) indexPath.row].imageUrl]]];
                    cell.textLabel.text = appLinks[(NSUInteger) indexPath.row].title;
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cocoa-bytes.com"]];
                break;
            case 2:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rs.linkedin.com/in/zarkocvijovic"]];
                break;

            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                [self performSegueWithIdentifier:@"WebViewSegue" sender:[self stringFromFile:@"Acknowledgements.html"]];
                break;

            default:
                break;
        }
    } else if (indexPath.section == 3) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appLinks[(NSUInteger) indexPath.row].url]];
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

- (NSString *)stringFromFile:(NSString *)file {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:@""];
    if (filePath) {
        NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        return myText;
    }
    
    return @"";
}

- (void)getAppLinks {
    NSString *ownId = @"1080130205";  // don't include this app
    appLinks = [NSMutableArray array];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    spinner.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    self.tableView.tableHeaderView = spinner;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/developer/vladislav-jevremovic/id612312893"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSString *stringWithData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSMutableArray *ids = [NSMutableArray array];
            NSRegularExpression *re = [[NSRegularExpression alloc] initWithPattern:@"https\\:\\/\\/itunes\\.apple\\.com\\/us\\/app\\/[a-z-]*\\/id([0-9]*)\\?mt=8" options:NSRegularExpressionCaseInsensitive error:nil];
            NSArray *matches = [re matchesInString:stringWithData options:0 range:NSMakeRange(0, stringWithData.length)];
            for (NSTextCheckingResult *match in matches) {
                NSString *substring = [stringWithData substringWithRange:[match rangeAtIndex:1]];
                if (![ids containsObject:substring] && ![substring isEqualToString:ownId]) {
                    [ids addObject:substring];
                }
            }
            for (NSString *_id in ids) {
                NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", _id]];
                NSURLRequest *urlRequest2 = [NSURLRequest requestWithURL:url2];
                NSURLSessionDataTask *task2 = [session dataTaskWithRequest:urlRequest2 completionHandler:^(NSData *data2, NSURLResponse *response2, NSError *error2) {
                    if (error2 == nil) {
                        NSError *jsonError = nil;
                        id responseObject = [NSJSONSerialization JSONObjectWithData:data2 options:(NSJSONReadingOptions) 0 error:&jsonError];
                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *dict = (NSDictionary *)responseObject;
                            if ([dict[@"results"] isKindOfClass:[NSArray class]]) {
                                NSArray *results = dict[@"results"];
                                for (NSDictionary *result in results) {
                                    AppLink *appLink = [[AppLink alloc] init];
                                    appLink.title = result[@"trackName"];
                                    appLink.url = result[@"trackViewUrl"];
                                    appLink.imageUrl = result[@"artworkUrl60"];
                                    [self->appLinks addObject:appLink];
                                }
                            }
                        }

                        [self->appLinks sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
                            AppLink *a1 = (AppLink *)obj1;
                            AppLink *a2 = (AppLink *)obj2;
                            return [a1.title compare:a2.title];
                        }];

                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView beginUpdates];
                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
                            [self.tableView endUpdates];
                        });
                    } else {
                        NSLog(@"Error: %@", error2);
                    }
                }];
                [task2 resume];
            }
        } else {
            NSLog(@"Error: %@", error);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.tableHeaderView = nil;
        });
    }];
    [task resume];
}

@end
