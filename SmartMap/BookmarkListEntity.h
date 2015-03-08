//
//  BookmarkListEntity.h
//  SmartMap
//
//  Created by Admin on 18.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BookmarkListEntity : NSManagedObject

@property (nonatomic, retain) NSString * latitute;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * name;

@end
