//
//  WebViewController.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 3/3/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property(nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = NSLocalizedString(@"infoTitle", nil);
    }
    return self;
}

- (void)loadStringIntoWebView {
    if (self.string != nil && self.webView != nil) {
        [self.webView loadHTMLString:self.string baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
}

- (void)loadURLIntoWebView {
    if (self.url != nil && self.webView != nil) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView.scalesPageToFit = YES;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.delegate = self;

    if (self.string != nil)
        [self loadStringIntoWebView];
    if (self.url != nil)
        [self loadURLIntoWebView];
}

- (void)setString:(NSString *)string {
    _string = [string copy];

    [self loadStringIntoWebView];
}

- (void)setUrl:(NSURL *)url {
    _url = [url copy];

    [self loadURLIntoWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }

    return YES;
}

- (void)dealloc {
    self.webView.delegate = nil;
    self.webView = nil;
}

@end
