//
//  VRRootViewController.h
//  SmartMap
//
//  Created by Admin on 17.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VRBookmarkList.h"



@interface VRRootViewController : UIViewController <MKMapViewDelegate, selectedCell> {
    
    NSMutableArray* indexArray;
    NSInteger selectedBookmarkIndex;
    
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *drawRouteButtonOutlet;
- (IBAction)drawRouteButton:(id)sender;


- (IBAction)testButton:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapViewOutlet;
@property (strong, nonatomic) NSMutableArray *bookmarksMutableArray;

@end
