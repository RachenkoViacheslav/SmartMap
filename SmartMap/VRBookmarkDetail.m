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

/*



 */

- (void)viewDidLoad {
  [super viewDidLoad];

    self.navigationItem.title = [self.bookmarkItem valueForKey:@"name"];
    
  dataSourseDictionary = [[NSMutableArray alloc] init];
  categoriesArray = [[NSMutableArray alloc] init];
    
  
     

  NSString *bookmarkName = [self.bookmarkItem valueForKey:@"name"];

  bookmarkLatitude = [self.bookmarkItem valueForKey:@"latitute"];
  bookmarkLongitude = [self.bookmarkItem valueForKey:@"longitude"];

  NSLog(@"bookmarkName = %@", bookmarkName);
  NSLog(@"bookmarkLatitude = %f", [bookmarkLatitude floatValue]);
  NSLog(@"bookmarkLongitude = %@", bookmarkLongitude);

  wikimapiaApiUrlString = [NSString
      stringWithFormat:@"http://api.wikimapia.org/"
                       @"?key=6FA30F2B-219E0764-EDA414C6-C3B4CC23-6C38B0A6-"
                       @"F44C0548-660BAD77-A74810CA&function=place.search&lat="
                       @"%f&lon=%f&format=json&language=ua&data_blocks=main,"
                       @"location&page=&count=100&distance=1000",
                       [bookmarkLatitude floatValue],
                       [bookmarkLongitude floatValue]];

  foursquareApiUrlString =
      [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/"
                                 @"search?ll=%f,%f&client_id="
                                 @"1AJY13TTJRL1SNDUEDAR3LPEUAY2SJEHPIAR53VVKXN"
                                 @"4W4NY&client_secret="
                                 @"DTMO0DCZWV3I3ILWGTMUAUPBNFAVWWA3Q4PJE0ZIAVB"
                                 @"TJNHP&v=20150101",
                                 [bookmarkLatitude floatValue],
                                 [bookmarkLongitude floatValue]];

  if ([bookmarkName isEqualToString:@"unnamedPin"]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self createRequest:foursquareApiUrlString];
    });
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
    
  UIActionSheet *requestSelector = [[UIActionSheet alloc]
               initWithTitle:nil
                    delegate:self
           cancelButtonTitle:nil
      destructiveButtonTitle:@"Cancel"
           otherButtonTitles:@"Foursquare", @"Wikimapia.org", nil];

  [requestSelector showInView:self.view];
   
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
    cell.detailTextLabel.text = categoriesArray[indexPath.row];
    //  [self.tableView reloadData];
    // Configure the cell...
  }
  return cell;
}

- (void)createRequest:(NSString *)apiStringURL {
   
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  NSURL *url = [NSURL URLWithString:apiStringURL];

  NSURLSessionConfiguration *config =
      [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

  NSURLSessionDataTask *dataTask = [session
      dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response,
                            NSError *error) {

          if (!response) {
            NSLog(@"\n------------\nerror = %@", [error localizedDescription]);
            [UIApplication sharedApplication].networkActivityIndicatorVisible =
                NO;
            dispatch_sync(dispatch_get_main_queue(), ^{

              UIAlertView *alertError = [[UIAlertView alloc]
                      initWithTitle:@"Error"
                            message:[error localizedDescription]
                           delegate:self
                  cancelButtonTitle:@"Cansel"
                  otherButtonTitles:@"Repeat", nil];

              [alertError show];

            });

          } else {
            [self processResponseUsingData:data];
            NSLog(@"resposne type %@", response.MIMEType);
            // NSLog(@"response list %@", data);
          }
          //   [self processResponseUsingData:data];
        }];

  [dataTask resume];
}

