//
//  MapViewController.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 4/8/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "DataManager.h"
#import "MapViewController.h"
#import "LocationAnnotation.h"
#import "GSPStop.h"
#import "DetailViewController.h"

#import "ClusterAnnotationView.h"

float const kDropDownHideTime = 2.5;
double const kZoomLevel = 1000.0;
int const kBatchCount = 10000; // 500 or stmh like that causes CF crash

@interface MapViewController () <UIActionSheetDelegate, MKMapViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate> {
    CLLocation *_oldLocation;
    BOOL _initiallyLocated;
    CLLocationManager *_locationManager;
}

@property(nonatomic, weak) IBOutlet UIButton *buttonLocateMe;
@property(nonatomic, weak) IBOutlet UILabel *infoLabel;
@property(nonatomic, weak) IBOutlet MKMapView *mapView;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation MapViewController

- (MKMapType)mapTypeFromSelectedIndex:(NSNumber *)selectedIndex {
    switch (selectedIndex.integerValue) {
        case 0:
            return MKMapTypeStandard;
        case 1:
            return MKMapTypeSatellite;
        case 2:
            return MKMapTypeHybrid;
        default:
            return MKMapTypeStandard;
    }
}

- (void)initMapView {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];

    // start with Belgrade center
    CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake(44.820556, 20.462222);
    _oldLocation = [[CLLocation alloc] initWithLatitude:zoomLocation.latitude longitude:zoomLocation.longitude];

    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:zoomLocation
                                                     fromEyeCoordinate:zoomLocation
                                                           eyeAltitude:kZoomLevel];

    [_mapView setCamera:camera animated:NO];
    _mapView.rotateEnabled = NO;
    _mapView.pitchEnabled = NO;
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"tbMapTitle", nil);

    [self initMapView];
    self.buttonLocateMe.enabled = NO;

    [self startAddingAnnotations];
}

- (void)startAddingAnnotations {
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;

    NSMutableArray *annotations = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *stops = [DataManager.sharedInstance fetchStops];
        for (NSUInteger i = 0; i < stops.count; i++) {
            GSPStop *stop = (GSPStop *) stops[i];

            LocationAnnotation *annotation = [self locationAnnotationForAddress:stop.code.stringValue];
            if (!annotation) {
                CLLocationCoordinate2D coordinateNew = CLLocationCoordinate2DMake(stop.latitude.doubleValue,
                        stop.longitude.doubleValue);
                annotation = [[LocationAnnotation alloc] initWithName:stop.name
                                                              address:stop.code.stringValue
                                                           coordinate:coordinateNew];
            }
            if (annotation != nil && ![annotation isEqual:[NSNull null]]) {
                [annotations addObject:annotation];
            } else {
                NSLog(@"%@", stop.code);
            }

            if (annotations.count == kBatchCount) {
                [self dispatchAnnotations:annotations queue:operationQueue];
                [annotations removeAllObjects];
            }
        }

        // remaining
        [self dispatchAnnotations:annotations queue:operationQueue];
        [operationQueue addOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicatorView stopAnimating];
            });
        }];
    });
}

- (void)dispatchAnnotations:(NSArray *)annotations queue:(NSOperationQueue *)operationQueue {
    NSArray *annotationsToDispatch = [annotations copy];
    [operationQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView addAnnotations:annotationsToDispatch];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _mapView.mapType = [self mapTypeFromSelectedIndex:Settings.sharedInstance.selectedMapStyle];
}

- (void)dealloc {
    _mapView = nil;
    _oldLocation = nil;
    _mapView.delegate = nil;
    _locationManager.delegate = nil;
}

#pragma mark - Private Methods

- (void)showInfoLabelWithText:(NSString *)text isError:(BOOL)isError {
    // if not on map
    if (self.tabBarController.selectedIndex != 0) {
        return;
    }

    UIColor *infoBackgroundColor = nil;
    if (isError) {
        infoBackgroundColor = [UIColor colorWithRed:1.0f green:59.0f / 255.0f blue:48.0f / 255.0f alpha:0.7f];
    } else {
        infoBackgroundColor = [UIColor colorWithRed:0.0f green:122.0f / 255.0f blue:1.0f alpha:0.7f];
    }

    self.infoLabel.hidden = false;
    self.infoLabel.textColor = UIColor.whiteColor;
    self.infoLabel.backgroundColor = infoBackgroundColor;
    self.infoLabel.text = text;
}

