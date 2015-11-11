//
//  SwitchCell.m
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 11/16/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
