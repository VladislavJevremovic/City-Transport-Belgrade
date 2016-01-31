//
//  DrawingHelper.m
//  BelgradeCityTransport
//
//  Created by Vladislav Jevremovic on 10/27/13.
//  Copyright (c) 2013 Vladislav Jevremovic. All rights reserved.
//

#import "DrawingHelper.h"

@interface DrawingHelper ()

@property(nonatomic, strong) NSMutableDictionary *imageCache;

@end

@implementation DrawingHelper

+ (DrawingHelper *)sharedInstance {
    static DrawingHelper *_default = nil;
    if (_default != nil) {
        return _default;
    }

    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        _default = [[DrawingHelper alloc] init];
    });
    return _default;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key {
    (self.imageCache)[key] = image;
}

- (UIImage *)getCachedImageForKey:(NSString *)key {
    return (self.imageCache)[key];
}

- (UIImage *)imageForListWithText:(NSString *)text
                   annotationType:(AnnotationType)annotationType {
    return [self imageWithText:text
                annotationType:annotationType
                         width:40.0
                        height:24.0
                      showBase:NO
                  cornerRadius:4.0
                      fontSize:12.0
                    textOffset:4.0];
}

- (UIImage *)imageWithText:(NSString *)text
            annotationType:(AnnotationType)annotationType
                     width:(CGFloat)width
                    height:(CGFloat)height
                  showBase:(BOOL)showBase
              cornerRadius:(CGFloat)cornerRadius
                  fontSize:(CGFloat)fontSize
                textOffset:(CGFloat)textOffset {
    NSString *cacheString = [NSString stringWithFormat:@"%@+%lu", text, (unsigned long) annotationType];

    // Caching
    UIImage *image = [self getCachedImageForKey:cacheString];
    if (image != nil) {
        return image;
    }

    CGFloat rW = width, rH = height, s = 44;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(s, s), NO, 0.0f);

    UIColor *fontColor;
    UIColor *fillColor;
    switch (annotationType) {
        case AnnotationType_Stop:
            fillColor = [UIColor colorWithRed:0.0f / 255.0f green:82.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];
            fontColor = [UIColor whiteColor];
            break;
        case AnnotationType_Tram:
            fillColor = [UIColor colorWithRed:219.0f / 255.0f green:35.0f / 255.0f blue:37.0f / 255.0f alpha:1.0f];
            fontColor = [UIColor whiteColor];
            break;
        case AnnotationType_Trolley:
            fillColor = [UIColor colorWithRed:238.0f / 255.0f green:137.0f / 255.0f blue:34.0f / 255.0f alpha:1.0f];
            fontColor = [UIColor blackColor];
            break;
        case AnnotationType_Bus:
            fillColor = [UIColor colorWithRed:253.0f / 255.0f green:199.0f / 255.0f blue:44.0f / 255.0f alpha:1.0f];
            fontColor = [UIColor blackColor];
            break;
        default:
            break;
    }

    [[UIColor grayColor] setStroke];

    [fillColor setFill];

    if (showBase) {
        UIBezierPath *pathStick = [UIBezierPath bezierPath];
        [pathStick moveToPoint:CGPointMake(s / 2.0f - 0.5f, s / 2.0f)];
        [pathStick addLineToPoint:CGPointMake(s / 2.0f - 0.5f, s - 1)];
        [pathStick setLineWidth:1.0];
        [pathStick stroke];
    }

    UIBezierPath *pathBoard = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((s - rW) / 2.0f, (s - rH) / 2.0f, rW, rH) cornerRadius:cornerRadius];
    [pathBoard setLineWidth:1.0];
    [pathBoard fill];

    if (showBase) {
        UIBezierPath *pathRoot = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(s / 2.0f - 1.5f, s - 3, 2, 2)];
        [pathRoot setLineWidth:1.0];
        [pathRoot stroke];
    }

    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];

    CGRect aRectangle = CGRectMake((s - rW) / 2, textOffset + (s - rH) / 2, rW, rH);

    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
            NSParagraphStyleAttributeName : paragraph,
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : fontColor
    };

    [text drawInRect:aRectangle
      withAttributes:attributes];

    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self cacheImage:resultingImage forKey:cacheString];

    return resultingImage;
}

- (UIImage *)bluePinWithArea:(BOOL)area {
    UIColor *color = [UIColor colorWithRed:0 green:122 / 255.0f blue:255 / 255.0f alpha:1];
    UIImage *baseImage = [self pinAnnotationWithColor:color];
    if (!area) {
        return baseImage;
    } else {
        CGColorRef colorRef = color.CGColor;
        NSString *colorString = [[CIColor colorWithCGColor:colorRef].stringRepresentation stringByReplacingOccurrencesOfString:@" " withString:@""];
        colorString = [colorString stringByAppendingString:@"+Area"];

        // Caching
        UIImage *image = [self getCachedImageForKey:colorString];
        if (image != nil) {
            return image;
        }

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(64.0f, 64.0f), NO, 0.0f);

        UIColor *fillColor = [UIColor colorWithRed:29 / 255.0f green:98 / 255.0f blue:240 / 255.0f alpha:0.15f];

        [[UIColor grayColor] setStroke];
        [fillColor setFill];

        UIBezierPath *pathBoard = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
        [pathBoard setLineWidth:1.0];
        [pathBoard fill];

        UIImage *pinImage = [self bluePinWithArea:NO];
        [pinImage drawAtPoint:CGPointMake(24, 5)];

        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        [self cacheImage:resultingImage forKey:colorString];

        return resultingImage;
    }
}

