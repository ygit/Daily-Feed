//
//  Utils.h
//  Daily Feed
//
//  Created by yogesh singh on 01/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import Foundation;

#import "Feed+CoreDataProperties.h"
#import "Hits+CoreDataProperties.h"
#import "ServerHelper.h"
#import "DataParser.h"
#import "DataProvider.h"
#import "AppDelegate.h"

@interface Utils : NSObject

#define APP_ICON [UIImage imageNamed:@"rss"]

#define CELL @"cell"

#define FEED @"Feed"

#define HITS @"Hits"

#define NEWS_FEED @"https://dailyhunt.0x10.info/api/dailyhunt?type=json&query=list_news"

#define API_HITS  @"https://dailyhunt.0x10.info/api/dailyhunt?type=json&query=api_hits"

#define FETCHED_FEEDS_SHOULD_UPDATE_VIEW @"update table"

#define FETCHED_API_HITS_SHOULD_UPDATE_VIEW @"update hits"

#define FETCHED_IMAGE_UPDATE_VIEW @"update image"

#define CUSTOM_BACKGROUNDCOLOR [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0]

#define CUSTOM_LIGHT_BLUE_COLOR [UIColor colorWithRed:72.0/255.0 green:166.0/255.0 blue:222.0/255.0 alpha:1.0]

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define IS_IPHONE_DEVICE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)


+ (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView;

+ (CIContext *)getCIContext;

@end
