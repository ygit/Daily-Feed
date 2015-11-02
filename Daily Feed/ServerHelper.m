//
//  ServerHelper.m
//  Daily Feed
//
//  Created by yogesh singh on 01/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ServerHelper.h"
#import "Utils.h"

@implementation ServerHelper

+ (void)fetchFeeds{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [manager GET:NEWS_FEED parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
            //NSLog(@"fetchFeeds responseObject : %@", responseObject);

            [DataParser parseFeedsInResponse:responseObject];

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"ServerHelper fetchFeeds error : %@", error.localizedDescription);

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         }];
}

+ (void)fetchHits{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [manager GET:API_HITS parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             //NSLog(@"fetchHits responseObject : %@", responseObject);
             
             [DataParser parseHitsInResponse:responseObject];
             
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"ServerHelper fetchHits error : %@", error.localizedDescription);
             
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         }];
}

@end
