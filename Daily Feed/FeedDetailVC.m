//
//  FeedDetailVC.m
//  Daily Feed
//
//  Created by yogesh singh on 01/11/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

#import <UIImageView+AFNetworking.h>

#import "FeedDetailVC.h"
#import "Utils.h"
#import "MarqueeLabel.h"

@interface FeedDetailVC ()

@property (weak, nonatomic) IBOutlet MarqueeLabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *bookmarkBtn;
@property (weak, nonatomic) IBOutlet UIButton *sourceLinkBtn;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UITextView *detail;
@property (weak, nonatomic) IBOutlet UIButton *readMore;
@property (weak, nonatomic) IBOutlet MarqueeLabel *liveLab;
@property (weak, nonatomic) IBOutlet UILabel *blinkingLiveLab;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) UIImageView *blurView;
@property (strong, nonatomic) __block UIColor *contrastingTextColor;
@property (strong, nonatomic) __block UIImage *blurImg;

@end

@implementation FeedDetailVC
@synthesize feed, dataArr, blurView;
@synthesize titleLab, img, detail, backBtn;
@synthesize bookmarkBtn, sourceLinkBtn;
@synthesize readMore, liveLab, shareBtn;
@synthesize blinkingLiveLab, contrastingTextColor, blurImg;

#pragma mark - View Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    contrastingTextColor = [UIColor whiteColor];
    
    [self setTitleText];
    [self setTextColor];
    
    [bookmarkBtn setSelected:[feed.bookmark boolValue]];
    
    [sourceLinkBtn setTitle:feed.url forState:UIControlStateNormal];
    
    [img setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:feed.imgUrl]]
               placeholderImage:APP_ICON
                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                          
                            if (image) {
                                [UIView transitionWithView:img
                                                  duration:0.2
                                                   options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve
                                                animations:^{
                                                    img.image = image;
                                                }
                                                completion:nil];
                            }
                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                 
                                 NSLog(@"feedDetailVC setImageWithURLRequest error : %@",error);
                             }];
    
    [detail setText:feed.content];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setLiveFeed)];
    [liveLab addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setLiveFeed)];
    [blinkingLiveLab addGestureRecognizer:tap2];
    
    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    
    blurView = [[UIImageView alloc] init];
    [self.view addSubview:blurView];
    [self.view sendSubviewToBack:blurView];
    [self setBlur];
    
    [self setHiddenStatus:YES];
}

- (void)viewWillAppear:(BOOL)animated{
  
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBlur)
                                                 name:FETCHED_IMAGE_UPDATE_VIEW object:nil];
    
    [self dropShadowOnImg];
    
    [self setLiveFeed];
    [self performSelector:@selector(setLiveFeed) withObject:nil afterDelay:30];
    
    blurView.frame = self.view.frame;
    blurView.image = blurImg;
    
    contrastingTextColor = [self getContrastingColor:[self getAverageColor]];
    [self setTitleText];
    [self setTextColor];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(setLiveBlinkLab) withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action Helpers

- (IBAction)goBack:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)setBookmark:(UIButton *)sender {
    sender.selected = !sender.selected;
    [DataParser setFeed:feed BookmarkOption:sender.selected];
}

- (IBAction)goToSource:(UIButton *)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:feed.url]];
}

- (IBAction)shareFeed:(UIButton *)sender {
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObject:feed.url]
                                                                             applicationActivities:nil];
    [self presentViewController:activityVC animated:TRUE completion:nil];
}


#pragma mark - UI Helpers

- (void)setLiveFeed{
    
    int rand = arc4random() % dataArr.count;
    Feed *liveFeed = dataArr[rand];
    [MarqueeLabel controllerLabelsShouldLabelize:self];
    
    [UIView transitionWithView:liveLab
                      duration:1
                       options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [liveLab setText:liveFeed.title];
                    }
                    completion:^(BOOL finished) {
                        
                        [self performSelector:@selector(setLiveFeed) withObject:nil afterDelay:30];
                        [MarqueeLabel controllerLabelsShouldAnimate:self];
                    }];
}

