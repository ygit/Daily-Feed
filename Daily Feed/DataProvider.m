//
//  DataProvider.m
//  Daily Feed
//
//  Created by yogesh singh on 01/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import "DataProvider.h"
#import "Utils.h"

@implementation DataProvider

+ (NSString *)getApiHits{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:HITS];
    
    NSError *fetchErr = nil;
    
    NSArray *fetchedHits = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr) {
        NSLog(@"DataProvider getApiHits fetchErr : %@", fetchErr.localizedDescription);
    }
    
    if (fetchedHits.count > 0) {
        Hits *hit = [fetchedHits firstObject];
        return hit.hits;
    }
    else return @"";
}

+ (NSArray *)getCategories{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:FEED];
    
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"category", nil]];
    [request setReturnsDistinctResults:YES];
    
    NSError *fetchErr = nil;
    NSArray *fetchedResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr) {
        NSLog(@"DataProvider getCategories fetchErr : %@", fetchErr.localizedDescription);
    }
    
    return fetchedResults;
}

+ (NSArray *)getFeedsFilteredByCategory:(NSString *)category{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:FEED];
    
    if (![category isEqualToString:@"None"]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category ==[cd] %@",category];
        [request setPredicate:predicate];
    }
    
    NSError *fetchErr = nil;
    NSArray *fetchedResults = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr) {
        NSLog(@"DataProvider getFeedsFilteredByCategory fetchErr : %@", fetchErr.localizedDescription);
    }
    
    return fetchedResults;
}

+ (NSArray *)getFeedsForCategory:(NSString *)category BySearchText:(NSString *)text{
    
    NSArray *filteredArray = [DataProvider getFeedsFilteredByCategory:category];
    
    if (![text isEqualToString:@""]) {
        
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", text];
        NSPredicate *sourcePredicate = [NSPredicate predicateWithFormat:@"source contains[cd] %@", text];
        
        NSCompoundPredicate *compoundPred = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                                               namePredicate, sourcePredicate, nil]];
        
        filteredArray = [filteredArray filteredArrayUsingPredicate:compoundPred];
    }

    return filteredArray;
}

+ (NSArray *)getBookmarksForCategory:(NSString *)category BySearchText:(NSString *)text{
  
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:FEED];
    
    //get all bookmarks
    NSPredicate *bookmarkPred = [NSPredicate predicateWithFormat:@"bookmark ==[cd] %@",[NSNumber numberWithBool:YES]];
    [request setPredicate:bookmarkPred];
    
    NSError *fetchErr = nil;
    NSArray *bookmarks = [appDelegate.managedObjectContext executeFetchRequest:request error:&fetchErr];
    
    if (fetchErr) {
        NSLog(@"DataProvider getBookmarksForCategory:BySearchText: fetchErr : %@", fetchErr.localizedDescription);
    }
    
    NSArray *bookmarksFilteredByCategory;
    
    //filter by category
    if ([category isEqualToString:@"None"]) {
        bookmarksFilteredByCategory = bookmarks;
    }
    else{
        NSPredicate *categoryPred = [NSPredicate predicateWithFormat:@"category ==[cd] %@",category];
        bookmarksFilteredByCategory = [bookmarks filteredArrayUsingPredicate:categoryPred];
    }
    
    NSArray *finalFilteredBySearchText;
    //filter by search text
    if ([text isEqualToString:@""]) {
        finalFilteredBySearchText = bookmarksFilteredByCategory;
    }
    else{
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", text];
        NSPredicate *sourcePredicate = [NSPredicate predicateWithFormat:@"source contains[cd] %@", text];
        
        NSCompoundPredicate *compoundPred = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                                               namePredicate, sourcePredicate, nil]];
        finalFilteredBySearchText = [bookmarksFilteredByCategory filteredArrayUsingPredicate:compoundPred];
    }
    
    return finalFilteredBySearchText;
}

@end
