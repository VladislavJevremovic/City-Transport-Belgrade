//
//  DetailViewController.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/27/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailMapViewController.h"
#import "GSPLine.h"
#import "GSPStop.h"
#import "TimeTableWebViewController.h"

@interface DetailViewController () <DetailTableViewControllerDelegate, UIAlertViewDelegate> {
    DetailTableViewController *detailTableViewController;
    DetailMapViewController *detailMapViewController;
}

@end

@implementation DetailViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        detailTableViewController = [[DetailTableViewController alloc] init];
        detailMapViewController = [[DetailMapViewController alloc] init];
        detailTableViewController.delegate = self;

        [self setFrontController:detailTableViewController];
        [self setBackController:detailMapViewController];
        [self setHidesBottomBarWhenPushed:YES];
        [self setClosedTopOffset:CLOSED_TOP_OFFSET];
        [self setOpenBottomOffset:OPEN_BOTTOM_OFFSET];
        [self setPullToToggleEnabled:YES];
        [self setOpenDragOffset:OPEN_DRAG_OFFSET];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [detailMapViewController updateMapViewForScrollOffset:detailTableViewController.tableView.contentOffset.y];

    // add not-available banner
    if (self.displayMode == DisplayMode_Stops) {
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 24)];
        infoView.backgroundColor = [UIColor colorWithRed:253.0f / 255.0f green:199.0f / 255.0f blue:44.0f / 255.0f alpha:0.8f];

        UILabel *label = [[UILabel alloc] initWithFrame:infoView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.text = NSLocalizedString(@"errorVehiclePositionsUnavailableText", nil);
        label.font = [UIFont boldSystemFontOfSize:12.0];
        [infoView addSubview:label];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        button.frame = CGRectMake(self.view.bounds.size.width - 22 - 1, 1, 22, 22);
        [button addTarget:self action:@selector(showVehiclePositionsUnavailableMessage:) forControlEvents:UIControlEventTouchUpInside];

        [infoView addSubview:button];

        [detailMapViewController.view addSubview:infoView];
    }
}

- (void)showVehiclePositionsUnavailableMessage:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"infoTitle", nil)
                                                                             message:NSLocalizedString(@"errorVehiclePositionsUnavailableLongText", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"okTitle", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark - Private methods

- (void)addButtonsRight {
    NSMutableArray *rightButtons = [NSMutableArray array];

    if (self.displayMode == DisplayMode_Stops) {
        UIBarButtonItem *rightItemUSSD = [[UIBarButtonItem alloc]
                initWithTitle:NSLocalizedString(@"infoUSSD", nil)
                        style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(clipBoardActionWithStopCode:)];
        [rightButtons addObject:rightItemUSSD];
    }
    else if (self.displayMode == DisplayMode_Lines) {
        UIBarButtonItem *rightItemUSSD = [[UIBarButtonItem alloc]
                initWithImage:[UIImage imageNamed:@"Time"]
                        style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(timeTableAction:)];
        [rightButtons addObject:rightItemUSSD];
    }

    self.navigationItem.rightBarButtonItems = [rightButtons copy];
}

- (void)removeButtonsRight {
    self.navigationItem.rightBarButtonItems = nil;
}

- (void)setObject:(id)anObject {
    if (_object != anObject) {
        _object = anObject;

        detailMapViewController.displayMode = self.displayMode;
        detailMapViewController.managedObjectContext = self.managedObjectContext;
        detailMapViewController.object = self.object;

        detailTableViewController.displayMode = self.displayMode;
        detailTableViewController.object = self.object;

        if (self.displayMode == DisplayMode_Stops) {
            GSPStop *stop = (GSPStop *) self.object;
            self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"vcStopTitle", nil), stop.code.stringValue];
        }
        else if (self.displayMode == DisplayMode_Lines) {
            GSPLine *line = (GSPLine *) self.object;
            self.title = [NSString stringWithFormat:@"%@ %@ (%@)", NSLocalizedString(@"vcLineTitle", nil), line.name, line.direction];
        }
        [self addButtonsRight];
    }
}

- (void)reloadDetailTableView {
    [detailTableViewController.tableView reloadData];
}

- (IBAction)clipBoardActionWithStopCode:(id)sender {
    NSNumber *stopCode = ((GSPStop *) self.object).code;
    NSString *phoneToCall = [NSString stringWithFormat:@"*011*%@#", stopCode];

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = phoneToCall;

    if (NSClassFromString(@"UIAlertController") != nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:phoneToCall
                                                                       message:NSLocalizedString(@"infoUSSDText", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"okTitle", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:phoneToCall
                                                                                 message:NSLocalizedString(@"infoUSSDText", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"okTitle", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:true completion:nil];
    }
}

- (IBAction)timeTableAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TimeTableWebViewController *webViewController = (TimeTableWebViewController *) [storyboard instantiateViewControllerWithIdentifier:@"TimeTableWebViewController"];
    webViewController.lineName = ((GSPLine *) self.object).map.lowercaseString;
    webViewController.lineDirection = ((GSPLine *) self.object).direction;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - DetailTableViewControllerDelegate

- (void)detailTableViewController:(DetailTableViewController *)viewController didChangeOffsetTo:(CGFloat)offset {
    [detailMapViewController updateMapViewForScrollOffset:offset];
}

- (void)detailTableViewController:(DetailTableViewController *)viewController didSelectObject:(id)object {
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.displayMode = (DisplayMode) (1 - self.displayMode);
    detailViewController.managedObjectContext = self.managedObjectContext;
    detailViewController.object = object;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