- (void)setBlur{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        CIImage *inputImage = [[CIImage alloc] initWithImage:img.image];
        
        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
        
        [filter setValue:inputImage forKey:kCIInputImageKey];
        
        [filter setValue:[NSNumber numberWithFloat:30.0f] forKey:@"inputRadius"];
        
        CIImage *result = [filter valueForKey:kCIOutputImageKey];
        
        CGImageRef cgImage = [[Utils getCIContext] createCGImage:result fromRect:[inputImage extent]];
        
        blurImg = [UIImage imageWithCGImage:cgImage];
        [[NSNotificationCenter defaultCenter] postNotificationName:FETCHED_IMAGE_UPDATE_VIEW object:nil];
        
        CGImageRelease(cgImage);
    });
}

- (void)updateBlur{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        blurView.image = blurImg;
        blurView.alpha = 0;
       
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             blurView.alpha = 1;
                             contrastingTextColor = [self getContrastingColor:[self getAverageColor]];
                             [self setTitleText];
                             [self setTextColor];
                             [self dropShadowOnImg];
                         } completion:^(BOOL finished) {
                             
                             blurView.alpha = 1;
                             [self setHiddenStatus:NO];
                         }];
    });
}

- (void)setHiddenStatus:(BOOL)isHidden{
    [backBtn setHidden:isHidden];
    [titleLab setHidden:isHidden];
    [bookmarkBtn setHidden:isHidden];
    [sourceLinkBtn setHidden:isHidden];
    [shareBtn setHidden:isHidden];
    [detail setHidden:isHidden];
    [blinkingLiveLab setHidden:isHidden];
    [liveLab setHidden:isHidden];
}

- (void)dropShadowOnImg{
    
    CGRect imgActualFrame = [Utils getFrameSizeForImage:img.image inImageView:img];

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:imgActualFrame];
    img.layer.masksToBounds = NO;
    img.layer.shadowColor = contrastingTextColor.CGColor;
    img.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    img.layer.shadowOpacity = 0.5f;
    img.layer.shadowPath = shadowPath.CGPath;
}

- (UIColor *)getAverageColor{
    
    CGSize size = {1, 1};
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
    [img.image drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
    uint8_t *data = CGBitmapContextGetData(ctx);
    UIColor *color = [UIColor colorWithRed:data[2] / 255.0f
                                     green:data[1] / 255.0f
                                      blue:data[0] / 255.0f
                                     alpha:1];
    UIGraphicsEndImageContext();
    return color;
}

- (UIColor*)getContrastingColor:(UIColor*)bgColor{
    
    CGFloat r=0,g=0,b=0,a=0;
    
    if ([bgColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [bgColor getRed:&r green:&g blue:&b alpha:&a];
    }
    
    NSArray *rgbaArray = [NSArray arrayWithObjects:@(r),@(g),@(b),@(a), nil];
    
    double color = 1 - ((0.299 * [rgbaArray[0] doubleValue]) + (0.587 * [rgbaArray[1] doubleValue]) + (0.114 * [rgbaArray[2] doubleValue]));
    return (color < 0.5) ? [UIColor blackColor] : [UIColor whiteColor];
}

- (void)setTextColor{
    [detail setTextColor:contrastingTextColor];
    [liveLab setTextColor:contrastingTextColor];
    [blinkingLiveLab setTextColor:contrastingTextColor];
}

- (void)setTitleText{
    
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:feed.title
                                                                                 attributes:@{NSForegroundColorAttributeName:contrastingTextColor}];
    [titleStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" under "
                                                                     attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}]];
    [titleStr appendAttributedString:[[NSAttributedString alloc] initWithString:feed.category
                                                                     attributes:@{NSForegroundColorAttributeName:contrastingTextColor}]];
    [titleStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" by "
                                                                     attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}]];
    [titleStr appendAttributedString:[[NSAttributedString alloc] initWithString:feed.source
                                                                     attributes:@{NSForegroundColorAttributeName:contrastingTextColor}]];
    [titleLab setAttributedText:titleStr];
}

- (void)setLiveBlinkLab{

    [UIView animateWithDuration:1 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         blinkingLiveLab.alpha = 0.1;
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:1 delay:0
                                             options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve
                                          animations:^{
                                            blinkingLiveLab.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              [self performSelector:@selector(setLiveBlinkLab)
                                                         withObject:nil afterDelay:1];
                                          }];
                         
                     }];
}

@end
