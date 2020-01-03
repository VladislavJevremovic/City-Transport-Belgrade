//
//  TimeTableWebViewController.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 3/3/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "TimeTableWebViewController.h"
#import "NSString+Utility.h"
#import <WebKit/WebKit.h>

@interface TimeTableWebViewController () <WKNavigationDelegate>

@property(nonatomic, weak) IBOutlet WKWebView *webView;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, weak) IBOutlet UILabel *labelBusevi;

@end

@implementation TimeTableWebViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = NSLocalizedString(@"tbTimetableTitle", nil);
    }
    return self;
}

- (void)loadStringIntoWebView {
    if (self.lineName != nil && self.lineDirection != nil && self.webView != nil) {
        NSString *requestString = nil;
        NSString *urlPrefixString = @"http://www.busevi.com/images/stories/Red-Voznje/Gradski-Prevoz-BG/linija.";
        if ([self.lineName endsWith:@"##"]) {
            if ([self.lineName isEqualToString:@"9a##"]) {
                requestString = [NSString stringWithFormat:@"%@9a-%@-2.png", urlPrefixString, ([self.lineDirection isEqualToString:@"A"] ? @"1" : @"2")];
            } else if ([self.lineName isEqualToString:@"9l##"]) {
                requestString = [NSString stringWithFormat:@"%@9l-%@-1.png", urlPrefixString, ([self.lineDirection isEqualToString:@"A"] ? @"1" : @"2")];
            }
        } else if ([self.lineName endsWith:@"#"]) {
            requestString = [NSString stringWithFormat:@"%@%@.png", urlPrefixString, [self.lineName substringToIndex:self.lineName.length - 1]];
        } else {
            requestString = [NSString stringWithFormat:@"%@%@-%@.png", urlPrefixString, self.lineName, ([self.lineDirection isEqualToString:@"A"] ? @"1" : @"2")];
        }

        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestString]]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.webView.scalesPageToFit = YES;
//    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
//    self.webView.delegate = self;

    [self addButtonsRight];
    [self attachTapGestureRecognizerToLabelBusevi];
    [self loadStringIntoWebView];
}

- (void)attachTapGestureRecognizerToLabelBusevi {
    self.labelBusevi.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelBuseviTapped:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.labelBusevi addGestureRecognizer:tapGestureRecognizer];
}

- (void)labelBuseviTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://busevi.com"] options:@{} completionHandler:nil];
}

- (void)setLineName:(NSString *)lineName {
    _lineName = [lineName copy];

    [self loadStringIntoWebView];
}

- (void)setLineDirection:(NSString *)lineDirection {
    _lineDirection = [lineDirection copy];

    [self loadStringIntoWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];

    UIAlertView *_alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorTitle", nil)
                                                         message:NSLocalizedString(@"errorDepartureFetchFailedText", nil)
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"okTitle", nil), nil];
    [_alertView show];
}

- (void)dealloc {
//    self.webView.delegate = nil;
    self.webView = nil;
}

- (void)addButtonsRight {
    NSMutableArray *rightButtons = [NSMutableArray array];

    UIBarButtonItem *rightItemUSSD = [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"ArrowReload"]
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(timeTableActionWithStopCode:)];
    [rightButtons addObject:rightItemUSSD];

    self.navigationItem.rightBarButtonItems = [rightButtons copy];
}

- (IBAction)timeTableActionWithStopCode:(id)sender {
    [self loadStringIntoWebView];
}

@end
