//
//  DataProvider.h
//  Daily Feed
//
//  Created by yogesh singh on 01/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import Foundation;

@interface DataProvider : NSObject

+ (NSString*)getApiHits;

+ (NSArray *)getCategories;

+ (NSArray *)getFeedsForCategory:(NSString *)category BySearchText:(NSString *)text;

+ (NSArray *)getBookmarksForCategory:(NSString *)category BySearchText:(NSString *)text;

@end
