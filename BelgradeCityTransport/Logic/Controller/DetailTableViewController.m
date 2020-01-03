//
//  DetailTableViewController.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/26/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailTableViewController.h"
#import "SubtitleCell.h"
#import "DrawingHelper.h"
#import "DataManager.h"
#import "GSPLine.h"
#import "GSPStop.h"
#import "GSPLineStop.h"

#define CellIdentifier @"Cell"

@interface DetailTableViewController () <UIAlertViewDelegate> {
    NSArray *_dataSource;
    UIAlertView *_alertView;
}

@property(nonatomic, weak) IBOutlet UIView *headerView;
@property(nonatomic, weak) IBOutlet UILabel *label;
@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic, weak) IBOutlet UIButton *buttonFavorite;

- (IBAction)tappedButtonFavorite:(id)sender;

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[SubtitleCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    if (_alertView) {
        _alertView.delegate = nil;
        [_alertView dismissWithClickedButtonIndex:[_alertView cancelButtonIndex]
                                         animated:NO];
        _alertView = nil;
    }
}

#pragma mark - Private methods

- (void)setObject:(id)anObject {
    if (_object != anObject) {
        _object = anObject;
        [self updateViewWithObject:self.object];
    }
}

- (void)updateButtonFavorite:(NSString *)stopCode {
    UIImage *img = [UIImage imageNamed:[DataManager.sharedInstance isFavoriteStop:stopCode] ? @"StarActive" : @"Star"];
    [self.buttonFavorite setImage:img forState:UIControlStateNormal];
}

- (void)updateViewWithObject:(id)object {
    if (object) {
        if (self.displayMode == DisplayMode_Lines) {
            GSPLine *line = (GSPLine *) object;

            self.label.text = line.descriptionAtoB;
            self.imageView.image = [[DrawingHelper sharedInstance] imageForListWithText:line.name annotationType:AnnotationType_Bus + (uint) line.type.intValue];
            self.buttonFavorite.hidden = YES;

            NSArray *dataSource = [[line.stops allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"line.direction" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];

            _dataSource = [[dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"line.direction = %@", line.direction]] valueForKey:@"stop"];
        }
        else if (self.displayMode == DisplayMode_Stops) {
            GSPStop *stop = (GSPStop *) object;

            self.label.text = stop.name;
            self.imageView.image = [[DrawingHelper sharedInstance] imageForListWithText:stop.code.stringValue annotationType:AnnotationType_Stop];

            [self updateButtonFavorite:stop.code.stringValue];

            NSArray *dataSource = [[stop.lines allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"line.name" ascending:YES selector:@selector(localizedStandardCompare:)]]];

            _dataSource = [dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"line.active = %@", @YES]];
        }
    }

    [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate) {
        [self.delegate detailTableViewController:self didChangeOffsetTo:scrollView.contentOffset.y];
    }
}

- (IBAction)tappedButtonFavorite:(id)sender {
    if (self.displayMode == DisplayMode_Stops) {
        GSPStop *stop = (GSPStop *) self.object;
        NSString *stopCodeString = stop.code.stringValue;

        BOOL isFavoriteStop = [DataManager.sharedInstance isFavoriteStop:stopCodeString];
        if (!isFavoriteStop) {
            BOOL addedOK = [DataManager.sharedInstance addFavoriteStop:stopCodeString];
            if (!addedOK && !_alertView) {
                _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorTitle", nil)
                                                        message:NSLocalizedString(@"errorMaximumNumberOfFavoritesReachedText", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"okTitle", nil), nil];
                [_alertView show];
            }
        }
        else {
            [DataManager.sharedInstance removeFavoriteStop:stopCodeString];
        }

        [self updateButtonFavorite:stopCodeString];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.displayMode == DisplayMode_Lines) {
        return 1;
    }
    else if (self.displayMode == DisplayMode_Stops) {
        return 1;
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.displayMode == DisplayMode_Lines) {
        return (NSInteger) _dataSource.count;
    }
    else if (self.displayMode == DisplayMode_Stops) {
        return (NSInteger) _dataSource.count;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (self.displayMode == DisplayMode_Stops) {
        GSPLineStop *lineStop = (GSPLineStop *) _dataSource[(NSUInteger) indexPath.row];
        GSPLine *line = lineStop.line;

        cell.textLabel.text = [lineStop isKindOfClass:[NSNull class]] ? @"" : line.descriptionAtoB;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.text = @"";
        cell.imageView.image = [lineStop isKindOfClass:[NSNull class]] ? nil : [[DrawingHelper sharedInstance] imageForListWithText:line.name annotationType:AnnotationType_Bus + (uint) line.type.intValue];
    }
    else if (self.displayMode == DisplayMode_Lines) {
        GSPStop *stop = (GSPStop *) _dataSource[(NSUInteger) indexPath.row];

        cell.textLabel.text = [stop isKindOfClass:[NSNull class]] ? @"" : stop.name;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.text = @"";
        cell.imageView.image = [stop isKindOfClass:[NSNull class]] ? nil : [[DrawingHelper sharedInstance] imageForListWithText:stop.code.stringValue annotationType:AnnotationType_Stop];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate) {
        id object = nil;
        if (self.displayMode == DisplayMode_Stops) {
            GSPLineStop *lineStop = (GSPLineStop *) _dataSource[(NSUInteger) indexPath.row];
            if (![lineStop isKindOfClass:[NSNull class]]) {
                object = [DataManager.sharedInstance lineForName:lineStop.line.name withDirection:lineStop.line.direction];
            }
        }
        else if (self.displayMode == DisplayMode_Lines) {
            GSPStop *stop = (GSPStop *) _dataSource[(NSUInteger) indexPath.row];
            if (![stop isKindOfClass:[NSNull class]]) {
                object = stop;
            }
        }

        if (object) {
            [self.delegate detailTableViewController:self didSelectObject:object];
        }
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.displayMode == DisplayMode_Stops) {
        GSPLineStop *lineStop = (GSPLineStop *) _dataSource[(NSUInteger) indexPath.row];
        if (![lineStop isKindOfClass:[NSNull class]]) {
            GSPLine *line = [DataManager.sharedInstance lineForName:lineStop.line.name withDirection:lineStop.line.direction];
            if (![line.active boolValue]) {
                [cell setBackgroundColor:kCustomColorLightGray];
            } else {
                [cell setBackgroundColor:[UIColor whiteColor]];
            }
        }
    }
    else if (self.displayMode == DisplayMode_Lines) {
        GSPStop *stop = (GSPStop *) _dataSource[(NSUInteger) indexPath.row];
        if (![stop isKindOfClass:[NSNull class]]) {
            if (![stop.active boolValue]) {
                [cell setBackgroundColor:kCustomColorLightGray];
            }
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    _alertView.delegate = nil;
    _alertView = nil;
}

@end
