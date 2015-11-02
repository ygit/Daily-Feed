//
//  HomeTableViewCell.h
//  Daily Feed
//
//  Created by yogesh singh on 31/10/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import UIKit;
#import "MarqueeLabel.h"

@interface HomeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet MarqueeLabel *title;


@end
