//
//  FeedDetailVC.h
//  Daily Feed
//
//  Created by yogesh singh on 01/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import UIKit;
@class Feed;

@interface FeedDetailVC : UIViewController

@property (strong, nonatomic) Feed *feed;
@property (strong, nonatomic) NSArray *dataArr;

@end
