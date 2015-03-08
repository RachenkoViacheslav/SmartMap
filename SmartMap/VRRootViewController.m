//
//  VRRootViewController.m
//  SmartMap
//
//  Created by Admin on 17.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import "VRRootViewController.h"
#import "VRAnnotationMap.h"
#import "BookmarkListEntity.h"
#import "VRBookmarkList.h"
#import "VRBookmarkDetail.h"
#import "UIView+MKAnnotationView.h"


@interface VRRootViewController () {
    CLLocation *locationSelf;
    double userLatitute;
    double userLongitude;
    
    double selectBookmarkLatitute;
    double selectBookmarkLongitude;
}

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (strong, nonatomic) UIPopoverController* popover;
@property (strong, nonatomic) MKDirections * directions;

@end

@implementation VRRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self viewAllSavedPin];
    [self longPressGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated {
   
[self.mapViewOutlet removeAnnotations:[self.mapViewOutlet annotations]];
     [self viewAllSavedPin];
    NSLog(@"viewWillAppear");
    //[self longPressGestureRecognizer];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
    
}


#pragma mark - LongPressGestureRecognizer
-(void)longPressGestureRecognizer {
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    
    self.longPressGesture.numberOfTapsRequired = 0;
    
    self.longPressGesture.numberOfTouchesRequired = 1;
    self.longPressGesture.minimumPressDuration = 0.7;
    
    [self.mapViewOutlet addGestureRecognizer:self.longPressGesture];
    
    //selectedBookmarkIndex0;
}
- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{
    if ([sender isEqual:self.longPressGesture]) {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
        
        NSLog(@"longPressGestureRecognizer is OK ");
            [self createBookmark];
        
        }
    }
}

#pragma mark - MKAnnotationView

-(void)createBookmark {
    
    CGPoint touchPoint = [self.longPressGesture locationInView:self.mapViewOutlet];
    CLLocationCoordinate2D location =
    [self.mapViewOutlet convertPoint:touchPoint toCoordinateFromView:self.mapViewOutlet];
    
    NSLog(@"Location found from Map: %f %f",location.latitude,location.longitude);
    NSInteger bookmarksMutableArrayCount = [self.bookmarksMutableArray count];
    VRAnnotationMap *annotation = [[VRAnnotationMap alloc]init];
    annotation.title = @"unnamed";
    annotation.coordinate = location;
    annotation.index = bookmarksMutableArrayCount ;
    NSLog(@"annotation.index = %i", annotation.index);
    userLatitute = location.latitude;
    userLongitude = location.longitude;
     
    [self.mapViewOutlet addAnnotation:annotation];
       [self saveDataToCache];
}
    


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
    static NSString *identifier = @"Annotation";
    MKPinAnnotationView* pin = (MKPinAnnotationView*)[self.mapViewOutlet dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        pin.canShowCallout = YES;
        pin.draggable = NO;
        
        pin.pinColor = MKPinAnnotationColorRed;
        
        
        UIButton *disclosureArrow = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [disclosureArrow addTarget:self action:@selector(actionDisclosureArrow:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = disclosureArrow;
    
    }
    else {
        pin.annotation = annotation;
    }
    
    return pin;
    
}



#pragma mark - actionButton

-(void) actionDisclosureArrow: (UIButton*) sender {
    NSLog(@"actionDisclosureArrow button is WORK!!!!");
        VRAnnotationMap *annt = [[self.mapViewOutlet selectedAnnotations] objectAtIndex:0];
    
   
    selectedBookmarkIndex =   annt.index;
    

    
    
  
    
   [self performSegueWithIdentifier:@"bookmarkDetail" sender:nil];
    
    
}


#pragma mark - segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue");
    
    
    if ([segue.identifier isEqualToString:@"ShowBookmarksList"]) {
        
        VRBookmarkList *bookmarkListController = segue.destinationViewController;
        NSLog(@"Rootview controller bookmarks %@", self.bookmarksMutableArray);
        bookmarkListController.bookmarksArray = self.bookmarksMutableArray;
        bookmarkListController.enableSegue = YES;
        

        
    }
    
    if ([segue.identifier isEqualToString:@"bookmarkDetail"]) {
        
       
       
        NSManagedObject *selectBookmark = [self.bookmarksMutableArray objectAtIndex:selectedBookmarkIndex];
       
 
         VRBookmarkDetail* bookmarkDetailView = segue.destinationViewController;
         
         bookmarkDetailView.bookmarkItem = selectBookmark;

         
        
        
    }
    
    
}

#pragma mark CoreData

-(NSManagedObjectContext*)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication]delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)saveDataToCache {
    
    
    
    
    NSLog(@"saveDataToCache");
    
 
    
    NSManagedObjectContext *context = [self managedObjectContext];

           NSManagedObject *cacheDataManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"BookmarkListEntity" inManagedObjectContext:context];
    NSString *strLatitute = [NSString stringWithFormat:@"%f", userLatitute];
     NSString *strLongitude = [NSString stringWithFormat:@"%f", userLongitude];
    
    [cacheDataManagedObject setValue: @"unnamedPin" forKey:@"name"];
    
    [cacheDataManagedObject setValue:strLatitute forKey:@"latitute"];
    [cacheDataManagedObject setValue:strLongitude forKey:@"longitude"];
    
    [self.bookmarksMutableArray addObject:cacheDataManagedObject];
    NSLog(@"bookmark Array %@", self.bookmarksMutableArray);
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't save %@ %@",error, [error localizedDescription]);
    }

}

