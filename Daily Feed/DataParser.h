//
//  DataParser.h
//  Daily Feed
//
//  Created by yogesh singh on 01/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import Foundation;
@class Feed;

@interface DataParser : NSObject

+ (void)parseFeedsInResponse:(id)response;

+ (void)parseHitsInResponse:(id)response;

+ (void)setFeed:(Feed *)feed BookmarkOption:(BOOL)option;

@end
