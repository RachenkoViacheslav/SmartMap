//
//  UIView+MKAnnotationView.m
//  SmartMap
//
//  Created by Admin on 23.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import "UIView+MKAnnotationView.h"
#import <MapKit/MapKit.h>

@implementation UIView (MKAnnotationView)
-(MKAnnotationView*)superAnnotationView {
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView*)self;
    }
    if (!self.superview) {
        return nil;
    }
    return [self.superview superAnnotationView];
}


@end
