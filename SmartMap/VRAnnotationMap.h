//
//  VRAnnotationMap.h
//  SmartMap
//
//  Created by Admin on 17.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import <MapKit/MapKit.h>

@interface VRAnnotationMap : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    
}

@property (assign, nonatomic)CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) NSInteger index;

@end
