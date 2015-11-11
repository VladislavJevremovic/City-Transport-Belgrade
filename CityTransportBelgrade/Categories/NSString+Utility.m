//
//  NSString+Utility.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 3/18/15.
//  Copyright (c) 2015 Vladislav Jevremovic. All rights reserved.
//

#import "NSString+Utility.h"

@implementation NSString (Utility)

- (BOOL)endsWith:(NSString *)ending {
    NSRange range = [self rangeOfString:ending options:NSCaseInsensitiveSearch];
    return (range.location != NSNotFound && range.location + range.length == [self length]);
}

@end
