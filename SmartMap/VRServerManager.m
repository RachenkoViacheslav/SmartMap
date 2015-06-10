//
//  VRServerManager.m
//  SmartMap
//
//  Created by Admin on 17.04.15.
//  Copyright (c) 2015 Rachenko Viacheslav. All rights reserved.
//

#import "VRServerManager.h"
#import <AFNetworking.h>

@interface VRServerManager ()
@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;
@end

@implementation VRServerManager

- (id)init
{
    self = [super init];
    if (!self.requestOperationManager) {
        
        NSURL* url = [NSURL URLWithString:@"https://"];
        
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}


+(VRServerManager*) sharedManager {
    static VRServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[VRServerManager alloc]init];
    });
    
    return manager;
}


#pragma mark - requestsMethods

-(void)getNearbyPlaceUsedFoursquareAPIFromURL:(NSString*)urlString
                                    onSuccess:(void(^)(NSArray* nearbyPlaceArray))success
                                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    [self.requestOperationManager
     GET:urlString parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
         
         
         NSDictionary *responseDictionary = [responseObject objectForKey:@"response"];
         NSInteger responseDataCount = [responseDictionary[@"venues"] count];
         NSLog(@"responseDataCount = %i", responseDataCount );
         NSMutableArray *nearbyPlaceNameArray = [NSMutableArray array];
         
         if (responseDataCount !=0) {
             
             for (int i =0; i<responseDataCount; i++) {
                 NSDictionary *dict = responseDictionary[@"venues"][i];
                 NSDictionary *locationDict = dict[@"location"];
                 
                 NSLog(@"index = %i", i);
                 NSLog(@"lat = %@, lng = %@", locationDict[@"lat"],
                       locationDict[@"lng"]);
                 NSString *nearbyPlaceName = [NSString stringWithFormat:@"%@", dict[@"name"]];
                 [nearbyPlaceNameArray addObject:nearbyPlaceName];
//                 NSString *string = [NSString stringWithFormat:@"lat = %@, lng = %@",
//                  locationDict[@"lat"],
//                  locationDict[@"lng"]];
//                 
//                 NSLog(@"string = %@", string );
                 
                 NSLog(@"dict ""Name"" = %@", dict[@"name"] );
                 if (success) {
                     success(nearbyPlaceNameArray);
                 }
                 
             }
         }
         else {
             NSLog(@"Not found !!!! " );
             
             if (success) {
                 success(nearbyPlaceNameArray);
             }
         }
         
         
         
       // NSLog(@"responseObject = %@", responseObject );
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(nil, operation.response.statusCode);
    }];
    
                            
}

-(void)getNearbyPlaceUsedWikimapiaAPIFromURL:(NSString*)urlString
                                    onSuccess:(void(^)(NSArray* nearbyPlaceArray))success
                                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    NSLog(@"wikimapia Used " );
    [self.requestOperationManager
     GET:urlString parameters:nil
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"responseObject = %@", responseObject );
         NSMutableArray *nearbyPlaceArray = [NSMutableArray array];
         
         
         NSArray *placesArray = [responseObject objectForKey:@"places"];
         if (placesArray.count!=0) {
             
             
             for (int i = 0; i < placesArray.count; i++) {
                
                 
                 NSDictionary *objectDict = placesArray[i];
                 NSArray *tags = objectDict[@"tags"];
                 NSDictionary *categoryDict = tags[0];
                 NSLog(@"categoryDict %i = %@",i, categoryDict );
                 if (objectDict[@"title"] != nil) {
                     NSString *titleString = objectDict[@"title"];
                     [nearbyPlaceArray addObject:titleString];
                 } }
         
             success (nearbyPlaceArray);
         }
         else {
             success (nearbyPlaceArray);
         }
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"error description = %@", error.description );
         failure(nil, operation.response.statusCode);
         NSLog(@"fefe = %@", operation.response. description );
     }];
    
    
}


@end
