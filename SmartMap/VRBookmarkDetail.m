//
//  VRBookmarkDetail.m
//  SmartMap
//
//  Created by Admin on 20.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import "VRBookmarkDetail.h"
#import "VRAppDelegate.h"
#import <MapKit/MapKit.h>
#import "VRServerManager.h"
#import <MBProgressHUD.h>


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface VRBookmarkDetail ()

@end

@implementation VRBookmarkDetail

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}



- (NSManagedObjectContext *)managedObjectContext {
  NSManagedObjectContext *context = nil;
  id delegate = [[UIApplication sharedApplication] delegate];

  if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
  }
  return context;
}


- (void)viewDidLoad {
  [super viewDidLoad];

    self.navigationItem.title = [self.bookmarkItem valueForKey:@"name"];
    
  dataSourseDictionary = [[NSMutableArray alloc] init];
  categoriesArray = [[NSMutableArray alloc] init];
    
  
     

  NSString *bookmarkName = [self.bookmarkItem valueForKey:@"name"];

  

  if ([bookmarkName isEqualToString:@"unnamedPin"]) {

      
      [self createRequest:@"foursquare"];
 
  }
    
  [dataSourseDictionary addObject:[self.bookmarkItem valueForKey:@"name" ]];
    NSString *latitude = [self.bookmarkItem valueForKey:@"latitute" ];
    NSString *longitude = [self.bookmarkItem valueForKey:@"longitude" ];
    NSString *categoryString = [NSString stringWithFormat:@"lat=%f, lon=%f", [latitude floatValue], [longitude floatValue]];
    
    [categoriesArray addObject:categoryString];
    [self.tableView reloadData];
  searchNearbyPlace = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                           target:self
                           action:@selector(startingRequest)];

  UIBarButtonItem *trashButton = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                           target:self
                           action:@selector(trashButton)];

  self.navigationItem.rightBarButtonItems = @[ trashButton, searchNearbyPlace ];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
}

