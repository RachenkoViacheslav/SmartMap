//
//  VRBookmarkList.h
//  SmartMap
//
//  Created by Admin on 18.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol selectedCell <NSObject>
-(void)selectedBookmarkCoordinateLatitute:(NSString*)latitute andLongitude:(NSString*)longitude;

@end

@interface VRBookmarkList : UITableViewController {
    NSString *selectedIndexPathStr;
}
- (IBAction)chackEditModeButton:(id)sender;

@property (assign, nonatomic)BOOL enableSegue;

@property(weak, nonatomic)id <selectedCell> delegatePopop;

@property (strong, nonatomic) NSMutableArray *bookmarksArray;

@end