- (void)processResponseUsingData:(NSData *)data {
  NSError *parseJsonError = nil;
  NSLog(@"processResponseUsingData");
  NSDictionary *jsonDict =
      [NSJSONSerialization JSONObjectWithData:data
                                      options:NSJSONReadingMutableContainers
                                        error:&parseJsonError];

  if (!parseJsonError) {

    NSArray *responseKey = [jsonDict allKeys];

    if ([responseKey containsObject:@"places"]) {
      dispatch_async(
          dispatch_get_main_queue(), ^{

            NSArray *placesDictionary = [jsonDict objectForKey:@"places"];
            NSLog(@"placesDictionary count = %i", [placesDictionary count]);
            NSInteger placesDictionaryCount = [placesDictionary count];

            if (placesDictionaryCount == 0) {
             
             
              [self showAllertWithTitle:@"Not found"
                             andMessage:@"В базе wikimapia.org  нету "
                                        @"информации об этом месте."
                    andOtherButtonTitle:@"showPlaceInfo"];

            } else {
              for (int i = 0; i < placesDictionaryCount; i++) {
                  [dataSourseDictionary removeAllObjects];
                  [categoriesArray removeAllObjects];
                  
                NSDictionary *objectDict = placesDictionary[i];
                NSArray *tags = objectDict[@"tags"];
                NSDictionary *categoryDict = tags[0];
                if (objectDict[@"title"] != nil) {
                  NSString *titleString = objectDict[@"title"];
                  NSLog(@"title[%i] = %@", i, titleString);
                  [dataSourseDictionary addObject:titleString];
                }

                NSString *categoryString = categoryDict[@"title"];

                [categoriesArray addObject:categoryString];
              }
              [self.tableView reloadData];
            }
          });
    }

    else if ([responseKey containsObject:@"response"]) {

      dispatch_async(dispatch_get_main_queue(),
                     ^{

                       NSDictionary *responseDictionary =
                           [jsonDict objectForKey:@"response"];

                       NSInteger responseDataCount =
                           [responseDictionary[@"venues"] count];
                       if (responseDataCount == 0) {

                         [self showAllertWithTitle:@"Not found"
                                        andMessage:
                                            @"В базе forsquare нету "
                                            @"информации об этом месте. "
                                            @"Попытаться найти информацию об "
                                            @"этом месте используя сервис "
                                            @"wikimapia.org?"
                               andOtherButtonTitle:@"Use wikimapia"];

                       }

                       else {
                           [dataSourseDictionary removeAllObjects];
                           [categoriesArray removeAllObjects];
                           
                         for (int index = 0; index < responseDataCount;
                              index++) {
                           NSDictionary *dict =
                               responseDictionary[@"venues"][index];
                           NSDictionary *locationDict = dict[@"location"];

                           NSLog(@"index = %i", index);
                           NSLog(@"lat = %@, lng = %@", locationDict[@"lat"],
                                 locationDict[@"lng"]);

                           NSString *string =
                               [NSString stringWithFormat:@"lat = %@, lng = %@",
                                                          locationDict[@"lat"],
                                                          locationDict[@"lng"]];

                           [dataSourseDictionary addObject:dict[@"name"]];

                           [categoriesArray addObject:string];
                         }
                         [self.tableView reloadData];
                       }
                     });
    }
  }
}

#pragma mark - Alert

- (void)showAllertWithTitle:(NSString *)title
                 andMessage:(NSString *)message
        andOtherButtonTitle:(NSString *)otherButtonTitle {
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
    [self createRequest:wikimapiaApiUrlString];
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
      
    [self createRequest:foursquareApiUrlString];
  } else if ([[actionSheet buttonTitleAtIndex:buttonIndex]
                 isEqualToString:@"Wikimapia.org"]) {
      
      searchNearbyPlace.enabled = NO;
      
      searchNearbyPlace.width = 0.0f;
      searchNearbyPlace.tintColor = [UIColor clearColor];
      searchNearbyPlace = nil;
      
    [self createRequest:wikimapiaApiUrlString];
  }
}

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

- (void)getPlaceInfoWithGeocoder {

  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
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
              [self.tableView reloadData];

            }

  ];
}
@end
