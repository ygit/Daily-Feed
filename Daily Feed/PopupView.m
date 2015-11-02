//
//  PopupView.m
//  Daily Feed
//
//  Created by yogesh singh on 31/10/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import "PopupView.h"
#import "MarqueeLabel.h"
#import "Utils.h"

@interface PopupView() <UITableViewDataSource, UITableViewDelegate> {
    AppDelegate *appDelegate;
    NSMutableArray *resetDict;
    CGFloat heightOfRow;
}

@end

@implementation PopupView
@synthesize isHidden,cellBackgroundColor,currentOption, isEmpty;


#pragma mark - Lifecycle

- (id) initWithTitleString:(NSString*)titleString andOptions:(NSArray*)options withSelectedIndex:(NSInteger)indexSelected delegate:(id)delegate{

    self = [super init];
    if (self) {
        
        _titleString    = titleString;
        _delegate       = delegate;
        _dataSource     = options;
        _indexOfSelectedValue = indexSelected;
        cellBackgroundColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0];

        appDelegate = [[UIApplication sharedApplication] delegate];

        //Self
        self.backgroundColor = [CUSTOM_BACKGROUNDCOLOR colorWithAlphaComponent:0.7];

        //Table
        _table = [[UITableView alloc] init];
        _table.dataSource = self;
        _table.delegate = self;
        _table.tableFooterView = [[UIView alloc]init];
        _table.layer.borderColor = [self getAverageColor].CGColor;
        _table.layer.borderWidth = 2;
        _table.backgroundColor = cellBackgroundColor;
        _table.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        
        if([_table respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]){
            _table.cellLayoutMarginsFollowReadableWidth = NO;
        }
        
        UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                                         action:@selector(buttonLongPressed:)];
        [_table addGestureRecognizer:longPressRecognizer];
        
        //Tap to dismiss
        UITapGestureRecognizer* tapToDismiss = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideOptionsPopup)];
        _tapToDismiss = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 1024)];
        [_tapToDismiss addGestureRecognizer:tapToDismiss];
        
        //Adding Subviews
        [self addSubview:_tapToDismiss];
        [self addSubview:_table];
    }
    return self;
}

- (void)showOptionsPopupWithCenter:(CGPoint)center andSize:(CGSize)size{
    
    resetDict = [NSMutableArray array];
    //Setup frames
    CGRect frame = CGRectMake(center.x - size.width/2, center.y-size.height/2, size.width, size.height);
    
    self.frame = CGRectMake(0, 0, 1024, 1024);
    [self setupView:frame];
    
    if ((_indexOfSelectedValue >= 0) &&  (_indexOfSelectedValue < [_table numberOfRowsInSection:0])) {
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_indexOfSelectedValue inSection:0]
                      atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    
    //Unhide View
    self.hidden = NO;
    isHidden = NO;
}

- (void) setupView:(CGRect)frame{
    
    //TableView Height
    int height = MIN(frame.size.height, (_dataSource.count*heightOfRow + heightOfHeader));
    
    CGPoint center = self.window.center;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
            if (IS_IPHONE_DEVICE) {
                
                frame.size.width = self.window.frame.size.width;
                frame.size.height = MIN(self.window.frame.size.width*0.8, height);
            }
            else{
                frame.size.width = MIN(height*1.5, self.window.frame.size.width/2);
                frame.size.height = height;
            }
            frame.origin.x = center.y - frame.size.width/2;
            frame.origin.y = center.x - frame.size.height/2;
        }
        else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
            if (IS_IPHONE_DEVICE) {
                frame.size.width = self.window.frame.size.width;
                frame.size.height = MIN(self.window.frame.size.width*0.8, height);
            }
            else{
                frame.size.width = MIN(height*1.5, self.window.frame.size.width/2);
                frame.size.height = height;
            }
            
            frame.origin.x = center.y - frame.size.width/2;
            frame.origin.y = center.x - frame.size.height/2;
        }
        else {
            if (IS_IPHONE_DEVICE) {
                frame.size.width = 240;
                frame.size.height = MIN(360,height);
            }
            else{
                frame.size.width = MIN(height*1.5, self.window.frame.size.width/2);
                frame.size.height = height;
            }
            
            frame.origin.x = center.x - frame.size.width/2;
            frame.origin.y = center.y - frame.size.height/2;
        }
    }
    else {
        frame.size.height = height;
        frame.origin.x = center.x - frame.size.width/2;
        frame.origin.y = center.y - frame.size.height/2;
    }
    
    _table.frame = frame;
    [_table reloadData];
}