- (void)viewAllSavedPin {
    
    
        self.bookmarksMutableArray = [[NSMutableArray alloc]init];
        NSLog(@"bookmarksMutableArray");
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"BookmarkListEntity"];
    
    
        self.bookmarksMutableArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
    
        for (int i=0; i<self.bookmarksMutableArray.count; i++) {
        NSManagedObject *cacheDate = [self.bookmarksMutableArray objectAtIndex:i];
       
        
            NSLog(@"index = %i", i);
            NSLog(@"name = %@", [cacheDate valueForKey:@"name"]);
        userLatitute    = [[cacheDate valueForKey:@"latitute"]floatValue];
        userLongitude   = [[cacheDate valueForKey:@"longitude"]floatValue];
   
        VRAnnotationMap *annotation = [[VRAnnotationMap alloc]init];
            annotation.index = i;
        
        annotation.title    = [cacheDate valueForKey:@"name"];
        //annotation.subtitle = [NSString stringWithFormat:@"%f", userLatitute];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLatitute, userLongitude);
        annotation.coordinate = coordinate;
      
        
            
            
            
        
            [self.mapViewOutlet addAnnotation:annotation];
            [self showPinsOnOneScreen];
    }
    
}

-(void)showPinsOnOneScreen {
    MKMapRect zoomRect = MKMapRectNull;
    
    for (id <MKAnnotation> annotation in self.mapViewOutlet.annotations) {
CLLocationCoordinate2D location = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        
        static double delta = 20000;
        
        MKMapRect rect = MKMapRectMake(center.x, center.y, delta*2, delta*2);
        zoomRect = MKMapRectUnion(zoomRect, rect);
        
    }
    
    zoomRect = [self.mapViewOutlet mapRectThatFits:zoomRect];
    [self.mapViewOutlet setVisibleMapRect:zoomRect
                              edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                                 animated:YES];
}


#pragma mark - draw route

-(void)actionDirection {

    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake
                                (selectBookmarkLatitute,
                                 selectBookmarkLongitude);
    
    
    MKDirectionsRequest* request = [[MKDirectionsRequest alloc]init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    MKPlacemark*placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    
    MKMapItem *destination = [[MKMapItem alloc]initWithPlacemark:placemark];
    request.destination = destination;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    self.directions = [[MKDirections alloc]initWithRequest:request];
    
    
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
         
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            
            
            NSLog(@"error %@", [error localizedDescription]);
        }
        else if ([response.routes count]==0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"round not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        else {
            self.mapViewOutlet.delegate = self;
            [self.mapViewOutlet removeOverlays:[self.mapViewOutlet overlays]];
            [self.mapViewOutlet removeAnnotations:[self.mapViewOutlet annotations]];
            NSMutableArray *array = [NSMutableArray array];
            
            for (MKRoute* route in response.routes) {
                [array addObject:route.polyline];
            }
            VRAnnotationMap *annotation = [[VRAnnotationMap alloc]init];
            annotation.title = @"unnamed";
            annotation.subtitle = @"subtitle";
            annotation.coordinate = coordinate;

            
            
            [self.mapViewOutlet addAnnotation:annotation];
            [self showPinsOnOneScreen];
            [self.mapViewOutlet addOverlays:array level:MKOverlayLevelAboveRoads];
        }
    }];
    
    
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    NSLog(@"rendererForOverlay");
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        
        renderer.lineWidth = 2.f;
        renderer.strokeColor = [UIColor blackColor];
        
        return renderer;
    }
    return  nil;
}



- (IBAction)drawRouteButton:(id)sender {
    
    

    if([self.drawRouteButtonOutlet.title isEqualToString:@"Route"])
    {
        [self.drawRouteButtonOutlet setTitle:@"Clean route"];
        
        VRBookmarkList * bookmarkListController = [self.storyboard instantiateViewControllerWithIdentifier:@"VRBookmarkList"];
        bookmarkListController.bookmarksArray = self.bookmarksMutableArray;
        bookmarkListController.delegatePopop = self;
        
        if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad) {
            
            self.popover = [[UIPopoverController alloc] initWithContentViewController:bookmarkListController];
            
            
            [self.popover presentPopoverFromBarButtonItem:sender         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
            
            bookmarkListController.preferredContentSize = CGSizeMake(500, 750);
        }
        else {
            NSLog(@"iphone");
        }

        
    }
    else
    {
        [self.drawRouteButtonOutlet setTitle:@"Route"];
        [self.mapViewOutlet removeOverlays:[self.mapViewOutlet overlays]];
        [self.mapViewOutlet removeAnnotations:[self.mapViewOutlet annotations]];
        
        [self viewAllSavedPin];

    }
    
  
   
    
}

- (IBAction)testButton:(id)sender {
    
     [self performSegueWithIdentifier:@"ShowBookmarksList" sender:nil];
    
    //[self actionDirection];
}

-(void)selectedBookmarkCoordinateLatitute:(NSString *)latitute andLongitude:(NSString *)longitude {
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
    
    selectBookmarkLatitute = [latitute floatValue];
    selectBookmarkLongitude= [longitude floatValue];
    NSLog(@"\n---------\n selectBookmarkLatitute = %f\n selectBookmarkLongitude  %f", selectBookmarkLatitute, selectBookmarkLongitude);
    [self actionDirection];
}
@end
