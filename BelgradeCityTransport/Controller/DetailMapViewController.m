//
//  DetailMapViewController.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/26/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailMapViewController.h"
#import "DetailViewController.h"
#import "DataManager.h"
#import "LocationAnnotation.h"
#import "GSPLine.h"
#import "GSPStop.h"
#import "GSPLineStop.h"
#import "DrawingHelper.h"
#import "MKMapView+Zoom.h"

@interface DetailMapViewController () <MKMapViewDelegate>

@property(nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation DetailMapViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initMapView];
    [self updateViewWithObject:self.object];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _mapView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _mapView.mapType = [self mapTypeFromSelectedIndex:Settings.sharedInstance.selectedMapStyle];
}

#pragma mark - Private Methods

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
    // start with Belgrade center
    CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake(44.820556, 20.462222);

    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:zoomLocation
                                                     fromEyeCoordinate:zoomLocation
                                                           eyeAltitude:kZoomLevel];

    [_mapView setCamera:camera animated:NO];
    _mapView.rotateEnabled = NO;
    _mapView.pitchEnabled = NO;
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
}

- (void)setObject:(id)anObject {
    if (_object != anObject) {
        _object = anObject;

        [self updateViewWithObject:self.object];
    }
}

- (void)updateViewWithObject:(id)object {
    if (!object || !_mapView) {
        return;
    }

    if (self.displayMode == DisplayMode_Lines) {
        GSPLine *line = (GSPLine *) object;

        [self addPinsFromLineNamed:line.name withDirection:line.direction andMap:_mapView];
    }
    else if (self.displayMode == DisplayMode_Stops) {
        GSPStop *stop = (GSPStop *) object;

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(stop.latitude.doubleValue,
                stop.longitude.doubleValue);
        LocationAnnotation *annotation = [[LocationAnnotation alloc] initWithName:stop.name
                                                                          address:stop.code.stringValue
                                                                       coordinate:coordinate];
        [_mapView addAnnotation:annotation];

        MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:coordinate
                                                         fromEyeCoordinate:coordinate
                                                               eyeAltitude:kZoomLevel];
        [_mapView setCamera:camera animated:NO];
    }
}

- (void)addPinsFromLineNamed:(NSString *)lineName withDirection:(NSString *)direction andMap:(MKMapView *)mapView {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GSPLineStop" inManagedObjectContext:self.managedObjectContext];
    [req setEntity:entityDescription];

    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"line.name =[cd] %@ AND line.direction =[cd] %@", lineName, direction];
    [req setPredicate:p1];

    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]];
    [req setSortDescriptors:sortDescriptors];

    NSArray *lineStops = [self.managedObjectContext executeFetchRequest:req error:nil];
    for (NSUInteger i = 0; i < lineStops.count; i++) {
        GSPLineStop *lineStop = (GSPLineStop *) lineStops[i];

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lineStop.stop.latitude.doubleValue,
                lineStop.stop.longitude.doubleValue);

        LocationAnnotation *annotation = [[LocationAnnotation alloc] initWithName:lineStop.stop.name
                                                                          address:lineStop.stop.code.stringValue
                                                                       coordinate:coordinate];
        [mapView addAnnotation:annotation];
    }

    if (lineStops.count > 1) {
        [mapView zoomToFitAnnotations:mapView.annotations];
    }
}

- (void)updateMapViewForScrollOffset:(CGFloat)offset {
    if (offset < 0) {
        CGRect newFrame = [self frameForScrollOffset:offset];
        self.mapView.frame = newFrame;
    }
}

- (CGRect)frameForScrollOffset:(CGFloat)offset {
    CGFloat topLayoutOffset = 64.0f;
    CGRect frame = self.mapView.frame;

    CGFloat oldCenterY = frame.size.height / 2.0f;
#if defined(__LP64__) && __LP64__
    CGFloat newCenterY = (fabs(offset) - topLayoutOffset) / 2.0f;
#else
    CGFloat newCenterY = (fabsf(offset) - topLayoutOffset) / 2.0f;
#endif
    CGFloat deltaY = oldCenterY - newCenterY;
    frame.origin.y = -deltaY + OPEN_BOTTOM_OFFSET;

    return frame;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *defaultPinID = @"MyLocation";
    if ([annotation isKindOfClass:[LocationAnnotation class]]) {
        MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if (pinView == nil) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                   reuseIdentifier:defaultPinID];
        } else {
            pinView.annotation = annotation;
        }

        pinView.enabled = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.canShowCallout = (self.displayMode == DisplayMode_Lines);
        pinView.image = [[DrawingHelper sharedInstance] bluePinWithArea:NO];

        return pinView;
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews {
    for (MKAnnotationView *annView in annotationViews) {
        annView.alpha = 0.0;
        [UIView animateWithDuration:0.5
                         animations:^{
                             annView.alpha = 1.0;
                         }];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    LocationAnnotation *annotation = (LocationAnnotation *) view.annotation;

    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.displayMode = DisplayMode_Stops;
    detailViewController.managedObjectContext = self.managedObjectContext;
    detailViewController.object = [DataManager.sharedInstance fetchStopForCode:annotation.subtitle];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
