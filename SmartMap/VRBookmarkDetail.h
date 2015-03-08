//
//  VRBookmarkDetail.h
//  SmartMap
//
//  Created by Admin on 20.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VRBookmarkDetail : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate> {
    NSMutableArray *dataSourseDictionary;
     NSMutableArray *categoriesArray;
    
    NSString *bookmarkNewName;
    
    NSString* bookmarkLatitude;
    NSString* bookmarkLongitude;
    
    NSString* wikimapiaApiUrlString;
    NSString* foursquareApiUrlString;
    UIBarButtonItem *searchNearbyPlace;
}



@property (strong, nonatomic) NSManagedObject * bookmarkItem;




@end
