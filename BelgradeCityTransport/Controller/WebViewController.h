//
//  WebViewController.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 3/3/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property(nonatomic, copy) NSString *string;
@property(nonatomic, strong) NSURL *url;

@end
