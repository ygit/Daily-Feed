//
//  ViewController.m
//  Daily Feed
//
//  Created by yogesh singh on 31/10/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import <UIImageView+AFNetworking.h>

#import "ViewController.h"
#import "FeedDetailVC.h"
#import "HomeTableViewCell.h"
#import "PopupView.h"
#import "Utils.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, PopupViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSArray *dataArr;

@property (weak, nonatomic) IBOutlet UILabel *sourcesLab;
@property (weak, nonatomic) IBOutlet UILabel *apiLab;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIButton *categoryBtn;
@property (strong, nonatomic) PopupView *popup;
@property (strong, nonatomic) NSString *categoryType;
@property (strong, nonatomic) NSMutableArray *categories;

@property (nonatomic) BOOL showBookmarks;


@end

@implementation ViewController
@synthesize table, dataArr;
@synthesize sourcesLab, apiLab;
@synthesize searchBar, showBookmarks;
@synthesize categoryBtn, categories, popup, categoryType;


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    table.delegate = self;
    table.dataSource = self;
    
    categoryType = @"None";             //default
    categories = [NSMutableArray array];
    [categories addObject:@"None"];
    [categoryBtn setTitle:[NSString stringWithFormat:@"Feeds by Category : %@",categoryType] forState:UIControlStateNormal];
    
    self.navigationItem.title = @"Daily Feed";
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTable:)
                                                 name:FETCHED_FEEDS_SHOULD_UPDATE_VIEW
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateHits:)
                                                 name:FETCHED_API_HITS_SHOULD_UPDATE_VIEW
                                               object:nil];
    
    
    [ServerHelper fetchFeeds];
    [ServerHelper fetchHits];
    dataArr = [DataProvider getFeedsForCategory:categoryType BySearchText:searchBar.text];
    [sourcesLab setText:[NSString stringWithFormat:@"Feed Sources : %lu", (unsigned long)dataArr.count]];
    [apiLab setText:[NSString stringWithFormat:@"API Hits : %@", [DataProvider getApiHits]]];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[self getAverageColor] CGColor],
                                                (id)[[self getAverageColor] CGColor],
                                                (id)[[UIColor whiteColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UI Helpers

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

- (void)updateTable:(id)sender{

    [MarqueeLabel controllerLabelsShouldLabelize:self];
    
    if (showBookmarks) {
        dataArr = [DataProvider getBookmarksForCategory:categoryType BySearchText:searchBar.text];
        [categoryBtn setTitle:[NSString stringWithFormat:@"Bookmarks by Category : %@",categoryType] forState:UIControlStateNormal];
        [searchBar setPlaceholder:@"Search Bookmarks"];
    }
    else{
        dataArr = [DataProvider getFeedsForCategory:categoryType BySearchText:searchBar.text];
        [categoryBtn setTitle:[NSString stringWithFormat:@"Feeds by Category : %@",categoryType] forState:UIControlStateNormal];
        [searchBar setPlaceholder:@"Search (by title or source)"];
    }
    
    [table reloadData];
    [sourcesLab setText:[NSString stringWithFormat:@"Feed Sources : %lu", (unsigned long)dataArr.count]];
    [MarqueeLabel controllerLabelsShouldAnimate:self];
}

- (void)updateHits:(NSNotification *)notification{
    [apiLab setText:[NSString stringWithFormat:@"API Hits : %@", [DataProvider getApiHits]]];
}

- (IBAction)categorySelected:(UIButton *)sender {
    
    [searchBar resignFirstResponder];
    
    NSArray *fetchedCategories = [DataProvider getCategories];
    
    for (NSDictionary *category in fetchedCategories) {
        if (![categories containsObject:[category valueForKey:@"category"]]) {
            [categories addObject:[category valueForKey:@"category"]];
        }
    }
    
    CGPoint center  = CGPointMake(self.view.window.frame.size.width/2, self.view.window.frame.size.height/2);
    CGSize  size    = CGSizeMake(self.view.window.frame.size.width/2, self.view.window.frame.size.height/2);
    
    if (IS_IPHONE_DEVICE) {
        size.width *= 1.5;
        size.height *= 1.5;
    }
    
    popup = [[PopupView alloc] initWithTitleString:@"Select a Category"
                                        andOptions:categories
                                 withSelectedIndex:[categories indexOfObject:categoryType]
                                          delegate:self];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [[[window subviews] objectAtIndex:0] addSubview:popup];
    [popup showOptionsPopupWithCenter:center andSize:size];
}

- (void)selectedOptionAtIndex:(NSInteger)selectedIndex{

    if (selectedIndex < categories.count) {
        
        categoryType = [categories objectAtIndex:selectedIndex];
        
        [categoryBtn setTitle:[NSString stringWithFormat:@"Feeds by Category : %@",categoryType] forState:UIControlStateNormal];
     
        [self updateTable:nil];
    }
}

- (void)searchFeeds{
    
    [MarqueeLabel controllerLabelsShouldLabelize:self];
   
    if (showBookmarks) {
        dataArr = [DataProvider getBookmarksForCategory:categoryType BySearchText:searchBar.text];
        [categoryBtn setTitle:[NSString stringWithFormat:@"Bookmarks by Category : %@",categoryType] forState:UIControlStateNormal];
        [searchBar setPlaceholder:@"Search Bookmarks"];
    }
    else{
        dataArr = [DataProvider getFeedsForCategory:categoryType BySearchText:searchBar.text];
        [categoryBtn setTitle:[NSString stringWithFormat:@"Feeds by Category : %@",categoryType] forState:UIControlStateNormal];
        [searchBar setPlaceholder:@"Search (by title or source)"];
    }
    
    [table reloadData];
    [sourcesLab setText:[NSString stringWithFormat:@"Feed Sources : %lu", (unsigned long)dataArr.count]];
    [MarqueeLabel controllerLabelsShouldAnimate:self];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self searchFeeds];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
 
    [self searchFeeds];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    showBookmarks = !showBookmarks;
    [self showBookmarkedFeeds];
}

- (void)showBookmarkedFeeds{
    
    [MarqueeLabel controllerLabelsShouldLabelize:self];
    
    if (showBookmarks) {
        dataArr = [DataProvider getBookmarksForCategory:categoryType BySearchText:searchBar.text];
        [categoryBtn setTitle:[NSString stringWithFormat:@"Bookmarks by Category : %@",categoryType] forState:UIControlStateNormal];
        [searchBar setPlaceholder:@"Search Bookmarks"];
    }
    else{
        dataArr = [DataProvider getFeedsForCategory:categoryType BySearchText:searchBar.text];
        [categoryBtn setTitle:[NSString stringWithFormat:@"Feeds by Category : %@",categoryType] forState:UIControlStateNormal];
        [searchBar setPlaceholder:@"Search (by title or source)"];
    }
    
    [table reloadData];
    [sourcesLab setText:[NSString stringWithFormat:@"Feed Sources : %lu", (unsigned long)dataArr.count]];
    [MarqueeLabel controllerLabelsShouldAnimate:self];
}


#pragma mark - TableView Helpers

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
    
    if (!cell) {
        cell = [[HomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.title.marqueeType = MLContinuous;
    }
    
    if (indexPath.row < dataArr.count) {
        
        Feed *feed = dataArr[indexPath.row];
        
        cell.title.text = feed.title;

        __weak HomeTableViewCell *weakCell = cell;
        [cell.img setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:feed.imgUrl]]
                        placeholderImage:APP_ICON
                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                     if (image) {
                                         [UIView transitionWithView:weakCell.img
                                                           duration:0.2
                                                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve
                                                         animations:^{
                                                             weakCell.img.image = image;
                                                         }
                                                         completion:nil];
                                     }
                                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                     
                                     NSLog(@"homeVC cellForRowAtIndexPath setImageWithURLRequest error : %@",error);
                                 }];
        
    }

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"feedDetail"]) {
        
        if ([sender isKindOfClass:[HomeTableViewCell class]]) {
            HomeTableViewCell *selectedCell = sender;
            NSIndexPath *index = [table indexPathForCell:selectedCell];

            if (index.row < dataArr.count) {
                Feed *selectedFeed = dataArr[index.row];
                
                FeedDetailVC *feedDetailVC = [segue destinationViewController];
                feedDetailVC.feed = selectedFeed;
                feedDetailVC.dataArr = dataArr;
            }
        }
    }
}


@end