- (UIImage *)pinAnnotationWithColor:(UIColor *)color {
    CGColorRef colorRef = color.CGColor;
    NSString *colorString = [[CIColor colorWithCGColor:colorRef].stringRepresentation stringByReplacingOccurrencesOfString:@" " withString:@""];

    // Caching
    UIImage *image = [self getCachedImageForKey:colorString];
    if (image != nil) {
        return image;
    }

    CGSize size = CGSizeMake(32, 39);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);

    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    CGContextScaleCTM(context, 0.5, 0.5);

    //// Color Declarations
    UIColor *pinColor = color;
    UIColor *pinBaseColor = [UIColor colorWithRed:0.372f green:0.372f blue:0.372f alpha:1];
    UIColor *pinStickColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1];
    UIColor *pinShadowColor = [UIColor colorWithRed:0.263f green:0.259f blue:0.259f alpha:1];
    UIColor *pinShadowFillColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.137f];

    //// Gradient Declarations
    CGFloat pinStickMiddleGradientLocations[] = {0, 1};
    CGGradientRef pinStickMiddleGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) @[(id) UIColor.lightGrayColor.CGColor, (id) pinStickColor.CGColor], pinStickMiddleGradientLocations);

    //// Shadow Declarations
    UIColor *shadow = pinShadowColor;
    CGSize shadowOffset = CGSizeMake(0.1f, -0.1f);
    CGFloat shadowBlurRadius = 3;

    //// pinBase Drawing
    UIBezierPath *pinBasePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(12, 69.5, 7, 2)];
    [pinBaseColor setFill];
    [pinBasePath fill];
    [pinBaseColor setStroke];
    pinBasePath.lineWidth = 1;
    [pinBasePath stroke];

    //// pinStick Drawing
    UIBezierPath *pinStickPath = [UIBezierPath bezierPathWithRect:CGRectMake(14, 26, 3, 44)];
    [pinStickColor setFill];
    [pinStickPath fill];

    //// pinStickMiddle Drawing
    UIBezierPath *pinStickMiddlePath = [UIBezierPath bezierPathWithRect:CGRectMake(15, 25, 1, 46)];
    CGContextSaveGState(context);
    [pinStickMiddlePath addClip];
    CGContextDrawLinearGradient(context, pinStickMiddleGradient, CGPointMake(15.5, 25), CGPointMake(15.5, 71), 0);
    CGContextRestoreGState(context);

    //// pinHead Drawing
    UIBezierPath *pinHeadPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2, 0, 27, 27)];
    [pinColor setFill];
    [pinHeadPath fill];

    //// pinHighlight Drawing
    UIBezierPath *pinHighlightPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(8, 6, 6, 6)];
    [UIColor.whiteColor setFill];
    [pinHighlightPath fill];

    //// pinShadow Drawing
    UIBezierPath *pinShadowPath = UIBezierPath.bezierPath;
    [pinShadowPath moveToPoint:CGPointMake(18, 69)];
    [pinShadowPath addCurveToPoint:CGPointMake(29, 49) controlPoint1:CGPointMake(18, 69) controlPoint2:CGPointMake(27, 51)];
    [pinShadowPath addCurveToPoint:CGPointMake(42, 44) controlPoint1:CGPointMake(31, 47) controlPoint2:CGPointMake(37.5, 47.25)];
    [pinShadowPath addCurveToPoint:CGPointMake(48, 37) controlPoint1:CGPointMake(46.5, 40.75) controlPoint2:CGPointMake(47.5, 38.5)];
    [pinShadowPath addCurveToPoint:CGPointMake(47.5, 28.5) controlPoint1:CGPointMake(48.5, 35.5) controlPoint2:CGPointMake(49.25, 31.25)];
    [pinShadowPath addCurveToPoint:CGPointMake(38, 25) controlPoint1:CGPointMake(45.75, 25.75) controlPoint2:CGPointMake(42, 25)];
    [pinShadowPath addCurveToPoint:CGPointMake(28, 29) controlPoint1:CGPointMake(34, 25) controlPoint2:CGPointMake(29, 28)];
    [pinShadowPath addCurveToPoint:CGPointMake(23.5, 35.5) controlPoint1:CGPointMake(27, 30) controlPoint2:CGPointMake(24.5, 31.5)];
    [pinShadowPath addCurveToPoint:CGPointMake(23.5, 41.5) controlPoint1:CGPointMake(22.5, 39.5) controlPoint2:CGPointMake(23.5, 41.5)];
    [pinShadowPath addCurveToPoint:CGPointMake(25.5, 47.5) controlPoint1:CGPointMake(23.5, 41.5) controlPoint2:CGPointMake(25, 46)];
    [pinShadowPath addCurveToPoint:CGPointMake(16, 68) controlPoint1:CGPointMake(26, 49) controlPoint2:CGPointMake(16, 68)];
    [pinShadowPath addLineToPoint:CGPointMake(18, 69)];
    [pinShadowPath closePath];
    pinShadowPath.lineJoinStyle = kCGLineJoinRound;

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, [shadow CGColor]);
    [pinShadowFillColor setFill];
    [pinShadowPath fill];
    CGContextRestoreGState(context);

    CGContextRestoreGState(context);

    //// Cleanup
    CGGradientRelease(pinStickMiddleGradient);
    CGColorSpaceRelease(colorSpace);

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Cache
    [self cacheImage:result forKey:colorString];

    return result;
}

@end
