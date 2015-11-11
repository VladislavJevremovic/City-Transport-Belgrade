//
//  MapStyleCell.h
//  CityTransportBelgrade
//
//  Created by Vladislav Jevremovic on 11/16/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapStyleCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel *aLabel;
@property(weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