- (void)hideInfoLabel {
    self.infoLabel.hidden = true;
}

- (IBAction)tappedLocateMe:(id)sender {
    [self locateMe];
}

- (void)locateMe {
    if (_oldLocation != nil) {
        [self acquiredLocation:_oldLocation];
    } else {
        self.buttonLocateMe.enabled = NO;
    }
}

- (void)acquiredLocation:(CLLocation *)location {
    CLLocationCoordinate2D zoomLocation = location.coordinate;
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:zoomLocation
                                                     fromEyeCoordinate:zoomLocation
                                                           eyeAltitude:kZoomLevel];
    [_mapView setCamera:camera animated:NO];

    BOOL isRegionSupported;
    if ([self isLocationSupported:zoomLocation]) {
        isRegionSupported = YES;
    }
    else {
        isRegionSupported = NO;
        [self showInfoLabelWithText:NSLocalizedString(@"errorRegionNotSupportedText", nil) isError:YES];
    }

    if (isRegionSupported) {
        CLGeocoder *rgeo = [[CLGeocoder alloc] init];
        [rgeo reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (!error) {
                           if (placemarks != nil && placemarks.count >= 1) {
                               CLPlacemark *placemark = placemarks[0];
                               if (placemark != nil) {
                                   [self showInfoLabelWithText:[NSString stringWithFormat:@"%@", placemark.thoroughfare] isError:NO];
                               }
                           }
                       }
                       else {
                           NSLog(@"Reverse geocoding error: %@", [error localizedDescription]);
                           [self hideInfoLabel];
                       }
                   }
        ];
    }
}

- (BOOL)isLocationSupported:(CLLocationCoordinate2D)location {
    CLLocationCoordinate2D northWestCorner, southEastCorner;

    northWestCorner.latitude = 45.15;
    northWestCorner.longitude = 19.95;
    southEastCorner.latitude = 44.25;
    southEastCorner.longitude = 20.85;

    return location.latitude <= northWestCorner.latitude &&
            location.latitude >= southEastCorner.latitude &&
            location.longitude >= northWestCorner.longitude &&
            location.longitude <= southEastCorner.longitude;
}

- (LocationAnnotation *)locationAnnotationForAddress:(NSString *)address {
    for (id <MKAnnotation> annotation in [_mapView annotations]) {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            LocationAnnotation *locationAnnotation = (LocationAnnotation *) annotation;
            if ([locationAnnotation.subtitle isEqualToString:address]) {
                return locationAnnotation;
            }
        }
    }

    return nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (!self.buttonLocateMe.enabled)
            self.buttonLocateMe.enabled = YES;
        _mapView.showsUserLocation = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error description]);
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (![self isLocationSupported:mapView.centerCoordinate]) {
        [self showInfoLabelWithText:NSLocalizedString(@"errorRegionNotSupportedText", nil) isError:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    NSString *identifier = @"Annotation";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.canShowCallout = true;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else {
        annotationView.annotation = annotation;
    }

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    LocationAnnotation *annotation = (LocationAnnotation *)view.annotation;

    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.displayMode = DisplayMode_Stops;
    detailViewController.managedObjectContext = self.managedObjectContext;
    detailViewController.object = [DataManager.sharedInstance fetchStopForCode:annotation.subtitle];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!_initiallyLocated) {
        _initiallyLocated = YES;
        [self acquiredLocation:userLocation.location];
    }

    _oldLocation = userLocation.location;

    if (!self.buttonLocateMe.enabled)
        self.buttonLocateMe.enabled = YES;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    // ...
}

//- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation {
//    return [NSString stringWithFormat:NSLocalizedString(@"clusterAnnotationStopsFormatText", nil), numAnnotations];
//}

@end
