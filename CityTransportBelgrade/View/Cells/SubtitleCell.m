//
//  SubtitleCell.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 6/29/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "SubtitleCell.h"

@implementation SubtitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    // ignore the style argument, use our own to override
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        //
    }
    return self;
}

@end
