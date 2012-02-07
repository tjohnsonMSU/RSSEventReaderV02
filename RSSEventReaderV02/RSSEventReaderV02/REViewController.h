//
//  REViewController.h
//  RSSEventReaderV02
//
//  Created by Seals, Shawn on 2/3/12.
//  Copyright (c) 2012 __MSU__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface REViewController : UIViewController <UIApplicationDelegate, NSXMLParserDelegate> {
    UIButton *requestButton_;
    NSURLConnection *eventFeedConnection;
    NSMutableData *eventData;
    
    // these variables are used during parsing
    Event *currentEventObject;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
    
}

@property (strong, nonatomic) IBOutlet UIButton *requestButton;
@property (nonatomic, strong) NSURLConnection *eventFeedConnection;
@property (nonatomic, strong) NSMutableData *eventData; // The data returned from the NSURLConnection

- (void)handleError:(NSError *)error;

- (IBAction)requestButtonPressed:(id)sender;

@end
