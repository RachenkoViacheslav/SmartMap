//
//  VRAppDelegate.h
//  SmartMap
//
//  Created by Admin on 17.02.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end