- (void)startingRequest {

    [dataSourseDictionary removeAllObjects];
    [categoriesArray removeAllObjects];
    
    if(IS_OS_8_OR_LATER) {
        
        
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:nil
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* foursquare = [UIAlertAction
                             actionWithTitle:@"foursquare"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 searchNearbyPlace.enabled = NO;
                                 
                                 searchNearbyPlace.width = 0.0f;
                                 searchNearbyPlace.tintColor = [UIColor clearColor];
                                 searchNearbyPlace = nil;
                                 
                                 [self createRequest:@"foursquare"];
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* wikimapia = [UIAlertAction
                                 actionWithTitle:@"Wikimapia.org"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     searchNearbyPlace.enabled = NO;
                                     
                                     searchNearbyPlace.width = 0.0f;
                                     searchNearbyPlace.tintColor = [UIColor clearColor];
                                     searchNearbyPlace = nil;
                                     
                                     [self createRequest:@"wikimapia"];
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        
        [alertController addAction:foursquare];
        [alertController addAction:wikimapia];
        
        if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad) {
            [alertController.popoverPresentationController setPermittedArrowDirections:0];
            NSLog(@"UIUserInterfaceIdiomPad" );
            
            
            //For set action sheet to middle of view.
            CGRect rect = self.view.frame;
            rect.origin.x = self.view.frame.size.width / 20;
            rect.origin.y = self.view.frame.size.height / 20;
            alertController.popoverPresentationController.sourceView = self.view;
            alertController.popoverPresentationController.sourceRect = rect;
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        else {
        [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    else {
        UIActionSheet *requestSelector = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:nil
                                          destructiveButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Foursquare", @"Wikimapia.org", nil];
        
        [requestSelector showInView:self.view];
    }

   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  

  NSInteger count = [dataSourseDictionary count];

  if (count == 0) {
    return 1;
  } else {
    // NSLog(@"feeds count = %i", [dataSourseDictionary count]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return [dataSourseDictionary count];
  }
}
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

 
  bookmarkNewName = cell.textLabel.text;
  [self renameBookMark];
    
self.navigationItem.title = bookmarkNewName;
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                      forIndexPath:indexPath];

  NSUInteger feedsCount = dataSourseDictionary.count;
  if (feedsCount == 0 && indexPath.row == 0) {

    cell.textLabel.text = @"Loading...";

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;

    //  cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;

  }

  else {
    cell.userInteractionEnabled = YES;
    cell.textLabel.text = dataSourseDictionary[indexPath.row];

  }
  return cell;
}

#pragma mark - NetWork

- (void)createRequest:(NSString *)apiStringURL {
    bookmarkLatitude = [self.bookmarkItem valueForKey:@"latitute"];
    bookmarkLongitude = [self.bookmarkItem valueForKey:@"longitude"];

    if ([apiStringURL isEqualToString:@"foursquare"]) {
        
        
        foursquareApiUrlString =
        [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/"
         @"search?ll=%f,%f&client_id="
         @"1AJY13TTJRL1SNDUEDAR3LPEUAY2SJEHPIAR53VVKXN"
         @"4W4NY&client_secret="
         @"DTMO0DCZWV3I3ILWGTMUAUPBNFAVWWA3Q4PJE0ZIAVB"
         @"TJNHP&v=20150101",
         [bookmarkLatitude floatValue],
         [bookmarkLongitude floatValue]];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        
        MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
        
        
        
        [[VRServerManager sharedManager]getNearbyPlaceUsedFoursquareAPIFromURL:foursquareApiUrlString onSuccess:^(NSArray *nearbyPlaceNameArray) {
            
            [dataSourseDictionary removeAllObjects];
            [dataSourseDictionary addObjectsFromArray:nearbyPlaceNameArray];
            [hud hide:YES];
            if (dataSourseDictionary.count==0) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Title"
                                                                   message:@"message"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Close"
                                                         otherButtonTitles:@"Use wikimapia", nil];
                
                [alertView show];
            }
            [self.tableView reloadData];
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"error code %i", statusCode );
        }];

    }
    
    else if ([apiStringURL isEqualToString:@"wikimapia"])
    {
    
        MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
        
    wikimapiaApiUrlString = [NSString
                             stringWithFormat:@"http://api.wikimapia.org/"
                             @"?key=6FA30F2B-219E0764-EDA414C6-C3B4CC23-6C38B0A6-"
                             @"F44C0548-660BAD77-A74810CA&function=place.search&lat="
                             @"%f&lon=%f&format=json&language=ua&data_blocks=main,"
                             @"location&page=&count=100&distance=1000",
                             [bookmarkLatitude floatValue],
                             [bookmarkLongitude floatValue]];
    
    
    [[VRServerManager sharedManager]getNearbyPlaceUsedWikimapiaAPIFromURL:wikimapiaApiUrlString
                                                                onSuccess:^(NSArray *nearbyPlaceNameArray) {
        [dataSourseDictionary removeAllObjects];
            [hud hide:YES];
    if (nearbyPlaceNameArray.count==0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Wikimapia"
                                                           message:@"notFound"
                                                          delegate:self
                                                 cancelButtonTitle:@"showPlaceInfo"
                                                 otherButtonTitles:@"OK", nil];
        
        [alertView show];
                                                                    }
                                                                    
        [dataSourseDictionary addObjectsFromArray:nearbyPlaceNameArray];
                                                                    
                                                                  
                                                                    
        [self.tableView reloadData];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error code %i", statusCode );
        NSLog(@"error description = %@", error.description );
    }];
    }
    
  

}


- (void)getPlaceInfoWithGeocoder {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    [dataSourseDictionary removeAllObjects];
    [categoriesArray removeAllObjects];
    
    CLGeocoder *ceo = [[CLGeocoder alloc] init];
    
    CLLocation *loc =
    [[CLLocation alloc] initWithLatitude:[bookmarkLatitude floatValue]
                               longitude:[bookmarkLongitude floatValue]];
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  NSLog(@"placemark %@", placemark);
                  // String to hold address
                  NSString *locatedAt = [[placemark.addressDictionary
                                          valueForKey:@"FormattedAddressLines"]
                                         componentsJoinedByString:@", "];
                  NSLog(@"addressDictionary %@", placemark.addressDictionary);
                  NSLog(@"addressDictionary %@", locatedAt);
                  
                  NSString *titleStr =
                  [NSString stringWithFormat:@"%@  ", locatedAt];
                  [dataSourseDictionary addObject:titleStr];
                  [categoriesArray addObject:[placemark.addressDictionary
                                              valueForKey:@"Country"]];
                  [UIApplication sharedApplication]
                  .networkActivityIndicatorVisible = NO;
                  [hud hide:YES];
                  [self.tableView reloadData];
                  
              }
     
     ];
}


