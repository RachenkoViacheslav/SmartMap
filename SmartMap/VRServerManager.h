//
//  VRServerManager.h
//  SmartMap
//
//  Created by Admin on 17.04.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRServerManager : NSObject



+(VRServerManager*) sharedManager;

-(void)getNearbyPlaceUsedFoursquareAPIFromURL:(NSString*)urlString
                                    onSuccess:(void(^)(NSArray* nearbyPlaceArray))success
                                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void)getNearbyPlaceUsedWikimapiaAPIFromURL:(NSString*)urlString
                                    onSuccess:(void(^)(NSArray* nearbyPlaceArray))success
                                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;
@end
