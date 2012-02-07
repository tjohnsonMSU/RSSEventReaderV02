//
//  REEventDetailView.h
//  RSSEventReaderV02
//
//  Created by Seals, Shawn on 2/5/12.
//  Copyright (c) 2012 __MSU__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface REEventDetailView : UIViewController <UIActionSheetDelegate> {
    Event *eventEDV;
    UIBarButtonItem *backButton;
    UIButton *addToCalendarButton;
    UIButton *gotoEventWebPageButton;
    UITextView *titleField;
    UILabel *dateField;
    UILabel *timeField;
    UILabel *locationField;
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) Event *eventEDV;
@property (nonatomic, strong) IBOutlet UIButton *addToCalendarButton;
@property (nonatomic, strong) IBOutlet UIButton *gotoEventWebPageButton;
@property (nonatomic, strong) IBOutlet UITextView *titleField;
@property (nonatomic, strong) IBOutlet UILabel *dateField;
@property (nonatomic, strong) IBOutlet UILabel *timeField;
@property (nonatomic, strong) IBOutlet UILabel *locationField;


- (IBAction)backButtonPressed:(id)sender;
- (IBAction)addEventToCalendar:(id)sender;
- (IBAction)gotoEventWebPage:(id)sender;

@end
