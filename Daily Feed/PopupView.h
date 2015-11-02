//
//  PopupView.h
//  Daily Feed
//
//  Created by yogesh singh on 31/10/15.
//  Copyright © 2015 yogesh singh. All rights reserved.
//

@import UIKit;

@protocol PopupViewDelegate <NSObject>
- (void) selectedOptionAtIndex:(NSInteger)selectedIndex;
@optional
- (void) selectedOptionAfterLongPressAtIndex:(NSInteger)selectedIndex;
@end

@interface PopupView : UIView 

@property (nonatomic) BOOL isHidden;
@property (nonatomic) __block BOOL isEmpty;
@property (nonatomic) NSInteger indexOfSelectedValue;

@property (nonatomic,strong) NSDictionary* currentOption;
@property (nonatomic,strong) UIView* tapToDismiss;
@property (nonatomic,strong) NSString* titleString;
@property (nonatomic,strong) UIColor* cellBackgroundColor;
@property (nonatomic,strong) UITableView* table;
@property (nonatomic,strong) id<PopupViewDelegate> delegate;
@property (nonatomic,strong) __block NSArray* dataSource;


- (id) initWithTitleString:(NSString*)titleString andOptions:(NSArray*)options
         withSelectedIndex:(NSInteger)indexSelected delegate:(id)delegate;

- (void) showOptionsPopupWithCenter:(CGPoint)center andSize:(CGSize)size;
- (void) hideOptionsPopup;

@end
