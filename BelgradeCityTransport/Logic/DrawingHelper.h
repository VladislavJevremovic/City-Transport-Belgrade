//
//  DrawingHelper.h
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/27/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnotationType.h"

@interface DrawingHelper : NSObject

+ (DrawingHelper *)sharedInstance;

- (UIImage *)imageForListWithText:(NSString *)text
                   annotationType:(AnnotationType)annotationType;

- (UIImage *)bluePinWithArea:(BOOL)area;

- (UIImage *)pinAnnotationWithColor:(UIColor *)color;

@end
