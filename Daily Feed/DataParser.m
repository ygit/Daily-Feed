//
//  DataParser.m
//  Daily Feed
//
//  Created by yogesh singh on 01/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import "DataParser.h"
#import "Utils.h"

@implementation DataParser

+ (void)setFeed:(Feed *)feed fromArticle:(NSDictionary *)article{
    
    [feed    setSource      :[article valueForKey:@"source"  ]];
    [feed    setCategory    :[article valueForKey:@"category"]];
    [feed    setContent     :[article valueForKey:@"content" ]];
    [feed    setImgUrl      :[article valueForKey:@"image"   ]];  //multiple image URLs in API do not return images
    [feed    setUrl         :[article valueForKey:@"url"     ]];
}

+ (void)parseFeedsInResponse:(id)response{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSArray *articles = [response valueForKey:@"articles"];
    
    //    NSInteger i = 0;
    
    for (NSDictionary *feed in articles) {
        
        NSString *feedTitle = [feed valueForKey:@"title"];
        
        //        NSLog(@"parsing service %ld of %lu", (long)++i, (unsigned long)providers.count);
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:FEED];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", feedTitle];
        
        [request setPredicate:predicate];
        
        NSError *fetchErr = nil;
        
        NSArray *fetchedFeeds = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
        
        if (fetchErr) {
            NSLog(@"DataParser parseFeedsInResponse fetch error : %@", fetchErr.localizedDescription);
        }
        
        if (fetchedFeeds.count == 0) {   //create a new feed
            
            Feed *newFeed = [NSEntityDescription insertNewObjectForEntityForName:FEED
                                                          inManagedObjectContext:appDelegate.managedObjectContext];
            
            [newFeed setTitle:feedTitle];
            
            [DataParser setFeed:newFeed fromArticle:feed];
            [newFeed    setBookmark:[NSNumber numberWithBool:NO]];
            
        }
        else if (fetchedFeeds.count == 1){   //update existing feed
            
            Feed *existingFeed = [fetchedFeeds firstObject];
            
            [DataParser setFeed:existingFeed fromArticle:feed];
            
        }
        else{
            NSLog(@"Duplicate feeds found on name key, will ignore for now");
        }
    }
    
    if ([appDelegate.managedObjectContext hasChanges]) {
        
        NSError *saveErr = nil;
        if([appDelegate.managedObjectContext save:&saveErr]){
            [[NSNotificationCenter defaultCenter] postNotificationName:FETCHED_FEEDS_SHOULD_UPDATE_VIEW object:nil];
        }
        else{
            NSLog(@"DataParser parseFeedsInResponse save error : %@", saveErr.localizedDescription);
        }
    }
}

+ (void)parseHitsInResponse:(id)response{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:HITS];
    
    NSError *fetchErr = nil;
    
    NSArray *fetchedHits = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr) {
        NSLog(@"DataParser parseHitsInResponse fetch error : %@", fetchErr.localizedDescription);
    }
    
    if (fetchedHits.count == 0) {
        
        Hits *newHit = [NSEntityDescription insertNewObjectForEntityForName:HITS
                                                     inManagedObjectContext:appDelegate.managedObjectContext];
        
        newHit.hits = [response valueForKey:@"api_hits"];
    }
    else{
        
        Hits *hit = [fetchedHits firstObject];
        hit.hits = [response valueForKey:@"api_hits"];
    }
    
    if ([appDelegate.managedObjectContext hasChanges]) {
        
        NSError *saveErr = nil;
        if([appDelegate.managedObjectContext save:&saveErr]){
            [[NSNotificationCenter defaultCenter] postNotificationName:FETCHED_API_HITS_SHOULD_UPDATE_VIEW object:nil];
        }
        else{
            NSLog(@"DataParser parseHitsInResponse save error : %@", saveErr.localizedDescription);
        }
    }
}

+ (void)setFeed:(Feed *)feed BookmarkOption:(BOOL)option{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [feed setBookmark:[NSNumber numberWithBool:option]];
    
    if ([appDelegate.managedObjectContext hasChanges]) {
        
        NSError *saveErr = nil;
        if(![appDelegate.managedObjectContext save:&saveErr]){
            NSLog(@"DataParser setFeed:BookmarkOption: save error : %@", saveErr.localizedDescription);
        }
    }
}

@end
