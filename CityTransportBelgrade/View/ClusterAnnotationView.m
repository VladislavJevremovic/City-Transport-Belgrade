//
//  ClusterAnnotationView.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 4/21/12.
//  Copyright (c) 2012 Vladislav Jevremovic. All rights reserved.
//

#import "ClusterAnnotationView.h"
#import "DrawingHelper.h"

@implementation ClusterAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setCount:1];
    }
    return self;
}

- (void)setCount:(NSUInteger)count {
    _count = count;
    [self setNeedsLayout];
}

- (void)setBlue:(BOOL)blue {
    _blue = blue;
    [self setNeedsLayout];
}

- (void)setUniqueLocation:(BOOL)uniqueLocation {
    _uniqueLocation = uniqueLocation;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    // Images are faster than using drawRect:
    UIImage *image = [[DrawingHelper sharedInstance] bluePinWithArea:!self.isUniqueLocation];
    self.image = image;
}

@end
