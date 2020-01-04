//
//  WebViewController.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 3/3/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController () <WKNavigationDelegate>

@property(nonatomic, weak) IBOutlet WKWebView *webView;

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

//    self.webView.scalesPageToFit = YES;
//    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.navigationDelegate = self;

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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        [[UIApplication sharedApplication] openURL:[navigationAction.request URL] options:@{} completionHandler:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)dealloc {
    self.webView.navigationDelegate = nil;
    self.webView.UIDelegate = nil;
    self.webView = nil;
}

@end