#pragma mark - Alert






- (void)showAllertWithTitle:(NSString *)title
                 andMessage:(NSString *)message
        andOtherButtonTitle:(NSString *)otherButtonTitle {
    
    if(IS_OS_8_OR_LATER) {
    
    
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:otherButtonTitle
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 
                                 if ([action.title isEqualToString:@"Use wikimapia"]) {
                                     [self createRequest:@"wikimapia"];
                                 } else if ([action.title
                                             isEqualToString:@"Repeat"]) {
                                     [self createRequest:foursquareApiUrlString];
                                 } else if ([action.title
                                             isEqualToString:@"showPlaceInfo"]) {
                                     [self getPlaceInfoWithGeocoder];
                                 } else if ([action.title
                                             isEqualToString:@"Закрыть"]) {
                                     [self.navigationController popToRootViewControllerAnimated:YES];
                                 }

                                 
                                 
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alertController addAction:ok];
        [alertController addAction:cancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
    
    }
    
  UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:title
                                 message:message
                                delegate:self
                       cancelButtonTitle:@"NO"
                       otherButtonTitles:otherButtonTitle, nil];

  [alert show];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Use wikimapia"]) {
    [self createRequest:@"wikimapia"];
  } else if ([[alertView buttonTitleAtIndex:buttonIndex]
                 isEqualToString:@"Repeat"]) {
    [self createRequest:foursquareApiUrlString];
  } else if ([[alertView buttonTitleAtIndex:buttonIndex]
                 isEqualToString:@"showPlaceInfo"]) {
    [self getPlaceInfoWithGeocoder];
  } else if ([[alertView buttonTitleAtIndex:buttonIndex]
                 isEqualToString:@"Закрыть"]) {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
    
  else if ([[alertView buttonTitleAtIndex:buttonIndex]
            isEqualToString:@"NO"]) {
      
      [UIApplication sharedApplication].networkActivityIndicatorVisible =
      NO;
    
  }

}
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {

  if ([[actionSheet buttonTitleAtIndex:buttonIndex]
          isEqualToString:@"Foursquare"]) {
      
      searchNearbyPlace.enabled = NO;
      
      searchNearbyPlace.width = 0.0f;
      searchNearbyPlace.tintColor = [UIColor clearColor];
      searchNearbyPlace = nil;
      
    [self createRequest:@"foursquare"];
      
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex]
                 isEqualToString:@"Wikimapia.org"]) {
      
      searchNearbyPlace.enabled = NO;
      
      searchNearbyPlace.width = 0.0f;
      searchNearbyPlace.tintColor = [UIColor clearColor];
      searchNearbyPlace = nil;
      
    [self createRequest:@"wikimapia"];
  }
}


#pragma mark - Action

- (void)renameBookMark {

  VRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

  NSManagedObjectContext *context = [appDelegate managedObjectContext];

  [self.bookmarkItem setValue:bookmarkNewName forKey:@"name"];

  NSError *error = nil;
  if (![context save:&error]) {
  }
}

- (void)trashButton {

  NSManagedObjectContext *context = [self managedObjectContext];
  NSLog(@"self.walkArray = %@", self.bookmarkItem);
  [context deleteObject:self.bookmarkItem];

  NSError *error = nil;
  if (![context save:&error]) {

    
    [self showAllertWithTitle:@"error"
                   andMessage:[error localizedDescription]
          andOtherButtonTitle:nil];
    
  }

    UIAlertView *infoDeleteBookmark = [[UIAlertView alloc]
                                       initWithTitle:nil
                                       message:@"Метка успешно удалена"
                                       delegate:self
                                       cancelButtonTitle:@"Закрыть"
                                       otherButtonTitles:nil, nil];
    [infoDeleteBookmark show];

}


@end