- (void)rotateView:(NSNotification*)notify {
    
    NSDictionary* dict = notify.object;
    NSString* centreX = [dict objectForKey:@"centerX"];
    NSString* centreY = [dict objectForKey:@"centerY"];
    NSString* sizeW = [dict objectForKey:@"sizeW"];
    NSString* sizeH = [dict objectForKey:@"sizeH"];
    
    //Setup frames
    CGRect frame = CGRectMake([centreX floatValue] - [sizeW floatValue]/2, [centreY floatValue]-[sizeH floatValue]/2,
                              [sizeW floatValue], [sizeH floatValue]);
    if (!self.isHidden) {
        self.frame = CGRectMake(0, 0, 1024, 1024);
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self setupView:frame];
                         } completion:nil];
    }
}

- (void)hideOptionsPopup{
    
    self.hidden = YES;
    isHidden = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UI Helpers

- (void)buttonLongPressed:(UILongPressGestureRecognizer*)gestureRecognizer{
    
    CGPoint p = [gestureRecognizer locationInView:_table];
    
    NSIndexPath *indexPath = [_table indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    }
    else{
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            //Set selected
            _indexOfSelectedValue = indexPath.row;
            
            //Call delegate (optional)
            if ([_delegate respondsToSelector:@selector(selectedOptionAfterLongPressAtIndex:)]) {
                [_delegate selectedOptionAfterLongPressAtIndex:indexPath.row];
            }
            
            [self hideOptionsPopup];
        }
    }
}

- (UIColor *)getAverageColor{
    
    CGSize size = {1, 1};
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
    [APP_ICON drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
    uint8_t *data = CGBitmapContextGetData(ctx);
    UIColor *color = [UIColor colorWithRed:data[2] / 255.0f
                                     green:data[1] / 255.0f
                                      blue:data[0] / 255.0f
                                     alpha:1];
    UIGraphicsEndImageContext();
    return color;
}


#pragma mark - TableView Helpers

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    heightOfRow = 56;
    
    return heightOfRow;
}

static int heightOfHeader = 56;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
  
    UILabel* headerLabel = [[UILabel alloc]init];
    headerLabel.font = [UIFont fontWithName:@"Futura-Medium" size:22];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = _titleString;
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [headerLabel sizeToFit];
    heightOfHeader = headerLabel.frame.size.height;
    heightOfHeader += 15;
    return heightOfHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    MarqueeLabel *headerLabel = [[MarqueeLabel alloc]init];
    headerLabel.rate = 60.0;
    headerLabel.backgroundColor = CUSTOM_BACKGROUNDCOLOR;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:22];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = [NSString stringWithFormat:@" %@ ",_titleString];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [headerLabel restartLabel];
    return headerLabel;
}

static NSString* cellIdentifier = @"Popup";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = cellBackgroundColor;
        cell.frame = CGRectMake(0, 0, _table.frame.size.width, 56);
    }
    
    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    UIView *customBackground        = [[UIView alloc]initWithFrame:cell.frame];
    customBackground.backgroundColor= CUSTOM_LIGHT_BLUE_COLOR;
    cell.selectedBackgroundView     = customBackground;
    
    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }
    
    //Selected Cell
    if (indexPath.row == _indexOfSelectedValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = CUSTOM_LIGHT_BLUE_COLOR;
    }
    else{
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [_dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    [_delegate selectedOptionAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self hideOptionsPopup];
}

@end
