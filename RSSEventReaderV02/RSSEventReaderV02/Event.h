//
//  Event.h
//  URLRequestTestV01
//
//  Created by Seals, Shawn on 2/2/12.
//  Copyright (c) 2012 __MSU__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject {
@private
    // Full rss title of event.
    // Example format: 1/31 7:30 PM [W] Men's Basketball at Abilene Christian
    NSString *title;
    // Description of the event.
    NSString *description;
    // GUID of the event;
    NSString *guid;
    // Location of the event.
    NSString *location;
    // Start time and date.
    NSDate *startDate;
    NSDate *localStartDate;
    // End time and date.
    NSDate *endDate;
    NSDate *localEndDate;
    // URL link to event info on web.
    NSURL *eventWebLink;
    // Flag for added to calendar.
    BOOL addedToCalendarFlag;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *localStartDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *localEndDate;
@property (nonatomic, strong) NSURL *eventWebLink;

@end
